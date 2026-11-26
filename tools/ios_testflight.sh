#!/usr/bin/env bash
# Assegna la build ai gruppi TestFlight (vedi ios_testflight.py). Serve ASC_KEY_ID, ASC_ISSUER_ID,
# ASC_KEY_PATH, BUILD_NUMBER. Best effort.
python3 -m venv .venv-tf
. .venv-tf/bin/activate
pip install --quiet pyjwt cryptography
python3 tools/ios_testflight.py
