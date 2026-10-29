// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get appTitle => 'ErasBus Tarragona';

  @override
  String get lineSubtitle => 'Línia e4 · Monbus';

  @override
  String get mapTooltip => 'Mapa de parades';

  @override
  String get settingsTooltip => 'Configuració';

  @override
  String get departureLabel => 'Sortida';

  @override
  String get arrivalLabel => 'Arribada';

  @override
  String get chooseDifferentStops => 'Tria dues parades diferents.';

  @override
  String get inFavorites => 'Als preferits';

  @override
  String get saveAsFavorite => 'Desa com a preferit';

  @override
  String get whenTravel => 'Quan vols viatjar?';

  @override
  String get departAfter => 'Surto després de les';

  @override
  String get arriveBy => 'Arribada abans de les';

  @override
  String get holidaySwitch => 'Festiu (horari de diumenge)';

  @override
  String get nightServiceSwitch => 'Servei nocturn';

  @override
  String calendarApplied(Object label) {
    return 'Calendari aplicat: $label';
  }

  @override
  String get findBus => 'Troba l\'autobús';

  @override
  String get selectStop => 'Selecciona una parada';

  @override
  String get searchStopOrCity => 'Cerca parada o ciutat…';

  @override
  String get noOtherBusToday =>
      'Avui no hi ha més autobusos per aquest trajecte';

  @override
  String get nextBusArriving => 'arribant';

  @override
  String nextBusInMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'd\'aquí a $minutes min',
      one: 'd\'aquí a 1 min',
    );
    return '$_temp0';
  }

  @override
  String nextBusInHours(Object hours) {
    return 'd\'aquí a ${hours}h';
  }

  @override
  String nextBusInHoursMinutes(Object hours, Object minutes) {
    return 'd\'aquí a ${hours}h $minutes min';
  }

  @override
  String thenAt(Object time) {
    return 'després a les $time';
  }

  @override
  String subscriptionExpiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abonament caducat fa $days dies',
      one: 'Abonament caducat fa 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpiresToday => 'Abonament: caduca avui';

  @override
  String subscriptionExpiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abonament: caduca d\'aquí a $days dies',
      one: 'Abonament: caduca d\'aquí a 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get lastBusBadge => 'Últim bus de la nit';

  @override
  String get recommendedBus => 'Autobús recomanat';

  @override
  String get noDirectTrip => 'Cap trajecte directe';

  @override
  String noDirectTripMessage(Object origin, Object destination) {
    return 'No hi ha cap trajecte directe de \"$origin\" a \"$destination\" en aquesta línia. Prova d\'invertir l\'origen i la destinació.';
  }

  @override
  String get noBusFound => 'No s\'ha trobat cap autobús';

  @override
  String noBusFoundDepartMessage(Object calendar) {
    return 'No hi ha més sortides després d\'aquesta hora per al calendari \"$calendar\". Prova una altra hora o dia.';
  }

  @override
  String get noBusFoundArriveMessage =>
      'Cap trajecte arriba a temps. Prova un límit horari més tard o un altre dia.';

  @override
  String get viewRouteOnMap => 'Veure el trajecte al mapa';

  @override
  String get tripDetailsTitle => 'Detalls del viatge';

  @override
  String get shareTooltip => 'Comparteix';

  @override
  String get fromLabel => 'DE';

  @override
  String get toLabel => 'A';

  @override
  String get direct => 'Directe';

  @override
  String stopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count parades',
      one: '1 parada',
    );
    return '$_temp0';
  }

  @override
  String get routeOnMap => 'Trajecte al mapa';

  @override
  String get stopsOfThisTrip => 'Parades d\'aquest trajecte';

  @override
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar) {
    return 'Autobús $origin → $destination\nSurts a les $dep, arribes a les $arr ($minutes min) — $calendar.';
  }

  @override
  String get lineStopsTitle => 'Parades de la línia';

  @override
  String get calculatingRoute => 'Calculant el trajecte per carretera…';

  @override
  String get routeUnavailable =>
      'Trajecte per carretera no disponible, es mostren línies directes';

  @override
  String get settingsTitle => 'Configuració';

  @override
  String get appearance => 'Aparença';

  @override
  String get appearanceSubtitle =>
      'Clar, fosc o segons la configuració del dispositiu.';

  @override
  String get light => 'Clar';

  @override
  String get dark => 'Fosc';

  @override
  String get system => 'Sistema';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get themeColorSubtitle => 'Tria el color principal de l\'aplicació.';

  @override
  String get colorGreen => 'Verd Monbus';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorIndigo => 'Indi';

  @override
  String get colorPurple => 'Violeta';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorCoral => 'Vermell corall';

  @override
  String get colorOrange => 'Taronja';

  @override
  String get colorAmber => 'Ambre';

  @override
  String get colorTeal => 'Turquesa';

  @override
  String get colorPetrol => 'Blau petroli';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle =>
      'Tria l\'idioma de l\'aplicació o segueix el del dispositiu.';

  @override
  String get languageSystem => 'Automàtic';

  @override
  String get languageItalian => 'Italià';

  @override
  String get languageCatalan => 'Català';

  @override
  String get languageSpanish => 'Espanyol';

  @override
  String get languageEnglish => 'Anglès';

  @override
  String get languageGerman => 'Alemany';

  @override
  String get subscription => 'Abonament';

  @override
  String get subscriptionSubtitle =>
      'Registra el teu abonament per recordar-te quan caduca. Només és un recordatori: no està connectat a cap sistema de bitllets.';

  @override
  String get purchaseDate => 'Data de compra';

  @override
  String get duration => 'Durada';

  @override
  String get oneMonth => '1 mes';

  @override
  String get twoMonths => '2 mesos';

  @override
  String get threeMonths => '3 mesos';

  @override
  String get customDuration => 'Personalitzada';

  @override
  String get expiryDate => 'Data de caducitat';

  @override
  String get chooseDate => 'Tria una data';

  @override
  String get saveSubscription => 'Desa l\'abonament';

  @override
  String get removeSubscription => 'Elimina l\'abonament';

  @override
  String get chooseCustomExpiryWarning =>
      'Tria una data de caducitat personalitzada.';

  @override
  String expiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Caducat fa $days dies',
      one: 'Caducat fa 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Caduca avui';

  @override
  String expiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Caduca d\'aquí a $days dies',
      one: 'Caduca d\'aquí a 1 dia',
    );
    return '$_temp0';
  }

  @override
  String expiryLabel(Object date) {
    return 'Caducitat: $date';
  }

  @override
  String get calWeekday => 'Feiner (Dl-Dv)';

  @override
  String get calWeekdayAugust => 'Feiner (agost)';

  @override
  String get calSaturday => 'Dissabte';

  @override
  String get calSundayHoliday => 'Diumenge / festiu';

  @override
  String get calNight => 'Servei nocturn';

  @override
  String get directionReusTarragona => 'Reus → Tarragona';

  @override
  String get directionTarragonaReus => 'Tarragona → Reus';

  @override
  String minutesAbbrev(Object minutes) {
    return '$minutes min';
  }

  @override
  String get loadError => 'Error en carregar els horaris:';

  @override
  String get infoTitle => 'Informació';

  @override
  String get privacyPolicyTitle => 'Política de privadesa';

  @override
  String get privacyPolicyP1 =>
      'L\'aplicació no recull ni transmet cap dada personal a servidors externs.';

  @override
  String get privacyPolicyP2 =>
      'Les preferències (tema, idioma) i les dades d\'abonament es desen només al teu dispositiu mitjançant SharedPreferences i no es comparteixen mai.';

  @override
  String get privacyPolicyP3 =>
      'L\'aplicació no utilitza anàlisi de dades, galetes de perfilació ni serveis de seguiment de tercers.';

  @override
  String get privacyPolicyP4 =>
      'Les dades d\'abonament s\'eliminen en desinstal·lar l\'aplicació o prement «Elimina l\'abonament» a la configuració.';

  @override
  String get privacyPolicyContact => 'Contacte: lumestudio.app@gmail.com';

  @override
  String get copyright =>
      '© 2024–2026 Lume Labs App. Tots els drets reservats.';

  @override
  String get nightServiceSalou => 'Servei nocturn Salou';

  @override
  String get calNightSalou => 'Nocturn Salou';

  @override
  String get calNightNt3 => 'NT3 Tarragona-Salou';

  @override
  String walkToPoiBanner(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min caminant',
      one: '1 min caminant',
    );
    return '$_temp0';
  }

  @override
  String walkFromStop(Object stop) {
    return 'Des de la parada: $stop';
  }

  @override
  String get poiSectionTitle => 'LLOCS';

  @override
  String get stopsSectionTitle => 'PARADES';

  @override
  String get whereDoYouWantToGo => 'On vols anar?';

  @override
  String get titleDaylife => 'On anem avui?';

  @override
  String get titleNightlife => 'On anem aquesta nit?';

  @override
  String get gpsDetecting => 'Detectant posició…';

  @override
  String get change => 'Canvia';

  @override
  String get categoryUniversity => 'Universitat';

  @override
  String get categoryNightlife => 'Vida nocturna';

  @override
  String get categoryAllStops => 'Totes les parades';

  @override
  String get locationTitle => 'Ubicació';

  @override
  String get locationSubtitle =>
      'Utilitza el GPS per trobar automàticament la parada més propera.';

  @override
  String get locationEnabled => 'Detecció d\'ubicació GPS';

  @override
  String get locationEnabledSubtitle =>
      'La ubicació s\'utilitza només localment i no es transmet mai.';

  @override
  String get locationPermissionDenied =>
      'Permís d\'ubicació denegat. Activa\'l des dels ajustos del dispositiu.';

  @override
  String get privacySection1Title => 'Recollida de dades';

  @override
  String get privacySection2Title => 'Ubicació GPS';

  @override
  String get privacySection3Title => 'Analítiques i seguiment';

  @override
  String get privacySection4Title => 'Mapes i serveis externs';

  @override
  String get privacyPolicyP2loc =>
      'L\'app pot sol·licitar accés a la ubicació GPS per suggerir la parada més propera. La ubicació es processa només al dispositiu i no es transmet mai. El permís és opcional i es pot desactivar a Ajustos.';

  @override
  String get privacyPolicyP4osm =>
      'Les tessel·les del mapa les proporciona OpenStreetMap (tile.openstreetmap.org). No es transmeten dades personals en aquestes sol·licituds.';

  @override
  String get privacyViewOnline => 'Veure política de privadesa completa';
}
