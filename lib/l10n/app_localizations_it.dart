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
  String get lastBusBadge => 'Ultimo bus della notte';

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
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar) {
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
  String get subscription => 'Abbonamento';

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
      'Le tessere della mappa sono fornite da OpenStreetMap (tile.openstreetmap.org). Non vengono trasmessi dati personali in queste richieste.';

  @override
  String get privacyViewOnline => 'Vedi informativa completa online';
}
