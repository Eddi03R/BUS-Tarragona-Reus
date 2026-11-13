# HANDOFF — ErasBus Tarragona (aggiornato al 2026-11-13, versione 1.0.0+63)

Documento per iniziare una nuova sessione senza perdere il contesto. **Sezione 4 = tema giochi (il più recente e voluminoso).**

---

## 0. RIPARTENZA RAPIDA (leggi questo per primo)

**Regole dell'utente (valgono sempre):**
1. Parla **italiano**; risposte concise, lavoro diretto e minimale.
2. **Pubblica SOLO quando lo dice lui** ("Pubblica sito" = solo web; "Pubblica entrambi"/"pubblica sito e app" = web + Android). Mai fare deploy di iniziativa. Se dice "quando finito avvisami con *fatto* e pubblica", prima verifica (Tests + Build Check verdi), poi pubblica, poi scrivi "fatto".
3. Non vuole usare il terminale: tutto passa da GitHub Actions + richieste a Claude.
4. Chiede idee/mockup **prima** di grafiche importanti (artifact HTML).
5. Branch: si lavora sul branch assegnato dalla sessione (es. `ccr-…`), poi merge/fast-forward su `master` solo al rilascio. **Nessuna PR** se non richiesta. I tag non si possono pushare da qui: lo crea il workflow.
6. Ogni nuova stringa UI va in **tutti e 5 gli .arb** (it template, en, es, ca, de).
7. Commit con le righe di attribuzione richieste dalla sessione; nessun nome del modello nei file del repo.

**Come rilasciare (dopo ok esplicito dell'utente):**
1. Su branch: lanciare `tests.yml` e `build-check.yml` (`actions_run_trigger` → `run_workflow`, ref = branch); leggere l'esito con `actions_list`/`actions_get`, log con `get_job_logs` (tail_lines; cercare le righe `error •`).
2. Se verdi: merge del branch su `master` e push (`git fetch origin master; git checkout master; git merge <branch>; git push origin master`; poi tornare al branch).
3. Lanciare `deploy-web.yml` su `master` con input `{"android": true}` per sito + Android (Play, track alpha), `false` per solo sito. Il workflow fa bump versione, build, push su `master` e `gh-pages` (Cloudflare serve gh-pages), e con android crea il tag che avvia `release.yml`.
4. Controllare l'esito dei run e avvisare l'utente (cosa provare su telefono).

**Verificare in locale senza aspettare la CI (trucco, ~2 min):** nel container non c'è Flutter, ma si scarica: `curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.38.10-stable.tar.xz` (≈1,4 GB) in `/tmp/fl`, `tar xf`, `export PATH=/tmp/fl/flutter/bin:$PATH CI=true`, poi `flutter pub get`, `flutter analyze lib`, `flutter test`, `flutter build web --release`. (Android non compila qui: serve `build-check.yml`.) Dopo `pub get` fare `git checkout pubspec.lock` prima di committare (il lock cambia per versioni diverse di Flutter e il deploy lo scarta comunque). CanvasKit non si scarica nel sandbox, quindi niente test browser reali.

## 0b. SUONI DEI GIOCHI (aggiunti 2026-11-13, v64+)

- Richiesta utente: opzione **C** completa (vittoria/sconfitta ovunque + suoni specifici per gioco + tocco/mossa), **spenti di base**, interruttore sia nell'elenco giochi (icona altoparlante nella AppBar di `ArcadeScreen`) sia in Impostazioni → "Suoni dei giochi" (`GameSoundsScreen`). Il "trombone triste" è una versione originale (Sib3-La3-Lab3-Sol3, "wah wah wah waaah"), non una registrazione famosa. Tutti i suoni sono sintetizzati da zero (nessun problema di diritti).
- `lib/services/game_sound.dart`: `GameSound.instance` (ChangeNotifier, pref `game_sounds_on`, default false, caricato in `main.dart`), enum `Sfx` (20 effetti), `play(sfx, delay:)`. Plugin `audioplayers ^6.1.0`; asset in `assets/sounds/*.wav` (WAV 22 kHz mono, ~400 KB totali), generati da `tools/gen_sounds.py` (`python3 tools/gen_sounds.py`, serve numpy) — per ritoccare un suono si modifica lì e si rigenera. Ogni errore audio è ignorato (try/catch); spento = il plugin non viene mai toccato. Mix con la musica dell'utente (niente audio focus).
- Esito: `ResultBanner` (game_common.dart) è ora StatefulWidget e suona win/lose/draw con 350 ms di ritardo → copre tutti i giochi, anche i futuri. Gli altri suoni sono chiamate `GameSound.instance.play(Sfx.xxx)` nelle schermate (place/capture scacchi-dama, flip memory/solitario, pop 2048, clear blocchi, splash/explosion battaglia navale, eat snake, flap/ding/thud flappy, flag/explosion campo minato, correct/wrong quiz-connections-sudoku-wordle, ecc.).
- Test: `test/game_sound_test.dart` (mock del canale audio). Non verificabile da Claude l'ascolto: l'utente giudica il risultato e si ritoccano i suoni a richiesta.
- Il gioco "Parola/giochi" ora sono **19** (oltre ai 10 originali: Quiz, Snake, Flappy, Campo minato, Slide, Connections, Solitario, Dama, Scacchi, ecc. — vedi `arcade_screen.dart`).


## 1. Progetto in breve

- **App Flutter** (web + Android) che pianifica viaggi sulla linea Reus–Tarragona (Monbus/e4) per studenti Erasmus. Repo GitHub: `Eddi03R/BUS-Tarragona-Reus`, branch principale `master`.
- **Stack**: Flutter (CI usa lo stable più recente; il Mac dell'utente ha 3.38.10 / Dart 3.10.9), Material 3, `setState` + singleton `ChangeNotifier` (niente Riverpod/Provider/BLoC). Orari in JSON statici (`assets/data/`).
- **Localizzazione**: `lib/l10n/*.arb` (it è il template, poi en/es/ca/de). `app_localizations.dart` è generato da `flutter pub get` (gitignored). **Ogni nuova stringa va aggiunta in tutti e 5 gli .arb.**
- **Siti/app**: web su Cloudflare Pages (`bustarragonareus.pages.dev`, serve il branch `gh-pages` già buildato); Android `app.lumelabs.bustarragona` su Play Store (closed testing / alpha, poi produzione).
- **Account/servizi**: Play Console (individuale, Lume Labs App, `lumestudio.app@gmail.com`), AdMob (ID reali già nel codice), Firebase progetto `erasbus-tarragona-8a602` (Crashlytics + Analytics).

## 2. Come lavora l'utente (preferenze)

- Parla **italiano**. Vuole risposte concise, "ponytail/lazy mode" (nessuna skill con quel nome: significa lavorare in modo diretto e minimale).
- **Pubblica solo quando lo dice lui** ("Pubblica sito" / "Pubblica entrambi" = web + Android). Mai fare deploy di iniziativa.
- Vuole **non usare il terminale**: tutto passa da GitHub Actions + richieste a Claude.
- Chiede idee/mockup **prima** di realizzare grafiche importanti (si è fatto con artifact HTML).
- Regole branch della sessione: sviluppare su `claude/adoring-noether-0aer1w`, poi fast-forward/merge su `master` al momento del rilascio. Non creare PR se non richiesto. Non si possono pushare **tag** né cancellare branch da questo ambiente (il push dei tag è bloccato): il tag Android lo crea il workflow.
- Nel container cloud **non c'è Flutter**: si verifica solo con GitHub Actions (vedi sez. 3).

## 3. Workflow GitHub Actions (tutto manuale, via `workflow_dispatch`)

Si avviano con il tool GitHub MCP `actions_run_trigger` (`run_workflow`), poi si legge l'esito con `actions_list` / `actions_get`; per i log `get_job_logs` (usare `tail_lines`, il log è molto lungo: gli errori veri sono le righe `error •`).

| Workflow (file) | Cosa fa | Note |
|---|---|---|
| **Tests** (`tests.yml`) | `flutter test` (unit + widget smoke) + job `e2e` (build web + Playwright/Chromium con screenshot negli artifact) | Non pubblica nulla. Girare su branch `claude/adoring-noether-0aer1w`. |
| **Build Check** (`build-check.yml`) | `flutter analyze lib` (solo errori bloccano), `flutter build web`, `flutter build apk --release` | Non pubblica. Indispensabile dopo modifiche native/Gradle. ~8 min. |
| **Deploy Web (Cloudflare)** (`deploy-web.yml`) | Bump versione, build web, push su `master` e `gh-pages`; con input `android: true` crea anche il tag `v1.0.0+N` e avvia `release.yml` | Da `master`. `{"android": true}` per sito + Android, `false` solo sito. |
| **Android Release Build** (`release.yml`) | Build AAB firmato e upload su Play (track alpha) | Parte da solo da deploy-web con `android: true`. Usa i secrets del repo. |

Ritmo tipico: modifica su branch → `Tests` + `Build Check` → se verdi: `git checkout master && git pull && git merge origin/claude/adoring-noether-0aer1w && git push origin master` → `deploy-web.yml` su `master` → comunicare all'utente l'esito (e cosa provare su telefono).

Stato (storico): v1.0.0+48 era pubblicata; la versione corrente è nel `pubspec.yaml`. **Verifica sempre con `git log`/`pubspec.yaml` e con la lista dei run Actions quale versione è live.** Vecchia nota: v1.0.0+48 pubblicata (web su Cloudflare via gh-pages + Android su Play, entrambi riusciti il 2026-11-10). Il branch di lavoro è allineato a `master`.

## 4. TEMA GIOCHI ("Spezza l'attesa") — stato completo

### 4.1 Punti d'ingresso e struttura

- In **home** (sia scheda Daylife che Nightlife), in fondo: riquadro "Spezza l'attesa" + sottotitolo "Gioca ai minigiochi di ErasBus Tarragona" → `ArcadeScreen`.
- `lib/screens/arcade_screen.dart`: **Idea A** (scelta dall'utente) = griglia 2 colonne di **tessere quadrate grandi**, con il disegno del gioco sul gradiente del tema (`ThemedBanner.gradient()`: Natale = taglio rosso/verde con filo bianco, Halloween = arancio→nero, altri = sfumatura del colore) e il nome in una pillola scura in basso.
- Tocco su tessera → `lib/games/game_intro_screen.dart` (`GameIntroScreen(kind)`): copertina (stessa illustrazione), titolo, spiegazione breve, **slider difficoltà Facile/Medio/Difficile** (grande etichetta colorata verde/arancio/rosso; assente per la Parola del giorno), pulsante **Gioca** (+ "Livello n" per Bus e minibus). Le schermate di gioco **non hanno più i chip di difficoltà**: la difficoltà arriva dal costruttore (`difficulty:`).
- Ordine tessere: Bus e minibus, Sudoku, Labirinto, Battaglia navale, Tris, Blocchi 1010, 2048, Memory, Parola del giorno, Collega i punti.

### 4.2 File principali (tutti in `lib/games/`)

- `game_common.dart`: `Difficulty` (easy/medium/hard), `difficultyLabel`, `fmtTime`, **`GameStats`** (singleton, SharedPreferences, caricato in `main.dart`: `best(key)`/`submitBest` = record "più basso è meglio" (tempo/mosse); `high(key)`/`submitHigh` = "più alto è meglio" (punti); `value`/`setValue` generici), `GameButton` (pulsante coerente con l'app: larghezza piena, padding 16, raggio 16, testo 16 semibold; `primary` = ElevatedButton, altrimenti OutlinedButton), `ResultBanner` (vittoria con rimbalzo, sconfitta con "scossa", neutro), `StatusSlot` (altezza fissa 68: **serve a non spostare l'area di gioco quando compare il risultato**), `ConfettiOverlay` (+ vibrazione), `GameScaffold` (ListView senza overscroll "elastico"; parametri `physics` per bloccare lo scroll durante i trascinamenti e `celebrate` per i coriandoli).
- `game_art.dart`: `GameKind` (enum dei 10 giochi) e `GameArt` — illustrazioni disegnate a CustomPaint (una per gioco), usate in tessere e copertine.
- `logic/` (puro Dart, testato): `tictactoe_logic`, `maze_logic`, `sudoku_logic`, `battleship_logic`, `busjam_logic`, `block_logic`, `game2048_logic`, `memory_logic`, `wordle_logic` + `wordle_words.dart` (liste parole), `flow_logic`.
- Schermate: `tictactoe_screen`, `maze_screen`, `sudoku_screen`, `battleship_screen`, `busjam_screen`, `block_screen`, `game2048_screen`, `memory_screen`, `wordle_screen`, `flow_screen`.

### 4.3 Giochi e regole implementative

1. **Bus e minibus** (tipo Rush Hour). Griglia 6×6, mezzi da 2 (minibus) e 3 (bus) caselle, il bus rosso (id 0, riga 2) deve uscire a destra. `JamLogic.generate(level)` è **deterministico** (seed = livello) e risolvibile (BFS, minimo mosse); 30 livelli totali = **10 per difficoltà** (facile 1-10, medio 11-20, difficile 21-30), sbloccati in sequenza (`GameStats` chiave `busjam_unlocked_<diff>`; record `busjam_<livelloGlobale>`). Mezzi disegnati come autobus visti dall'alto (tetto, parabrezza, fari, ruote, striscia bianca sul rosso) con `_VehiclePainter`. **Gotcha risolto**: i trascinamenti verticali erano rubati dallo scroll della pagina → si usano gesti sull'asse del mezzo (`onHorizontalDrag*`/`onVerticalDrag*`) + `Listener` che blocca lo scroll mentre si tocca il campo.
2. **Sudoku**: generatore con unicità della soluzione (3 difficoltà = celle vuote 36/46/52), conflitti in rosso, tempo e record.
3. **Labirinto**: 3 dimensioni (facile 8×8, medio 14×14, difficile 22×22). Generazione casuale con **due algoritmi** (DFS e Prim), cella iniziale casuale, partenza/arrivo in angoli opposti casuali, e non si ripropone lo stesso labirinto di fila (`Maze.signature`). Il personaggio è il **bus del logo dell'app** (`assets/images/logo_bus.png`, copia dell'icona), animato con `AnimatedPositioned`. Controlli: swipe (con scroll bloccato) + frecce.
4. **Battaglia navale**: griglia 8×8, flotta = 1 portaerei (4), 2 cacciatorpediniere (3), 2 motovedette (2) con **navi disegnate** (`_ShipsPainter`). L'utente **posiziona le navi** (tocco, "Ruota", "Casuale", tocco su nave per rimuoverla, poi "Inizia"). Turni chiari con riquadro verde "Tocca a te: spara!" / arancione "Turno dell'avversario…". **Animazione del colpo** (`_ShotFxPainter`): missile con scia → esplosione se colpisce, spruzzo se manca. Mare nemico rosso chiaro, il proprio blu. IA del telefono con 3 livelli (facile: a caso; medio: insegue le navi colpite; difficile: scacchiera + inseguimento in linea).
5. **Tris**: 3 difficoltà (casuale / metà minimax / minimax = imbattibile), parte con **Facile**, linea vincente animata, segni con animazione "pop".
6. **Blocchi 1010**: griglia 10×10, 3 pezzi per volta, **trascinamento con `Listener`** (il pezzo segue il dito, offset sopra il dito, anteprima verde/rossa), righe/colonne complete si svuotano, punti con bonus combo, partita finita quando nessun pezzo entra. Difficoltà = set di pezzi (facile piccoli, difficile più grandi frequenti). Record a punti (`high`).
7. **2048**: swipe; difficoltà = dimensione (5×5 / 4×4 / 3×3); celebrazione a 2048 (si può continuare); record a punti.
8. **Memory**: 6/8/12 coppie (3/4/4 colonne), carte con flip 3D, tempo + mosse, record a tempo. Simboli = emoji.
9. **Parola del giorno** (stile Wordle): 6 tentativi, 5 lettere, **stessa parola per tutti nella stessa lingua** (`WordleLogic.dailyWord(lang, data)`: indice = giorni dal 2024-01-01, con permutazione deterministica per lingua). Stato del giorno salvato in SharedPreferences (`wordle_<lang>_<giorno>`). Condivisione risultato (share_plus), modalità "Parola casuale" di allenamento, tastiera su schermo + tastiera fisica. **Limiti noti**: accetta qualsiasi sequenza di 5 lettere (nessun dizionario di validazione); liste parole scritte a mano, senza accenti: it ~237, en ~461, es ~213, de ~133, ca ~101. Da rivedere (soprattutto catalano) in base ai feedback.
10. **Collega i punti** (Flow): 3 difficoltà = griglia 5×5/4 colori, 6×6/5, 7×7/6; puzzle generato da un cammino hamiltoniano casuale (mosse "backbite") tagliato in segmenti → sempre risolvibile e con copertura totale; "Perfetto!" se riempi tutta la griglia; record a tempo.

### 4.4 Cose da ricordare per toccare i giochi

- **Scroll vs drag**: ogni gioco con trascinamento/swipe usa `Listener` + stato `_locked` → `GameScaffold(physics: NeverScrollableScrollPhysics())` durante il tocco.
- **Layout shift**: messaggi/risultati vanno **sempre** dentro `StatusSlot` (altezza fissa), mai inseriti/rimossi come figli della lista.
- **Pulsanti**: usare solo `GameButton` (non `FilledButton` ecc.).
- **Test dei giochi**: `test/games_test.dart` (Tris, Labirinto incl. varietà, Sudoku, Battaglia navale incl. IA a 3 livelli e posizionamento, Bus e minibus) e `test/games2_test.dart` (Blocchi, 2048, Memory, Parola del giorno, Collega i punti). Nota: in Dart i `record` con liste dentro **non** si confrontano per valore (`expect((list, n), ...)` fallisce): destrutturare e confrontare a parte.
- **Tema Natale/Halloween**: le tessere e le copertine usano `ThemedBanner.gradient()`, quindi seguono il tema automaticamente.
- L'utente ha escluso "Petdoku" (ignorato) e sostituito "macchine da far uscire" con **Bus e minibus**.

### 4.5 Idee/backlog sui giochi (non ancora fatto)

- **Classifiche tra utenti** (richieste dall'utente): serve schema giornaliero uguale per tutti (seed = data) per sudoku/labirinto/bus; Firestore (già nel progetto Firebase) + accesso anonimo + nome utente scelto + filtro parolacce + **regole di sicurezza Firestore** (le scriviamo noi, girano sui server Google, nessun server da gestire: limitano chi scrive cosa e i valori plausibili; non provano che la partita sia onesta) + **App Check** (Play Integrity) per accettare solo l'app vera; eventuale Cloud Functions (piano Blaze) per verificare partite; aggiornare privacy policy e Data Safety in Play Console; moderazione nomi.
- Altri giochi suggeriti: solitario, ecc. Possibile "gioco/sfida del giorno" con serie di giorni.
- Eventuali miglioramenti: validazione dizionario per la Parola del giorno, più parole, musica/effetti sonori opzionali, hint/annulla in alcuni giochi, record per tutte le combinazioni mostrati nella pagina di avvio.

## 5. Resto dell'app (stato)

- **Temi**: colori standard + **Halloween** (sempre scuro) + **Natale** (sempre chiaro, rosso/verde con filo bianco, fiocchi e alberi). Con Halloween/Natale la modalità chiaro/scuro è bloccata. AppBar rossa a Natale con icone di stato bianche (`SystemUiOverlayStyle`); `AdsFrame` ha uno sfondo del tema sotto la navigazione (evita angoli neri col gesto "indietro").
- **Impostazioni (proposta B)**: menu corto con valori attuali e pagine dedicate: Aspetto, I miei posti, Lingua, Abbonamento dei trasporti (promemoria scadenza, non collegato a biglietteria), Posizione, Privacy e statistiche, Informazioni (versione, contatti `lumestudio.app@gmail.com`, "Valuta l'app"). Banner "Supporta lo sviluppatore" colorato col gradiente del tema.
- **I miei posti**: Casa + Fermata abituale → in home pulsanti "Torna a casa" / "Alla fermata abituale" (Daylife) e "Torna a casa" (Nightlife: parte dalla fermata di ritorno del locale scelto o dal GPS); banner "Configura le tue corse abituali" se non impostati.
- **Widget Android "Prossimo bus"** (Kotlin `NextBusWidgetProvider` + layout XML + canale `app.lumelabs.bustarragona/widget`): l'app scrive in SharedPreferences (`flutter.widget_data`) le corse delle prossime 72 ore per le due rotte (`lib/services/widget_sync.dart`), il widget le mostra anche ad app chiusa (aggiornamento via AlarmManager inesatto ~5 min / dopo ogni partenza). L'utente ha confermato che funziona.
- **Orari**: i **festivi della Catalogna** (fissi + Venerdì Santo/Lunedì di Pasqua) usano l'orario "domenica e festivi" (`CalendarResolver.isHoliday`). Feste **locali** (Reus/Tarragona/Salou) NON incluse (date non trovate/regola Monbus non nota; a Tarragona 2026: Sant Magí 19/8 e Santa Tecla 23/9). I dati hanno 2 refusi presenti nel PDF ufficiale Monbus (feriale RT corsa #102, TR corsa #57), segnati come noti nei test.
- **Preferiti**: due liste separate Daylife/Nightlife (con memoria del locale per mostrare la fermata consigliata).
- **Fermata consigliata**: per **Tropical Club** ed **Enjoy Salou (La Cage)** è "Av. de Pompeu Fabra - C. Carles Buïgas (La Cage)" (41.0701869, 1.1540123), non presente negli orari ufficiali (si mostra l'orario di Plaça Europa con "~"); "Flash Back Discothèque" (41.0769861, 1.1460503) usa Plaça Europa.
- **Pubblicità e abbonamento (solo Android)**: AdMob banner + video con ricompensa (non toglie la pubblicità), abbonamento Play `remove_ads` (mensile 0,99 € / annuale 5,99 €) per toglierla; consenso UMP; ID reali in `lib/config/ads_config.dart` e manifest. Modalità test pubblicità **rimossa**. Sul **sito** nessuna pubblicità (solo un link di supporto, vuoto finché non c'è l'URL in `AdsConfig.supportUrl`).
- **Firebase**: Crashlytics (solo Android) + Analytics (Android dopo consenso UMP; web con banner di consenso e interruttore in Impostazioni); `google-services.json` nel repo. **R8/minify disattivato** in release (WorkManager veniva rimosso → crash all'avvio).
- **Recensione**: finestra nativa Google Play (`in_app_review`, `lib/services/review_prompt.dart`): dopo ≥4 ricerche, ≥3 giorni dal primo avvio, max 1 volta ogni 120 giorni.
- **Info utili**: pagina con link a URV (studenti internazionali), Monbus (`https://www.monbus.es/es`), Ajuntament di Tarragona/Reus/Salou, Tarragona Turisme. **Manca il link ESN Tarragona** (non trovato un sito ufficiale; aggiungere quando l'utente lo manda).
- **Privacy policy pubblica**: `web/privacy.html` (finisce su GitHub Pages via gh-pages; la copia in-app è `PrivacyPolicyScreen`). Aggiornata per ads, abbonamento, Analytics/Crashlytics.

## 6. Cose in sospeso / decisioni aperte

1. **Fermata di ritorno da Flash Back (notte)**: nei dati notturni (NT2/NT3, da reusdigital.cat ed empresaplana.cat) Plaça Europa è solo fermata **di andata**; per tornare a Tarragona (NT3) il bus passa da Av. Andorra (H10 Salou Princess) e C/ Amposta, per Reus (NT2) la corsa parte da C/ Barcelona (Bar Bus). L'utente ha detto di **lasciar stare per ora** (potrebbe fermare davanti al locale senza essere negli orari, come La Cage).
2. **Link ESN Tarragona**: da aggiungere quando disponibile.
3. **Play Console**: sezione sicurezza dei dati / dichiarazioni (annunci, ID pubblicità, Analytics/diagnostica) già fatte dall'utente ("punto A e B" completati); verificare che la dichiarazione tenga conto di Analytics/Crashlytics e di eventuali classifiche future. Collegare l'app AdMob allo store solo quando sarà pubblica (completare "App da confermare" associando all'app esistente `…~6793885816`).
4. **Feste locali** nei festivi (vedi sopra) e **24/31 dicembre** (comportamento orari non noto).
5. **Classifiche giochi** (sez. 4.5) e **sito**: link di supporto (Ko-fi / Buy Me a Coffee) da mettere in `AdsConfig.supportUrl`.
6. Test su telefono da fare per le ultime novità dei giochi (non verificabili in CI): gesti di Blocchi 1010 e Collega i punti, aspetto di tessere/disegni/copertine, animazioni (coriandoli, missile/esplosione), Parola del giorno (qualità liste parole).

## 7. File e convenzioni utili

- `lib/main.dart`: bootstrap (Firebase, controller, `GameStats.load`, `MyPlacesController.load`, avvio widget sync, review).
- `lib/services/`: `ads_controller`, `analytics_service`, `calendar_resolver`, `journey_planner`, `favorites_controller`, `my_places_controller`, `widget_sync`, `review_prompt`, `theme_controller`, ecc.
- `lib/widgets/`: `themed_banner.dart` (gradiente tema + `ThemedBanner`), `christmas_decorations.dart` (+ `ChristmasBackdrop` usato in tutte le schermate), `ads_frame.dart`.
- `assets/data/`: `stops.json`, `poi.json` (locali + fermate consigliate), `timetable_*.json`. `assets/images/logo_bus.png`.
- Chiavi SharedPreferences principali: `app_seed_color`, `app_theme_mode`, `app_locale`, `favorite_routes`, `my_home_stop`, `my_usual_stop`, `widget_data`, `game_best_*`, `game_val_*`, `wordle_<lang>_<giorno>`, `analytics_choice`, `ads_premium`, `review_*`.
- Mockup/idee grafiche pubblicati come artifact (solo visione): Impostazioni (due proposte) e schermata giochi (due idee, scelta A).
- Documentazione repo: `README.md` (novità e deploy), `docs/idee-giochi.md` (idee giochi iniziali), questo `docs/HANDOFF.md`.
- Sicurezza: segreti (keystore, password, service account Play) sono nei **secrets GitHub** e non vanno copiati in repo o in chat. Le chiavi Firebase/AdMob nel codice sono identificativi pubblici di progetto.
