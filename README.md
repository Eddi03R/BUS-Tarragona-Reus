# Reus ↔ Tarragona Bus

App Flutter (pensata per Web, Android e iOS dallo stesso codice) per pianificare un viaggio
sulla linea e4 Monbus tra Reus e Tarragona: scegli fermata di partenza e di arrivo, data e ora
(partenza minima oppure arrivo entro), e l'app indica subito quale bus prendere. Include anche
una mappa con tutte le fermate della linea.

Dati orari estratti da:
`H_A3_Reus-Tarragona_13-11-2025_v1.pdf` (Monbus, v131125) — salvato in `schedule.pdf` in questa
cartella per riferimento.

## Come avviare il progetto

Serve Flutter SDK installato (`flutter --version`). Non era disponibile in questo ambiente,
quindi il progetto non è stato ancora compilato/testato automaticamente: va lanciato in locale.

```bash
flutter pub get
flutter run -d chrome     # per il web
flutter run                # per un emulatore/dispositivo Android o iOS collegato
```

Per pubblicare come app nativa in futuro:

```bash
flutter build apk          # Android
flutter build ios          # iOS (richiede macOS + Xcode)
flutter build web          # sito statico deployabile ovunque
```

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

## Limiti noti / cosa manca

1. **Orario di agosto**: il PDF ha un orario feriale leggermente diverso per il mese di agosto
   (pagina 3). Non incluso in questa v1: se serve, va aggiunto come nuovo file
   `timetable_weekday_august.json` con lo stesso schema di `timetable_weekday.json` e selezionato
   in `CalendarResolver` quando `date.month == 8`.
2. **Servizio notturno** (Reus ↔ Tarragona, tutte le notti, fermate diverse) non incluso: nel PDF
   è a pagina 3 ("Servei nocturn"). Stesso discorso: nuovo file JSON + nuove fermate in `stops.json`.
3. **Festività catalane**: l'app non conosce il calendario dei giorni festivi (es. Sant Jordi,
   Pasqua, ecc.). L'utente deve attivare manualmente l'interruttore "Festivo" in quei giorni.
4. **Coordinate delle fermate**: sono stime interpolate lungo il corridoio Reus–Tarragona a
   partire dai punti noti (stazioni bus, campus URV), non un rilievo GPS. Utili per farsi un'idea
   sulla mappa, ma da verificare/affinare (es. con Google Maps) prima di un uso in produzione.
5. Alcuni orari nel PDF originale contenevano valori palesemente incoerenti (minuti che tornano
   indietro all'interno della stessa corsa); sono stati corretti nei JSON per coerenza cronologica
   e sono segnalati nel campo `_note` dei file interessati.

## Stack tecnico

Flutter + Material 3, `flutter_map`/`latlong2` per la mappa (OpenStreetMap, nessuna API key
richiesta), `intl` per la formattazione di date/orari in italiano. Nessun backend: tutti i dati
sono statici negli asset JSON dell'app.
