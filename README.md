# Reus ↔ Tarragona Bus

App Flutter (pensata per Web, Android e iOS dallo stesso codice) per pianificare un viaggio
sulla linea e4 Monbus tra Reus e Tarragona: scegli fermata di partenza e di arrivo, data e ora
(partenza minima oppure arrivo entro), e l'app indica subito quale bus prendere. Include anche
una mappa con tutte le fermate della linea.

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
- `lib/screens/map_screen.dart` — mappa (OpenStreetMap via `flutter_map`) con le fermate.

## Stack tecnico

Flutter + Material 3, `flutter_map`/`latlong2` per la mappa (OpenStreetMap, nessuna API key
richiesta), `intl` per la formattazione di date/orari in italiano. Nessun backend: tutti i dati
sono statici negli asset JSON dell'app.
