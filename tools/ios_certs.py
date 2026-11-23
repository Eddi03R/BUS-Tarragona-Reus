#!/usr/bin/env python3
"""Elenca i certificati dell'account Apple e, con --revoke-ci, revoca quelli di sviluppo creati
dalla compilazione automatica ("Created via API"): ogni build sul server ne crea uno nuovo e
Apple ha un limite. Non tocca i certificati creati a mano (Xcode sul Mac) né quelli di distribuzione.
Variabili: ASC_KEY_ID, ASC_ISSUER_ID, ASC_KEY_PATH."""
import sys
sys.path.insert(0, __import__("os").path.dirname(__file__))
from ios_whats_new import call  # stessa autenticazione

def main():
    revoke = "--revoke-ci" in sys.argv
    certs = call("GET", "/v1/certificates?limit=200")["data"]
    print(f"{len(certs)} certificati:")
    for c in certs:
        a = c["attributes"]
        print(f'- {a.get("certificateType")} | {a.get("name")} | {a.get("displayName")} | scade {a.get("expirationDate")} | id {c["id"]}')
    if not revoke:
        return
    for c in certs:
        a = c["attributes"]
        if "DEVELOPMENT" in (a.get("certificateType") or "") and "Created via API" in (a.get("name") or ""):
            try:
                call("DELETE", f"/v1/certificates/{c['id']}")
                print("revocato", c["id"])
            except RuntimeError as e:
                print("non revocabile", c["id"], e)

if __name__ == "__main__":
    main()
