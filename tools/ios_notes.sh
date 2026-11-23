#!/usr/bin/env bash
# Crea (se manca) la versione iOS in App Store Connect e imposta le note di rilascio.
# Serve ASC_KEY_ID, ASC_ISSUER_ID e ASC_KEY_PATH nell'ambiente. Best effort.
set -e
python3 -m venv .venv-notes
. .venv-notes/bin/activate
pip install --quiet pyjwt cryptography
VERSION_STRING=$(grep '^version:' pubspec.yaml | sed -E 's/version: *([0-9.]+).*/\1/') python3 tools/ios_whats_new.py
