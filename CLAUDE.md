# ErasBus Tarragona — istruzioni per Claude

- **Per ogni modifica al codice usa la skill `ponytail`** (livello `full`, quello predefinito), in `.claude/skills/ponytail/`: la modifica più piccola che risolve davvero il problema, senza funzioni o astrazioni non richieste, e una risposta breve che dice cosa è stato saltato e i rischi. L'utente può cambiare livello (`lite`/`ultra`) o dire "normal mode" per disattivarla.
- Il contesto completo del progetto, le preferenze dell'utente e il processo di pubblicazione sono in `docs/HANDOFF.md`: leggilo a inizio sessione.
- La cartella `.claude/` (skill e strumenti di lavoro) **non fa parte dell'app**: non va mai incluso nei pacchetti di build di sito, Android o iOS. Le build prendono solo `lib/`, `web/`, `android/`, gli `assets/` elencati in `pubspec.yaml` e `build/web`.
