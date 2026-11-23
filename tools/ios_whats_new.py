#!/usr/bin/env python3
"""Imposta "Novità di questa versione" della versione iOS in preparazione.

Legge ios_config/whats_new/<lingua>.txt (it, en, es, ca, de) e le scrive sulle
localizzazioni della versione in App Store Connect (API ufficiale, stessa chiave
del caricamento). Best effort: ogni errore viene solo stampato (exit 0).
Variabili: ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH.
"""
import json, os, sys, time, urllib.request, urllib.error
import jwt  # pip install pyjwt cryptography

BUNDLE_ID = "app.lumelabs.bustarragona"
BASE = "https://api.appstoreconnect.apple.com"
DIR = os.path.join(os.path.dirname(__file__), "..", "ios_config", "whats_new")
LOCALES = {"it": "it", "en": "en", "es": "es", "ca": "ca", "de": "de"}  # prefisso locale -> file

def token():
    key = open(os.environ["ASC_KEY_PATH"]).read()
    now = int(time.time())
    return jwt.encode(
        {"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 900,
         "aud": "appstoreconnect-v1"},
        key, algorithm="ES256", headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"})

def call(method, path, body=None):
    req = urllib.request.Request(BASE + path, method=method,
                                 data=json.dumps(body).encode() if body else None)
    req.add_header("Authorization", "Bearer " + token())
    req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return json.loads(r.read() or b"{}")
    except urllib.error.HTTPError as e:
        raise RuntimeError(f"{method} {path}: {e.code} {e.read()[:300]!r}")

def notes_for(locale):
    for prefix, name in LOCALES.items():
        if locale.lower().startswith(prefix):
            p = os.path.join(DIR, name + ".txt")
            if os.path.exists(p):
                return open(p, encoding="utf-8").read().strip()
    return None

def main():
    if not any(f.endswith(".txt") for f in os.listdir(DIR)):
        print("Nessun file di note in ios_config/whats_new: niente da fare.")
        return
    apps = call("GET", f"/v1/apps?filter[bundleId]={BUNDLE_ID}")["data"]
    if not apps:
        print("App non trovata."); return
    app_id = apps[0]["id"]
    states = "PREPARE_FOR_SUBMISSION,DEVELOPER_REJECTED,REJECTED,METADATA_REJECTED"
    versions = call("GET", f"/v1/apps/{app_id}/appStoreVersions?filter[appStoreState]={states}")["data"]
    vs = os.environ.get("VERSION_STRING")
    if not versions and vs:
        created = call("POST", "/v1/appStoreVersions", {"data": {
            "type": "appStoreVersions", "attributes": {"platform": "IOS", "versionString": vs},
            "relationships": {"app": {"data": {"type": "apps", "id": app_id}}}}})
        versions = [created["data"]]
        print(f"Versione {vs} creata in App Store Connect.")
    if not versions:
        print("Nessuna versione in preparazione: le note non si possono ancora impostare."); return
    vid = versions[0]["id"]
    locs = call("GET", f"/v1/appStoreVersions/{vid}/appStoreVersionLocalizations")["data"]
    for loc in locs:
        code = loc["attributes"]["locale"]
        text = notes_for(code)
        if not text:
            print(f"{code}: nessun file di note, salto."); continue
        try:
            call("PATCH", f"/v1/appStoreVersionLocalizations/{loc['id']}",
                 {"data": {"type": "appStoreVersionLocalizations", "id": loc["id"],
                           "attributes": {"whatsNew": text}}})
            print(f"{code}: note impostate.")
        except RuntimeError as e:
            print(f"{code}: non impostabili ({e})")

if __name__ == "__main__":
    try:
        main()
    except Exception as e:  # best effort
        print("Note di rilascio non impostate:", e)
    sys.exit(0)
