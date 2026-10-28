// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ErasBus Tarragona';

  @override
  String get lineSubtitle => 'Linie e4 · Monbus';

  @override
  String get mapTooltip => 'Haltestellenkarte';

  @override
  String get settingsTooltip => 'Einstellungen';

  @override
  String get departureLabel => 'Abfahrt';

  @override
  String get arrivalLabel => 'Ankunft';

  @override
  String get chooseDifferentStops =>
      'Wähle zwei unterschiedliche Haltestellen.';

  @override
  String get inFavorites => 'In Favoriten';

  @override
  String get saveAsFavorite => 'Als Favorit speichern';

  @override
  String get whenTravel => 'Wann möchtest du reisen?';

  @override
  String get departAfter => 'Abfahrt nach';

  @override
  String get arriveBy => 'Ankunft bis';

  @override
  String get holidaySwitch => 'Feiertag (Sonntagsfahrplan verwenden)';

  @override
  String get nightServiceSwitch => 'Nachtverkehr';

  @override
  String calendarApplied(Object label) {
    return 'Verwendeter Fahrplan: $label';
  }

  @override
  String get findBus => 'Bus finden';

  @override
  String get selectStop => 'Haltestelle auswählen';

  @override
  String get searchStopOrCity => 'Haltestelle oder Stadt suchen…';

  @override
  String get noOtherBusToday => 'Heute keine weiteren Busse für diese Strecke';

  @override
  String get nextBusArriving => 'kommt gerade an';

  @override
  String nextBusInMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'in $minutes Min.',
      one: 'in 1 Min.',
    );
    return '$_temp0';
  }

  @override
  String nextBusInHours(Object hours) {
    return 'in $hours Std.';
  }

  @override
  String nextBusInHoursMinutes(Object hours, Object minutes) {
    return 'in $hours Std. $minutes Min.';
  }

  @override
  String thenAt(Object time) {
    return 'danach um $time';
  }

  @override
  String subscriptionExpiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abo seit $days Tagen abgelaufen',
      one: 'Abo seit 1 Tag abgelaufen',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpiresToday => 'Abo: läuft heute ab';

  @override
  String subscriptionExpiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abo: läuft in $days Tagen ab',
      one: 'Abo: läuft in 1 Tag ab',
    );
    return '$_temp0';
  }

  @override
  String get lastBusBadge => 'Letzter Bus der Nacht';

  @override
  String get recommendedBus => 'Empfohlener Bus';

  @override
  String get noDirectTrip => 'Keine Direktverbindung';

  @override
  String noDirectTripMessage(Object origin, Object destination) {
    return 'Es gibt keine Direktverbindung von \"$origin\" nach \"$destination\" auf dieser Linie. Versuche, Start und Ziel zu vertauschen.';
  }

  @override
  String get noBusFound => 'Kein Bus gefunden';

  @override
  String noBusFoundDepartMessage(Object calendar) {
    return 'Nach dieser Uhrzeit gibt es keine weiteren Abfahrten im Fahrplan \"$calendar\". Versuche eine andere Uhrzeit oder einen anderen Tag.';
  }

  @override
  String get noBusFoundArriveMessage =>
      'Keine Verbindung kommt rechtzeitig an. Versuche eine spätere Ankunftszeit oder einen anderen Tag.';

  @override
  String get viewRouteOnMap => 'Strecke auf der Karte ansehen';

  @override
  String get tripDetailsTitle => 'Fahrtdetails';

  @override
  String get shareTooltip => 'Teilen';

  @override
  String get fromLabel => 'VON';

  @override
  String get toLabel => 'NACH';

  @override
  String get direct => 'Direkt';

  @override
  String stopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Haltestellen',
      one: '1 Haltestelle',
    );
    return '$_temp0';
  }

  @override
  String get routeOnMap => 'Strecke auf der Karte';

  @override
  String get stopsOfThisTrip => 'Haltestellen dieser Fahrt';

  @override
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar) {
    return 'Bus $origin → $destination\nAbfahrt um $dep, Ankunft um $arr ($minutes Min.) — $calendar.';
  }

  @override
  String get lineStopsTitle => 'Haltestellen der Linie';

  @override
  String get calculatingRoute => 'Straßenroute wird berechnet…';

  @override
  String get routeUnavailable =>
      'Straßenroute nicht verfügbar, zeige direkte Linien';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get appearance => 'Erscheinungsbild';

  @override
  String get appearanceSubtitle =>
      'Hell, dunkel oder wie in den Geräteeinstellungen.';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get themeColor => 'Designfarbe';

  @override
  String get themeColorSubtitle => 'Wähle die Hauptfarbe der App.';

  @override
  String get colorGreen => 'Monbus-Grün';

  @override
  String get colorBlue => 'Blau';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Violett';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorCoral => 'Korallrot';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorTeal => 'Türkis';

  @override
  String get colorPetrol => 'Petrolblau';

  @override
  String get language => 'Sprache';

  @override
  String get languageSubtitle =>
      'Wähle die Sprache der App oder folge dem Gerät.';

  @override
  String get languageSystem => 'Automatisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languageCatalan => 'Katalanisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get subscription => 'Abo';

  @override
  String get subscriptionSubtitle =>
      'Erfasse dein Abo, um erinnert zu werden, wann es abläuft. Nur eine Erinnerung: nicht mit einem Ticketsystem verbunden.';

  @override
  String get purchaseDate => 'Kaufdatum';

  @override
  String get duration => 'Laufzeit';

  @override
  String get oneMonth => '1 Monat';

  @override
  String get twoMonths => '2 Monate';

  @override
  String get threeMonths => '3 Monate';

  @override
  String get customDuration => 'Benutzerdefiniert';

  @override
  String get expiryDate => 'Ablaufdatum';

  @override
  String get chooseDate => 'Datum wählen';

  @override
  String get saveSubscription => 'Abo speichern';

  @override
  String get removeSubscription => 'Abo entfernen';

  @override
  String get chooseCustomExpiryWarning =>
      'Wähle ein benutzerdefiniertes Ablaufdatum.';

  @override
  String expiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Seit $days Tagen abgelaufen',
      one: 'Seit 1 Tag abgelaufen',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Läuft heute ab';

  @override
  String expiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Läuft in $days Tagen ab',
      one: 'Läuft in 1 Tag ab',
    );
    return '$_temp0';
  }

  @override
  String expiryLabel(Object date) {
    return 'Ablauf: $date';
  }

  @override
  String get calWeekday => 'Werktag (Mo-Fr)';

  @override
  String get calWeekdayAugust => 'Werktag (August)';

  @override
  String get calSaturday => 'Samstag';

  @override
  String get calSundayHoliday => 'Sonntag / Feiertag';

  @override
  String get calNight => 'Nachtverkehr';

  @override
  String get directionReusTarragona => 'Reus → Tarragona';

  @override
  String get directionTarragonaReus => 'Tarragona → Reus';

  @override
  String minutesAbbrev(Object minutes) {
    return '$minutes Min.';
  }

  @override
  String get loadError => 'Fehler beim Laden der Fahrpläne:';

  @override
  String get infoTitle => 'Info';

  @override
  String get privacyPolicyTitle => 'Datenschutzerklärung';

  @override
  String get privacyPolicyP1 =>
      'Die App erfasst oder übermittelt keine personenbezogenen Daten an externe Server.';

  @override
  String get privacyPolicyP2 =>
      'Einstellungen (Design, Sprache) und Abo-Daten werden ausschließlich auf deinem Gerät über SharedPreferences gespeichert und nie weitergegeben.';

  @override
  String get privacyPolicyP3 =>
      'Die App verwendet keine Analyse-Tools, Profiling-Cookies oder Drittanbieter-Tracking-Dienste.';

  @override
  String get privacyPolicyP4 =>
      'Abo-Daten werden bei der Deinstallation oder über «Abo entfernen» in den Einstellungen gelöscht.';

  @override
  String get privacyPolicyContact => 'Kontakt: lumestudio.app@gmail.com';

  @override
  String get copyright => '© 2024–2026 Lume Labs App. Alle Rechte vorbehalten.';

  @override
  String get nightServiceSalou => 'Nachtbus Salou';

  @override
  String get calNightSalou => 'Nacht Salou';

  @override
  String get calNightNt3 => 'NT3 Tarragona-Salou';

  @override
  String walkToPoiBanner(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Min. Fußweg',
      one: '1 Min. Fußweg',
    );
    return '$_temp0';
  }

  @override
  String walkFromStop(Object stop) {
    return 'Von Haltestelle: $stop';
  }

  @override
  String get poiSectionTitle => 'ORTE';

  @override
  String get stopsSectionTitle => 'HALTESTELLEN';

  @override
  String get whereDoYouWantToGo => 'Wohin möchtest du?';

  @override
  String get gpsDetecting => 'Position wird ermittelt…';

  @override
  String get change => 'Ändern';

  @override
  String get categoryUniversity => 'Universität';

  @override
  String get categoryNightlife => 'Nachtleben';

  @override
  String get categoryAllStops => 'Alle Haltestellen';

  @override
  String get locationTitle => 'Standort';

  @override
  String get locationSubtitle =>
      'GPS verwenden, um die nächste Haltestelle automatisch zu finden.';

  @override
  String get locationEnabled => 'GPS-Standorterkennung';

  @override
  String get locationEnabledSubtitle =>
      'Der Standort wird nur lokal verwendet und nie übertragen.';

  @override
  String get locationPermissionDenied =>
      'Standortberechtigung verweigert. Aktiviere sie in den Geräteeinstellungen.';

  @override
  String get privacySection1Title => 'Datenerfassung';

  @override
  String get privacySection2Title => 'GPS-Standort';

  @override
  String get privacySection3Title => 'Analysen und Tracking';

  @override
  String get privacySection4Title => 'Karten und externe Dienste';

  @override
  String get privacyPolicyP2loc =>
      'Die App kann GPS-Standortzugriff anfordern, um die nächste Bushaltestelle vorzuschlagen. Der Standort wird nur auf dem Gerät verarbeitet und nie übertragen. Die Berechtigung ist optional und kann in den Einstellungen deaktiviert werden.';

  @override
  String get privacyPolicyP4osm =>
      'Kartenkacheln werden von OpenStreetMap (tile.openstreetmap.org) bereitgestellt. Bei diesen Anfragen werden keine persönlichen Daten übertragen.';

  @override
  String get privacyViewOnline =>
      'Vollständige Datenschutzerklärung online anzeigen';
}
