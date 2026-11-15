// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'ErasBus Tarragona';

  @override
  String get lineSubtitle => 'Linea e4 · Monbus';

  @override
  String get mapTooltip => 'Mappa fermate';

  @override
  String get settingsTooltip => 'Impostazioni';

  @override
  String get departureLabel => 'Partenza';

  @override
  String get arrivalLabel => 'Arrivo';

  @override
  String get chooseDifferentStops => 'Scegli due fermate diverse.';

  @override
  String get inFavorites => 'Nei preferiti';

  @override
  String get saveAsFavorite => 'Salva come preferita';

  @override
  String get whenTravel => 'Quando vuoi viaggiare?';

  @override
  String get departAfter => 'Parto dopo le';

  @override
  String get arriveBy => 'Arrivo entro le';

  @override
  String get holidaySwitch => 'Festivo (usa orario domenicale)';

  @override
  String get nightServiceSwitch => 'Servizio notturno';

  @override
  String calendarApplied(Object label) {
    return 'Calendario applicato: $label';
  }

  @override
  String get findBus => 'Trova il bus';

  @override
  String get goButton => 'Vai';

  @override
  String get selectStop => 'Seleziona fermata';

  @override
  String get searchStopOrCity => 'Cerca fermata o città…';

  @override
  String get noOtherBusToday => 'Nessun altro bus oggi per questa tratta';

  @override
  String get nextBusArriving => 'in arrivo';

  @override
  String nextBusInMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'tra $minutes min',
      one: 'tra 1 min',
    );
    return '$_temp0';
  }

  @override
  String nextBusInHours(Object hours) {
    return 'tra ${hours}h';
  }

  @override
  String nextBusInHoursMinutes(Object hours, Object minutes) {
    return 'tra ${hours}h $minutes min';
  }

  @override
  String thenAt(Object time) {
    return 'poi $time';
  }

  @override
  String subscriptionExpiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abbonamento scaduto da $days giorni',
      one: 'Abbonamento scaduto da 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String weatherRainingNow(Object place, int temp) {
    return 'Sta piovendo a $place, porta con te un ombrello! Ci sono $temp°';
  }

  @override
  String weatherMaybeRain(int temp) {
    return 'Potrebbe piovere, meglio se porti un ombrello per sicurezza. Ci sono $temp°';
  }

  @override
  String weatherMaybeRainIn(Object place, int temp) {
    return 'Potrebbe piovere a $place, meglio se porti un ombrello per sicurezza. Ci sono $temp°';
  }

  @override
  String weatherSunny(int temp) {
    return 'Goditi una splendida giornata di sole! Ci sono $temp°';
  }

  @override
  String get subscriptionExpiresToday => 'Abbonamento: scade oggi';

  @override
  String subscriptionExpiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abbonamento: scade tra $days giorni',
      one: 'Abbonamento: scade tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get lastBusBadge => 'Ultimo bus verso questa destinazione';

  @override
  String get tripInfoTitle => 'Info sul viaggio';

  @override
  String get payCashOnly =>
      'Biglietto a bordo: SOLO contanti, niente pagamento elettronico';

  @override
  String get recommendedBus => 'Bus consigliato';

  @override
  String get noDirectTrip => 'Nessuna corsa diretta';

  @override
  String noDirectTripMessage(Object origin, Object destination) {
    return 'Non esiste una corsa diretta da \"$origin\" a \"$destination\" su questa linea. Prova a invertire partenza e arrivo.';
  }

  @override
  String get noBusFound => 'Nessun bus trovato';

  @override
  String noBusFoundDepartMessage(Object calendar) {
    return 'Non ci sono più corse dopo questo orario per il calendario \"$calendar\". Prova un altro orario o giorno.';
  }

  @override
  String get noBusFoundArriveMessage =>
      'Non ci sono corse che arrivano in tempo. Prova un orario limite più tardo o un altro giorno.';

  @override
  String get viewRouteOnMap => 'Vedi il percorso sulla mappa';

  @override
  String get tripDetailsTitle => 'Dettagli viaggio';

  @override
  String get shareTooltip => 'Condividi';

  @override
  String get fromLabel => 'DA';

  @override
  String get toLabel => 'A';

  @override
  String get direct => 'Diretto';

  @override
  String stopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fermate',
      one: '1 fermata',
    );
    return '$_temp0';
  }

  @override
  String get routeOnMap => 'Percorso sulla mappa';

  @override
  String get stopsOfThisTrip => 'Fermate di questa corsa';

  @override
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  ) {
    return 'Bus $origin → $destination\nParti alle $dep, arrivi alle $arr ($minutes min) — $calendar.';
  }

  @override
  String get lineStopsTitle => 'Fermate della linea';

  @override
  String get calculatingRoute => 'Calcolo percorso su strada…';

  @override
  String get routeUnavailable =>
      'Percorso su strada non disponibile, mostro linee dirette';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get appearance => 'Aspetto';

  @override
  String get appearanceSubtitle =>
      'Chiaro, scuro o come da impostazioni del dispositivo.';

  @override
  String get light => 'Chiaro';

  @override
  String get dark => 'Scuro';

  @override
  String get system => 'Sistema';

  @override
  String get themeColor => 'Colore del tema';

  @override
  String get themeColorSubtitle => 'Scegli il colore principale dell\'app.';

  @override
  String get colorGreen => 'Verde Monbus';

  @override
  String get colorBlue => 'Blu';

  @override
  String get colorIndigo => 'Indaco';

  @override
  String get colorPurple => 'Viola';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorCoral => 'Rosso corallo';

  @override
  String get colorOrange => 'Arancione';

  @override
  String get colorAmber => 'Ambra';

  @override
  String get colorTeal => 'Turchese';

  @override
  String get colorPetrol => 'Blu petrolio';

  @override
  String get language => 'Lingua';

  @override
  String get languageSubtitle =>
      'Scegli la lingua dell\'app o segui quella del dispositivo.';

  @override
  String get languageSystem => 'Automatica';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get subscription => 'Abbonamento dei trasporti';

  @override
  String get subscriptionSubtitle =>
      'Registra il tuo abbonamento per ricordarti quando scade. Solo un promemoria: non è collegato a nessun sistema di biglietteria.';

  @override
  String get purchaseDate => 'Data di acquisto';

  @override
  String get duration => 'Durata';

  @override
  String get oneMonth => '1 mese';

  @override
  String get twoMonths => '2 mesi';

  @override
  String get threeMonths => '3 mesi';

  @override
  String get customDuration => 'Personalizzata';

  @override
  String get expiryDate => 'Data di scadenza';

  @override
  String get chooseDate => 'Scegli data';

  @override
  String get saveSubscription => 'Salva abbonamento';

  @override
  String get removeSubscription => 'Rimuovi abbonamento';

  @override
  String get chooseCustomExpiryWarning =>
      'Scegli una data di scadenza personalizzata.';

  @override
  String expiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Scaduto da $days giorni',
      one: 'Scaduto da 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Scade oggi';

  @override
  String expiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Scade tra $days giorni',
      one: 'Scade tra 1 giorno',
    );
    return '$_temp0';
  }

  @override
  String expiryLabel(Object date) {
    return 'Scadenza: $date';
  }

  @override
  String get calWeekday => 'Feriale (Lun-Ven)';

  @override
  String get calWeekdayAugust => 'Feriale (agosto)';

  @override
  String get calSaturday => 'Sabato';

  @override
  String get calSundayHoliday => 'Domenica / festivo';

  @override
  String get calNight => 'Servizio notturno';

  @override
  String get directionReusTarragona => 'Reus → Tarragona';

  @override
  String get directionTarragonaReus => 'Tarragona → Reus';

  @override
  String minutesAbbrev(Object minutes) {
    return '$minutes min';
  }

  @override
  String get loadError => 'Errore nel caricamento degli orari:';

  @override
  String get infoTitle => 'Informazioni';

  @override
  String get privacyPolicyTitle => 'Informativa sulla privacy';

  @override
  String get privacyPolicyP1 =>
      'L\'app non raccoglie né trasmette dati personali a server esterni.';

  @override
  String get privacyPolicyP2 =>
      'Le preferenze (tema, lingua) e i dati di abbonamento sono salvati solo sul tuo dispositivo tramite SharedPreferences e non vengono mai condivisi.';

  @override
  String get privacyPolicyP3 =>
      'L\'app non utilizza analytics, cookie di profilazione o servizi di tracciamento di terze parti.';

  @override
  String get privacyPolicyP4 =>
      'I dati di abbonamento vengono eliminati alla disinstallazione o tramite il pulsante «Rimuovi abbonamento» nelle impostazioni.';

  @override
  String get privacyPolicyContact =>
      'Per informazioni: lumestudio.app@gmail.com';

  @override
  String get copyright =>
      '© 2024–2026 Lume Labs App. Tutti i diritti riservati.';

  @override
  String get nightServiceSalou => 'Servizio notturno Salou';

  @override
  String get calNightSalou => 'Notturno Salou';

  @override
  String get calNightNt3 => 'NT3 Tarragona-Salou';

  @override
  String walkToPoiBanner(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min a piedi',
      one: '1 min a piedi',
    );
    return '$_temp0';
  }

  @override
  String walkFromStop(Object stop) {
    return 'Dalla fermata: $stop';
  }

  @override
  String get poiSectionTitle => 'LUOGHI';

  @override
  String get stopsSectionTitle => 'FERMATE';

  @override
  String get whereDoYouWantToGo => 'Dove vuoi andare?';

  @override
  String get titleDaylife => 'Dove andiamo oggi?';

  @override
  String get titleNightlife => 'Dove andiamo stanotte?';

  @override
  String get gpsDetecting => 'Rilevamento posizione…';

  @override
  String get change => 'Cambia';

  @override
  String get categoryUniversity => 'Università';

  @override
  String get categoryNightlife => 'Vita notturna';

  @override
  String get categoryAllStops => 'Tutte le fermate';

  @override
  String get gameSoundsTitle => 'Suoni dei giochi';

  @override
  String get gameSoundsSubtitle =>
      'Effetti sonori nei minigiochi (vittoria, mosse, esplosioni…). Spenti di base.';

  @override
  String get gameSoundsOff => 'Disattiva i suoni';

  @override
  String get gameSoundsOn => 'Attiva i suoni';

  @override
  String get tutorialSkip => 'Salta';

  @override
  String get tutorialNext => 'Avanti';

  @override
  String get tutorialDone => 'Fine';

  @override
  String get tutorialReview => 'Rivedi il tutorial';

  @override
  String get tutorialReviewSub => 'Una breve guida all\'uso dell\'app';

  @override
  String get tutorial1Title => 'Cerca la tua corsa';

  @override
  String get tutorial1Text =>
      'Qui trovi la partenza (di solito la rileva il GPS) e qui l\'arrivo: tocca per scegliere. Poi premi «Vai» per vedere i bus.';

  @override
  String get tutorial2Title => 'Corse rapide';

  @override
  String get tutorial2Text =>
      'Imposta casa e fermata abituale per partire con un tocco. Dopo una ricerca, tocca la stella ★ nel dettaglio della corsa per salvarla tra i preferiti.';

  @override
  String get tutorial3Title => 'Spezza l\'attesa';

  @override
  String get tutorial3Text =>
      'In attesa del bus? Qui trovi tanti minigiochi per passare il tempo.';

  @override
  String get tutorial4Title => 'Scrivici';

  @override
  String get tutorial4Text =>
      'Se vuoi richiedere una funzionalità o segnalare un bug, scrivici da Impostazioni → Informazioni → Contattaci.';

  @override
  String get locationTitle => 'Posizione';

  @override
  String get locationSubtitle =>
      'Usa il GPS per trovare automaticamente la fermata più vicina.';

  @override
  String get locationEnabled => 'Rilevamento posizione GPS';

  @override
  String get locationEnabledSubtitle =>
      'La posizione viene usata solo localmente, non viene mai trasmessa.';

  @override
  String get locationPermissionDenied =>
      'Permesso posizione negato. Abilitalo dalle impostazioni del dispositivo.';

  @override
  String get privacySection1Title => 'Raccolta dati';

  @override
  String get privacySection2Title => 'Posizione GPS';

  @override
  String get privacySection3Title => 'Analytics e tracciamento';

  @override
  String get privacySection4Title => 'Mappe e servizi esterni';

  @override
  String get privacyPolicyP2loc =>
      'L\'app può richiedere l\'accesso alla posizione GPS per suggerire la fermata più vicina. La posizione viene elaborata solo sul dispositivo e non viene mai trasmessa. Il permesso è opzionale e può essere disattivato dalle Impostazioni.';

  @override
  String get privacyPolicyP4osm =>
      'Le tessere della mappa sono fornite da OpenStreetMap (tile.openstreetmap.org). Non vengono trasmessi dati personali in queste richieste. Il meteo è fornito da Open-Meteo (api.open-meteo.com): la richiesta contiene le coordinate della fermata e, come per ogni connessione, l\'indirizzo IP; non contiene altri dati personali.';

  @override
  String get privacyViewOnline => 'Vedi informativa completa online';

  @override
  String recommendedStopTitle(Object stop) {
    return 'Fermata consigliata: $stop';
  }

  @override
  String get recommendedStopNote =>
      'Il bus si ferma qui anche se non compare nel percorso ufficiale. L\'orario è quello di Plaça Europa e può differire di qualche minuto.';

  @override
  String get nightMapsNote =>
      'Le corse notturne non sono su Google Maps: il percorso mostrato potrebbe essere diverso.';

  @override
  String get alightAt => 'Scendi a:';

  @override
  String get alightHere => 'Scendi qui';

  @override
  String get recommendedLabel => 'consigliata';

  @override
  String get supportTitle => 'Supporta lo sviluppatore';

  @override
  String get supportSubtitle =>
      'L\'app è gratuita. Se ti è utile, puoi aiutarmi a mantenerla.';

  @override
  String get watchAdButton =>
      'Supporta lo sviluppatore guardando una pubblicità';

  @override
  String get adNotReady =>
      'Pubblicità non ancora pronta, riprova tra qualche secondo.';

  @override
  String get adThanks => 'Grazie per il supporto! 💚';

  @override
  String get removeAdsTitle => 'Rimuovi la pubblicità';

  @override
  String removeAdsMonthly(Object price) {
    return '$price / mese';
  }

  @override
  String removeAdsYearly(Object price) {
    return '$price / anno';
  }

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get premiumActive => 'Grazie! Hai la versione senza pubblicità.';

  @override
  String get manageSubscription => 'Gestisci abbonamento';

  @override
  String get adPrivacyOptions => 'Opzioni privacy pubblicità';

  @override
  String get supportLinkButton => 'Supporta lo sviluppatore';

  @override
  String get subscriptionUnavailable =>
      'Abbonamento non disponibile al momento.';

  @override
  String get privacySection5Title => 'Pubblicità e acquisti';

  @override
  String get privacyPolicyP5 =>
      'Su Android l\'app mostra pubblicità tramite Google AdMob, che può usare l\'identificativo pubblicitario del dispositivo e dati simili per mostrare annunci; in Europa l\'uso avviene solo dopo il tuo consenso, modificabile dalle Impostazioni. L\'abbonamento «senza pubblicità» è gestito da Google Play: l\'app non riceve né conserva i tuoi dati di pagamento. Anche il sito web mostra un banner pubblicitario tramite Google AdSense (in Europa solo dopo il tuo consenso).';

  @override
  String get analyticsConsentText =>
      'Usiamo statistiche anonime (Google Analytics) per migliorare l\'app. Le accetti?';

  @override
  String get analyticsAccept => 'Accetta';

  @override
  String get analyticsReject => 'Rifiuta';

  @override
  String get analyticsSwitchTitle => 'Statistiche anonime';

  @override
  String get analyticsSwitchSubtitle =>
      'Ci aiutano a migliorare l\'app (Google Analytics).';

  @override
  String get privacySection6Title => 'Statistiche e diagnostica';

  @override
  String get privacyPolicyP6 =>
      'Con il tuo consenso usiamo Google Analytics (Firebase) per statistiche anonime di utilizzo, ad esempio quali ricerche vengono fatte e quali funzioni sono usate; puoi disattivarlo in qualsiasi momento dalle Impostazioni. Su Android usiamo anche Firebase Crashlytics, che invia rapporti tecnici sugli arresti dell\'app (tipo di dispositivo, versione di Android, errore) per correggerli. Non raccogliamo nome, e-mail o posizione.';

  @override
  String get privacyAndStats => 'Privacy e statistiche';

  @override
  String get notSet => 'Non impostato';

  @override
  String get settingOn => 'Attiva';

  @override
  String get settingOff => 'Disattivata';

  @override
  String get specialThemes => 'Temi speciali';

  @override
  String get specialThemesNote =>
      'Natale è sempre chiaro e Halloween sempre scuro: la modalità si blocca da sola.';

  @override
  String get supportBannerShort => 'Guarda un video o rimuovi la pubblicità';

  @override
  String get watchAdTitle => 'Guarda un video';

  @override
  String get supportVideoNote =>
      'Un modo per ringraziare: il video non rimuove la pubblicità.';

  @override
  String get supportAdFreeNote =>
      'Con l\'abbonamento il banner pubblicitario sparisce. Scegli mensile o annuale.';

  @override
  String get subscriptionTerms =>
      'L\'abbonamento si rinnova automaticamente fino a quando non lo annulli da Google Play.';

  @override
  String get bestValue => 'Più conveniente';

  @override
  String get myPlacesTitle => 'I miei posti';

  @override
  String get myPlacesSubtitle =>
      'Imposta Casa e la tua fermata abituale (di solito vicino all\'università): avrai le corse con un tocco dalla home.';

  @override
  String get homeStopLabel => 'Casa';

  @override
  String get usualStopLabel => 'Fermata abituale';

  @override
  String get chooseStop => 'Scegli una fermata';

  @override
  String get clearPlace => 'Rimuovi';

  @override
  String get backHome => 'Torna a casa';

  @override
  String get goToUsual => 'Alla fermata abituale';

  @override
  String get configureMyRoutes => 'Configura le tue corse abituali';

  @override
  String get configureMyRoutesSub =>
      'Imposta Casa e fermata abituale per avere le corse con un tocco';

  @override
  String get usefulInfoTitle => 'Info utili';

  @override
  String get infoSecUniversity => 'Università';

  @override
  String get infoSecTransport => 'Trasporti';

  @override
  String get infoSecCities => 'Città';

  @override
  String get infoDisclaimer =>
      'Link a siti esterni. Orari, prezzi e contatti possono cambiare: verifica sempre le fonti ufficiali.';

  @override
  String get linkUrv => 'URV · Studenti internazionali';

  @override
  String get linkUrvSub => 'Accoglienza, corsi e documenti per chi arriva';

  @override
  String get linkMonbus => 'Monbus';

  @override
  String get linkMonbusSub => 'Orari e informazioni ufficiali del servizio';

  @override
  String get linkBusplana => 'Busplana';

  @override
  String get linkBusplanaSub => 'Orari e informazioni dei bus Plana';

  @override
  String get linkTarragona => 'Ajuntament de Tarragona';

  @override
  String get linkReus => 'Ajuntament de Reus';

  @override
  String get linkSalou => 'Ajuntament de Salou';

  @override
  String get linkTurisme => 'Tarragona Turisme';

  @override
  String get arcadeButton => 'Spezza l\'attesa';

  @override
  String get arcadeNew => 'Nuovo!';

  @override
  String get arcadeMostPlayed => 'Più giocati!';

  @override
  String get arcadeFavAdd => 'Aggiungi ai preferiti';

  @override
  String get arcadeFavRemove => 'Rimuovi dai preferiti';

  @override
  String get arcadeRecords => 'Record raggiunti';

  @override
  String get arcadeTitle => 'Spezza l\'attesa';

  @override
  String get arcadeSubtitle => 'Gioca ai minigiochi di ErasBus Tarragona';

  @override
  String get gameTicTacToe => 'Tris';

  @override
  String get gameBattleship => 'Battaglia navale';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameMaze => 'Labirinto';

  @override
  String get gameBusJam => 'Bus e minibus';

  @override
  String get gameTicTacToeDesc => 'Sfida il telefono';

  @override
  String get gameBattleshipDesc => 'Affonda la flotta nemica';

  @override
  String get gameSudokuDesc => 'Completa la griglia';

  @override
  String get gameMazeDesc => 'Trova l\'uscita';

  @override
  String get gameBusJamDesc => 'Fai uscire il bus rosso';

  @override
  String get difficultyEasy => 'Facile';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difficile';

  @override
  String get gameNew => 'Nuova partita';

  @override
  String get gameYouWin => 'Hai vinto!';

  @override
  String get gameYouLose => 'Hai perso';

  @override
  String get gameDraw => 'Pareggio';

  @override
  String get gameYourTurn => 'Tocca a te';

  @override
  String get gameThinking => 'Il telefono pensa…';

  @override
  String get gameNoRecord => 'Nessun record';

  @override
  String get gameSolved => 'Risolto!';

  @override
  String get gameClear => 'Cancella';

  @override
  String get gameRestart => 'Ricomincia';

  @override
  String get gameNextLevel => 'Livello successivo';

  @override
  String get gameLevelDone => 'Livello completato!';

  @override
  String get gameMazeHint =>
      'Scorri sul labirinto o usa le frecce fino alla bandiera';

  @override
  String get gameBusJamHint =>
      'Trascina i mezzi per liberare la strada al bus rosso';

  @override
  String get gameBattleshipHint => 'Tocca il mare nemico per sparare';

  @override
  String get gameEnemySea => 'Mare nemico';

  @override
  String get gameYourSea => 'Il tuo mare';

  @override
  String get gameHit => 'Colpito!';

  @override
  String get gameMiss => 'Acqua';

  @override
  String get gameSunk => 'Affondata!';

  @override
  String gameBest(Object value) {
    return 'Record: $value';
  }

  @override
  String gameBestMoves(int n) {
    return 'Record: $n mosse';
  }

  @override
  String gameMoves(int n) {
    return 'Mosse: $n';
  }

  @override
  String gameLevel(int n) {
    return 'Livello $n';
  }

  @override
  String get gamePlaceShips =>
      'Posiziona le tue navi: tocca la griglia per piazzare la prossima nave. Tocca una nave per rimuoverla.';

  @override
  String get gameRotate => 'Ruota';

  @override
  String get gameHorizontal => 'Orizzontale';

  @override
  String get gameVertical => 'Verticale';

  @override
  String get gameRandom => 'Casuale';

  @override
  String get gameStart => 'Inizia';

  @override
  String get gameShipNoFit => 'Qui la nave non ci sta';

  @override
  String get gameFire => 'Tocca a te: spara!';

  @override
  String get gameEnemyTurn => 'Turno dell\'avversario…';

  @override
  String get gameYou => 'Tu';

  @override
  String get gameOpponent => 'Avversario';

  @override
  String get widgetInPrefix => 'tra';

  @override
  String get widgetMinSuffix => 'min';

  @override
  String get widgetNoTrips => 'Nessuna corsa prevista';

  @override
  String get widgetHint =>
      'Puoi aggiungere il widget «ErasBus» alla schermata Home del telefono: tieni premuto sullo sfondo → Widget. Mostra le prossime corse per Casa e fermata abituale.';

  @override
  String get contactTitle => 'Contattaci';

  @override
  String get contactText =>
      'Hai una richiesta per una nuova funzione o vuoi segnalare un bug? Scrivici una mail:';

  @override
  String get rateApp => 'Valuta l\'app';

  @override
  String get shipCarrier => 'Portaerei (4)';

  @override
  String get shipDestroyer => 'Cacciatorpediniere (3)';

  @override
  String get shipPatrol => 'Motovedetta (2)';

  @override
  String get gamePlay => 'Gioca';

  @override
  String get gameDifficulty => 'Difficoltà';

  @override
  String get gameTicTacToeHow =>
      'Allinea tre simboli in riga, colonna o diagonale prima del telefono. Tu giochi con la X e inizi per primo.';

  @override
  String get gameBattleshipHow =>
      'Posiziona la tua flotta (una portaerei, due cacciatorpediniere, due motovedette) e affonda quella nemica prima che il telefono affondi la tua. La difficoltà cambia quanto è astuto il telefono.';

  @override
  String get gameSudokuHow =>
      'Riempi la griglia con i numeri da 1 a 9 senza ripeterli su righe, colonne e riquadri 3×3. Più è difficile, meno numeri trovi già scritti.';

  @override
  String get gameMazeHow =>
      'Guida il bus dalla partenza alla bandiera. Il labirinto è sempre diverso e più è difficile, più è grande.';

  @override
  String get gameBusJamHow =>
      'Fai scorrere bus e minibus per liberare la strada e portare il bus rosso fuori dal parcheggio. Ogni difficoltà ha 10 livelli da sbloccare uno dopo l\'altro: meno mosse fai, meglio è.';

  @override
  String get gameBlocks => 'Blocchi 1010';

  @override
  String get game2048 => '2048';

  @override
  String get gameMemory => 'Memory';

  @override
  String get gameWordle => 'Parola del giorno';

  @override
  String get gameFlow => 'Collega i punti';

  @override
  String get gameBlocksDesc => 'Completa righe e colonne';

  @override
  String get game2048Desc => 'Unisci i numeri uguali';

  @override
  String get gameMemoryDesc => 'Trova tutte le coppie';

  @override
  String get gameWordleDesc => 'Una nuova parola ogni giorno';

  @override
  String get gameFlowDesc => 'Unisci i colori senza incroci';

  @override
  String get gameBlocksHow =>
      'Trascina i pezzi sulla griglia 10×10: ogni riga o colonna completa si svuota. Più linee svuoti insieme, più punti fai. La partita finisce quando nessun pezzo entra più. Facile: pezzi piccoli; difficile: pezzi più grandi.';

  @override
  String get game2048How =>
      'Scorri per spostare tutte le tessere: quelle con lo stesso numero si uniscono e raddoppiano. Arriva a 2048! Difficoltà: facile 5×5, medio 4×4, difficile 3×3.';

  @override
  String get gameMemoryHow =>
      'Gira due carte alla volta e trova tutte le coppie nel minor tempo e con meno mosse. Facile: 6 coppie; medio: 8; difficile: 12.';

  @override
  String get gameWordleHow =>
      'Indovina la parola di 5 lettere in 6 tentativi: scrivila e premi INVIO per vedere i colori. Verde: lettera giusta al posto giusto; giallo: lettera presente ma altrove; grigio: assente. La parola è la stessa per tutti e cambia ogni giorno, nella lingua dell\'app.';

  @override
  String get gameArrows => 'Frecce';

  @override
  String get gameArrowsHow =>
      'Tocca le frecce per spostarle fuori dal tabellone, ma attento: il loro percorso deve essere libero. Alcune frecce bloccano altre frecce, perciò scegli l\'ordine giusto per completare ogni livello. Hai 3 vite: ogni freccia bloccata che tocchi ne toglie una. Difficoltà: tabellone più grande e più frecce.';

  @override
  String get gameArrowsHint => 'Tocca una freccia che ha la strada libera';

  @override
  String gameArrowsLeft(int n) {
    return 'Frecce: $n';
  }

  @override
  String wordleAttempts(int n) {
    return '$n tentativi';
  }

  @override
  String get gameFlowHow =>
      'Unisci con una linea ogni coppia di punti dello stesso colore, senza incroci. C\'è una sola soluzione, e riempie tutti i riquadri. Difficoltà: più grande e più colori.';

  @override
  String get gameBlocksHint => 'Trascina un pezzo sulla griglia';

  @override
  String get game2048Hint => 'Scorri in una direzione';

  @override
  String get gameMemoryHint => 'Tocca due carte per girarle';

  @override
  String get gameWordleHint => 'Scrivi una parola di 5 lettere e premi INVIO';

  @override
  String get gameFlowHint =>
      'Trascina da un punto all\'altro dello stesso colore';

  @override
  String get gameOver => 'Partita finita';

  @override
  String get gamePerfect => 'Perfetto!';

  @override
  String get wordleToday => 'Parola di oggi';

  @override
  String get wordleNotEnough => 'Servono 5 lettere';

  @override
  String get wordleComeBack => 'Torna domani per una nuova parola!';

  @override
  String get wordleShare => 'Condividi il risultato';

  @override
  String get wordlePractice => 'Parola casuale';

  @override
  String gameScore(int n) {
    return 'Punti: $n';
  }

  @override
  String gameBestScore(int n) {
    return 'Record: $n';
  }

  @override
  String wordleAnswer(Object word) {
    return 'La parola era $word';
  }

  @override
  String get gameBackAgain => 'Scorri di nuovo indietro per uscire';

  @override
  String get wordlePressEnter => 'Premi INVIO per confermare';

  @override
  String get wordleEnter => 'INVIO';

  @override
  String get gameFlowFillAll => 'Coppie unite! Ora riempi tutti i riquadri';

  @override
  String get gameSnake => 'Snake';

  @override
  String get gameMines => 'Campo minato';

  @override
  String get gameChess => 'Scacchi';

  @override
  String get gameChessHow =>
      'Gioca con i bianchi contro il telefono. Tocca un pezzo e poi la casella dove spostarlo: le mosse possibili si illuminano. Vale tutto: arrocco, presa al varco e promozione. Vince chi dà scacco matto. Più sale il livello, più il telefono pensa in anticipo.';

  @override
  String get gameCheckers => 'Dama';

  @override
  String get gameCheckersHow =>
      'Dama italiana: tu hai le pedine chiare, in basso. Le pedine vanno in avanti in diagonale e mangiano saltando un pezzo avversario; la presa è obbligatoria e va scelta quella che ne porta via di più. La pedina non può mangiare la dama. Arrivata in fondo, diventa dama. Vince chi blocca o mangia tutto.';

  @override
  String get gameCheck => 'Scacco!';

  @override
  String get gameStalemate => 'Stallo: pareggio';

  @override
  String get gamePromote => 'Scegli il pezzo';

  @override
  String get gameMustCapture => 'Presa obbligatoria!';

  @override
  String gameWins(int n) {
    return 'Vittorie: $n';
  }

  @override
  String get gameSolitaire => 'Solitario';

  @override
  String get gameSlide => 'Puzzle scorrevole';

  @override
  String get gameConnections => 'Connessioni';

  @override
  String get gameFlappy => 'Bus volante';

  @override
  String get gameQuiz => 'Quiz Catalunya';

  @override
  String get gameSnakeHow =>
      'Guida il bus con uno swipe (o con le frecce) e mangia le fermate per allungarti, senza toccare te stesso. Facile: i bordi sono aperti; medio e difficile: i muri bloccano e si va più veloci.';

  @override
  String get gameMinesHow =>
      'Scopri tutti i riquadri senza mine. I numeri dicono quante mine ci sono intorno. Tocco lungo (o modalità bandiera) per segnare una mina. Il primo tocco è sempre sicuro. Più è difficile, più mine ci sono.';

  @override
  String get gameSolitaireHow =>
      'Solitario Klondike: porta tutte le carte nelle quattro fondazioni, dall’asso al re, per seme. Sulle colonne si impilano carte a scalare di colore alternato. Tocca una carta e poi dove metterla; un secondo tocco la manda alla fondazione.';

  @override
  String get gameSlideHow =>
      'Fai scorrere le tessere per rimetterle in ordine da 1 in poi, con lo spazio vuoto in fondo. Facile 3×3, medio 4×4, difficile 5×5.';

  @override
  String get gameConnectionsHow =>
      'Ci sono 16 parole su Tarragona, Catalogna e Spagna: raggruppale in 4 gruppi da 4 con qualcosa in comune. Hai 4 errori a disposizione.';

  @override
  String get gameFlappyHow =>
      'Tocca lo schermo per far saltare il bus e passa tra i palazzi senza toccarli. Più è difficile, più vai veloce e più stretti sono i passaggi.';

  @override
  String get gameQuizHow =>
      '10 domande mescolate su Tarragona, Santa Tecla, Spagna e Catalogna. Scegli la risposta giusta tra quattro.';

  @override
  String get gameSnakeHint => 'Scorri per partire e cambiare direzione';

  @override
  String get gameMinesHint => 'Tocca per scoprire, tocco lungo per la bandiera';

  @override
  String get gameSolitaireHint => 'Tocca una carta e poi dove metterla';

  @override
  String get gameSlideHint => 'Tocca una tessera accanto allo spazio vuoto';

  @override
  String get gameConnectionsHint => 'Seleziona 4 parole dello stesso gruppo';

  @override
  String get gameFlappyHint => 'Tocca per saltare';

  @override
  String get gameMinesDig => 'Scopri';

  @override
  String get gameMinesFlag => 'Bandiera';

  @override
  String get quizCatTarragona => 'Tarragona';

  @override
  String get quizCatSantaTecla => 'Santa Tecla';

  @override
  String get quizCatSpain => 'Spagna';

  @override
  String get quizCatCatalonia => 'Catalogna';

  @override
  String quizScore(int score, int total) {
    return '$score su $total';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Domanda $n di $total';
  }

  @override
  String get quizNext => 'Avanti';

  @override
  String get quizFinish => 'Vedi il risultato';

  @override
  String get connMistakes => 'Errori';

  @override
  String connSolvedCount(int n) {
    return 'Risolti: $n';
  }

  @override
  String get connOneAway => 'Ci sei quasi: ne manca una!';

  @override
  String get connSubmit => 'Conferma';

  @override
  String get connShuffle => 'Mescola';

  @override
  String get rewardedArrowsMessage =>
      'Guarda una breve pubblicità per ottenere una vita e continuare il livello.';

  @override
  String get rewardedArrowsButton => 'Ottieni una vita';

  @override
  String get rewardedReviveTitle => 'Vuoi recuperare la partita?';

  @override
  String get rewardedReviveMessage =>
      'Guarda una breve pubblicità per continuare da dove eri rimasto, tenendo il punteggio.';

  @override
  String get rewardedBlocksMessage =>
      'Guarda una breve pubblicità: il tavolo di gioco viene svuotato e tieni il punteggio.';

  @override
  String get rewardedReviveButton => 'Recupera la partita';

  @override
  String get rewardedClearButton => 'Svuota il tavolo e continua';

  @override
  String get rewardedSkipTitle => 'Vuoi saltare il livello?';

  @override
  String get rewardedSkipMessage =>
      'Guarda una breve pubblicità per saltare il livello.';

  @override
  String get rewardedSkipButton => 'Salta il livello';

  @override
  String get rewardedPeekTitle => 'Vuoi vedere tutte le carte?';

  @override
  String get rewardedPeekMessage =>
      'Guarda una breve pubblicità: le carte restano scoperte per qualche secondo.';

  @override
  String get rewardedPeekButton => 'Mostra tutte le carte';

  @override
  String get rewardedUndoTitle => 'Vuoi annullare le ultime mosse?';

  @override
  String get rewardedUndoMessage =>
      'Guarda una breve pubblicità per annullare le ultime 3 mosse.';

  @override
  String get rewardedUndoButton => 'Annulla 3 mosse';

  @override
  String get rewardedWatch => 'Guarda la pubblicità';

  @override
  String get rewardedContinue => 'Continua';

  @override
  String get rewardedNo => 'No, grazie';

  @override
  String get rewardedFreeNote => 'Puoi farlo subito, senza pubblicità.';

  @override
  String get gameSkipped => 'Livello saltato';
}
