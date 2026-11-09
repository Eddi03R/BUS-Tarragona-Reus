# Reus ↔ Tarragona Bus

App Flutter (pensata per Web, Android e iOS dallo stesso codice) per pianificare un viaggio
sulla linea e4 Monbus tra Reus e Tarragona: scegli fermata di partenza e di arrivo, data e ora
(partenza minima oppure arrivo entro), e l'app indica subito quale bus prendere. Include anche
il servizio notturno (Nightlife) e vari temi colore.

Sito live: https://bustarragonareus.pages.dev · Android: `app.lumelabs.bustarragona` (Play Store, closed testing).

Pubblicità sul sito: banner AdSense in fondo alla pagina, spento finché non si compilano `client` e `slot` in `web/ads.js` (e la riga in `web/ads.txt`). Lo spazio in Flutter è riservato in `AdsFrame` solo quando è attivo.

## Novità

- **v1.0.0+35 — Tema Natale 🎄**: tema speciale sempre in modalità chiara (rosso/verde su sfondo neve),
  con header a taglio rosso/verde, fiocchi di neve, alberi di Natale e barra superiore rossa su
  tutte le schermate (home, risultati, dettaglio corsa, impostazioni, privacy). Si attiva solo
  scegliendolo in Impostazioni → Colore tema.
- **Tema Halloween 🎃**: tema speciale sempre scuro con ragnatele e teschi.
- **Daylife / Nightlife**: due tab nella home; Nightlife cerca dalle 22:00 con calendari speciali
  (`night`, `night_salou`, `night_nt3`).
- **Temi colore**: verde (default), blu, indigo, viola, magenta, corallo, arancio, ambra, teal, blu petrolio.

Dati orari estratti da:
`H_A3_Reus-Tarragona_13-11-2025_v1.pdf` (Monbus, v131125) — salvato in `schedule.pdf` in questa
cartella per riferimento.

## Struttura

- `assets/data/stops.json` — elenco fermate con coordinate.
- `assets/data/timetable_weekday.json` — orari feriali (lun-ven, 1 set - 31 lug), entrambe le direzioni.
- `assets/data/timetable_saturday.json` — orari del sabato (tutto l'anno).
- `assets/data/timetable_sunday.json` — orari di domenica e festivi (tutto l'anno).
- `lib/data/schedule_repository.dart` — carica i JSON in memoria.
- `lib/services/journey_planner.dart` — logica di ricerca: dato origine/destinazione, calendario,
  modalità (parti dopo / arriva entro) e orario di riferimento, restituisce le corse utili ordinate.
- `lib/services/calendar_resolver.dart` — determina feriale/sabato/domenica dalla data scelta
  (i giorni festivi infrasettimanali vanno forzati manualmente con l'interruttore "Festivo" in Home).
- `lib/screens/home_screen.dart` — schermata di ricerca.
- `lib/screens/results_screen.dart` — elenco corse trovate, con la migliore evidenziata.
- `lib/screens/trip_detail_screen.dart` — dettaglio di una corsa.
- `lib/screens/settings_screen.dart` — impostazioni (temi, lingua, preferiti).
- `lib/theme/app_theme.dart`, `lib/services/theme_controller.dart` — temi (inclusi Halloween e Natale).
- `lib/widgets/christmas_decorations.dart`, `lib/widgets/halloween_decorations.dart` — decorazioni dei temi speciali.

## Stack tecnico

Flutter + Material 3, `flutter_map`/`latlong2` per la mappa (OpenStreetMap, nessuna API key
richiesta), `intl` per la formattazione di date/orari in italiano. Nessun backend: tutti i dati
sono statici negli asset JSON dell'app.

## Deploy

- **Web (Cloudflare Pages)**: da `master` pulito, `./deploy_web.sh` (macOS/Linux) oppure
  `deploy_web.ps1` (Windows). Bump versione, build, push su `master` e sul branch `gh-pages`
  (da cui Cloudflare serve i file).
- **Android (Play Store)**: push di un tag `v1.0.0+N` (N = build number in `pubspec.yaml`);
  `.github/workflows/release.yml` builda l'AAB firmato e lo carica sul track alpha.
