# Note di rilascio iOS ("Novità di questa versione")

A ogni rilascio che include iOS Claude scrive qui, **da solo**, le note della versione
in un file per lingua (testo semplice, max 4000 caratteri, in genere 3-6 righe):

- `it.txt`, `en.txt`, `es.txt`, `ca.txt`, `de.txt`

Il workflow `ios-release.yml` (dopo il caricamento su TestFlight) esegue
`tools/ios_whats_new.py`, che le imposta sulla versione dell'app in preparazione in
App Store Connect. È un tentativo "best effort": se non c'è una versione modificabile
(per esempio la prima uscita 1.0, che non ha le note) non fa niente e non blocca nulla.
Dopo averle scritte il file resta nel repo come storico: alla release successiva si riscrive.
