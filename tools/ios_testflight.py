#!/usr/bin/env python3
"""Dopo l'upload: mette le note "Cosa provare" sulla build e la assegna ai gruppi TestFlight
"Tester interni" e "Tester esterni" (per gli esterni prova anche a inviarla alla Beta App Review).
Best effort: ogni errore viene solo stampato (exit 0). Variabili: ASC_KEY_ID, ASC_ISSUER_ID,
ASC_KEY_PATH, BUILD_NUMBER (numero di build iOS = github.run_number)."""
import os, sys, time
sys.path.insert(0, os.path.dirname(__file__))
from ios_whats_new import call, notes_for, BUNDLE_ID

GROUPS = ("tester interni", "tester esterni")

def main():
    build_no = os.environ["BUILD_NUMBER"]
    app_id = call("GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}")["data"][0]["id"]
    build = None
    for _ in range(40):  # Apple elabora la build: fino a ~20 minuti
        r = call("GET", f"/v1/builds?filter[app]={app_id}&filter[version]={build_no}&limit=1")["data"]
        if r and r[0]["attributes"].get("processingState") == "VALID":
            build = r[0]; break
        print("Build in elaborazione, attendo...")
        time.sleep(30)
    if not build:
        print("Build non pronta: gruppi non assegnati."); return
    bid = build["id"]
    # note "Cosa provare" per le lingue del beta
    try:
        locs = call("GET", f"/v1/builds/{bid}/betaBuildLocalizations")["data"]
        have = {l["attributes"]["locale"].lower(): l["id"] for l in locs}
        for code in ("it", "en-US", "es-ES", "ca", "de-DE"):
            text = notes_for(code)
            if not text:
                continue
            if code.lower() in have:
                call("PATCH", f"/v1/betaBuildLocalizations/{have[code.lower()]}",
                     {"data": {"type": "betaBuildLocalizations", "id": have[code.lower()], "attributes": {"whatsNew": text}}})
            else:
                call("POST", "/v1/betaBuildLocalizations", {"data": {
                    "type": "betaBuildLocalizations", "attributes": {"locale": code, "whatsNew": text},
                    "relationships": {"build": {"data": {"type": "builds", "id": bid}}}}})
            print(f"{code}: note TestFlight impostate.")
    except RuntimeError as e:
        print("Note TestFlight non impostate:", e)
    # gruppi
    groups = call("GET", f"/v1/apps/{app_id}/betaGroups?limit=200")["data"]
    for g in groups:
        name = g["attributes"].get("name", "")
        if name.lower() not in GROUPS:
            continue
        try:
            call("POST", f"/v1/builds/{bid}/relationships/betaGroups",
                 {"data": [{"type": "betaGroups", "id": g["id"]}]})
            print(f"Build assegnata al gruppo '{name}'.")
        except RuntimeError as e:
            if "internal group" in str(e):  # gruppo interno con accesso a tutte le build: la riceve già da solo
                print(f"Gruppo '{name}': riceve già tutte le build in automatico.")
            else:
                print(f"Gruppo '{name}' non assegnabile:", e)
    # Beta App Review (serve per i tester esterni; errore = già inviata o non richiesta)
    try:
        call("POST", "/v1/betaAppReviewSubmissions", {"data": {
            "type": "betaAppReviewSubmissions",
            "relationships": {"build": {"data": {"type": "builds", "id": bid}}}}})
        print("Inviata alla Beta App Review.")
    except RuntimeError as e:
        print("Beta App Review:", e)

if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # best effort
        print("TestFlight gruppi: errore:", e)
