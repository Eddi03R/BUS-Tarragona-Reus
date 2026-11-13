# Reel automatici (prototipo)

Genera due video verticali 1080x1920 (italiano e inglese) registrando il sito:
Nightlife → scelta del locale → risultati → dettaglio corsa. Titolo iniziale,
sottotitoli e schermata finale sono aggiunti da `compose.py`.

```bash
tools/reels/build_reel.sh
```

- La data è fissata a sabato 14 novembre, 22:40, e la posizione a Tarragona, così
  i risultati sono sempre quelli di una serata di sabato.
- I testi dei sottotitoli stanno in `compose.py` (dizionario `TXT`).
- Il passaggio sul sito si cambia in `record.js` (coordinate dei tocchi + tempi).
- I video non vanno nel repository (cartella ignorata).
- Audio: il video ha una traccia silenziosa; la musica va scelta dentro TikTok/Instagram
  al momento della pubblicazione (diritti).
