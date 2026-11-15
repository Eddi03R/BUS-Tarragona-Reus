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
  String get goButton => 'Los';

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
  String weatherRainingNow(Object place, int temp) {
    return 'In $place regnet es, nimm einen Regenschirm mit! Es sind $temp°';
  }

  @override
  String weatherMaybeRain(int temp) {
    return 'Es könnte regnen, nimm sicherheitshalber einen Regenschirm mit. Es sind $temp°';
  }

  @override
  String weatherMaybeRainIn(Object place, int temp) {
    return 'In $place könnte es regnen, nimm sicherheitshalber einen Regenschirm mit. Es sind $temp°';
  }

  @override
  String weatherSunny(int temp) {
    return 'Genieße einen sonnigen Tag! Es sind $temp°';
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
  String get lastBusBadge => 'Letzter Bus zu diesem Ziel';

  @override
  String get tripInfoTitle => 'Reiseinfos';

  @override
  String get payCashOnly =>
      'Ticket im Bus: NUR Barzahlung, keine elektronische Zahlung';

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
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  ) {
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
  String get subscription => 'Verkehrs-Abo';

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
  String get titleDaylife => 'Wohin gehen wir heute?';

  @override
  String get titleNightlife => 'Wohin gehen wir heute Nacht?';

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
  String get gameSoundsTitle => 'Spielsounds';

  @override
  String get gameSoundsSubtitle =>
      'Soundeffekte in den Minispielen (Sieg, Züge, Explosionen …). Standardmäßig aus.';

  @override
  String get gameSoundsOff => 'Sounds ausschalten';

  @override
  String get gameSoundsOn => 'Sounds einschalten';

  @override
  String get tutorialSkip => 'Überspringen';

  @override
  String get tutorialNext => 'Weiter';

  @override
  String get tutorialDone => 'Fertig';

  @override
  String get tutorialReview => 'Tutorial ansehen';

  @override
  String get tutorialReviewSub => 'Eine kurze Anleitung zur App';

  @override
  String get tutorial1Title => 'Fahrt suchen';

  @override
  String get tutorial1Text =>
      'Hier ist die Abfahrt (meist per GPS erkannt) und hier die Ankunft: zum Auswählen antippen. Dann „Los“ drücken, um die Busse zu sehen.';

  @override
  String get tutorial2Title => 'Schnelle Fahrten';

  @override
  String get tutorial2Text =>
      'Lege Zuhause und deine übliche Haltestelle fest, um mit einem Tipp zu starten. Tippe nach einer Suche in den Fahrtdetails auf den Stern ★, um sie als Favorit zu speichern.';

  @override
  String get tutorial3Title => 'Wartezeit verkürzen';

  @override
  String get tutorial3Text =>
      'Wartest du auf den Bus? Hier gibt es viele Minispiele zum Zeitvertreib.';

  @override
  String get tutorial4Title => 'Schreib uns';

  @override
  String get tutorial4Text =>
      'Für Funktionswünsche oder Fehlermeldungen schreib uns unter Einstellungen → Info → Kontakt.';

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
      'Kartenkacheln werden von OpenStreetMap (tile.openstreetmap.org) bereitgestellt. Bei diesen Anfragen werden keine persönlichen Daten übertragen. Das Wetter stammt von Open-Meteo (api.open-meteo.com): Die Anfrage enthält die Koordinaten der Haltestelle und, wie bei jeder Verbindung, die IP-Adresse; keine weiteren personenbezogenen Daten.';

  @override
  String get privacyViewOnline =>
      'Vollständige Datenschutzerklärung online anzeigen';

  @override
  String recommendedStopTitle(Object stop) {
    return 'Empfohlene Haltestelle: $stop';
  }

  @override
  String get recommendedStopNote =>
      'Der Bus hält hier, obwohl die Haltestelle nicht im offiziellen Fahrplan steht. Die angezeigte Zeit ist die von Plaça Europa und kann um einige Minuten abweichen.';

  @override
  String get nightMapsNote =>
      'Nachtbusse sind nicht in Google Maps: die angezeigte Route kann abweichen.';

  @override
  String get alightAt => 'Aussteigen:';

  @override
  String get alightHere => 'Hier aussteigen';

  @override
  String get recommendedLabel => 'empfohlen';

  @override
  String get supportTitle => 'Entwickler unterstützen';

  @override
  String get supportSubtitle =>
      'Die App ist kostenlos. Wenn sie dir nützt, kannst du helfen, sie am Laufen zu halten.';

  @override
  String get watchAdButton => 'Entwickler unterstützen: Werbung ansehen';

  @override
  String get adNotReady =>
      'Werbung noch nicht bereit, versuche es in ein paar Sekunden erneut.';

  @override
  String get adThanks => 'Danke für deine Unterstützung! 💚';

  @override
  String get removeAdsTitle => 'Werbung entfernen';

  @override
  String removeAdsMonthly(Object price) {
    return '$price / Monat';
  }

  @override
  String removeAdsYearly(Object price) {
    return '$price / Jahr';
  }

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get premiumActive => 'Danke! Du hast die werbefreie Version.';

  @override
  String get manageSubscription => 'Abo verwalten';

  @override
  String get adPrivacyOptions => 'Datenschutzoptionen für Werbung';

  @override
  String get supportLinkButton => 'Entwickler unterstützen';

  @override
  String get subscriptionUnavailable => 'Abo derzeit nicht verfügbar.';

  @override
  String get privacySection5Title => 'Werbung und Käufe';

  @override
  String get privacyPolicyP5 =>
      'Auf Android zeigt die App Werbung über Google AdMob an, das die Werbe-ID des Geräts und ähnliche Daten verwenden kann; in Europa geschieht dies nur nach deiner Einwilligung, die du in den Einstellungen ändern kannst. Das werbefreie Abo wird von Google Play abgewickelt: die App erhält oder speichert keine Zahlungsdaten. Die Website zeigt ebenfalls ein Werbebanner über Google AdSense (in Europa nur mit deiner Einwilligung).';

  @override
  String get analyticsConsentText =>
      'Wir verwenden anonyme Statistiken (Google Analytics), um die App zu verbessern. Stimmst du zu?';

  @override
  String get analyticsAccept => 'Akzeptieren';

  @override
  String get analyticsReject => 'Ablehnen';

  @override
  String get analyticsSwitchTitle => 'Anonyme Statistiken';

  @override
  String get analyticsSwitchSubtitle =>
      'Sie helfen uns, die App zu verbessern (Google Analytics).';

  @override
  String get privacySection6Title => 'Statistiken und Diagnose';

  @override
  String get privacyPolicyP6 =>
      'Mit deiner Einwilligung nutzen wir Google Analytics (Firebase) für anonyme Nutzungsstatistiken, z. B. welche Suchen durchgeführt und welche Funktionen genutzt werden; du kannst dies jederzeit in den Einstellungen deaktivieren. Auf Android nutzen wir außerdem Firebase Crashlytics, das technische Absturzberichte (Gerätetyp, Android-Version, Fehler) sendet, damit wir sie beheben können. Wir erfassen weder Name, E-Mail noch Standort.';

  @override
  String get privacyAndStats => 'Datenschutz und Statistiken';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get settingOn => 'Aktiv';

  @override
  String get settingOff => 'Inaktiv';

  @override
  String get specialThemes => 'Spezielle Themen';

  @override
  String get specialThemesNote =>
      'Weihnachten ist immer hell und Halloween immer dunkel: der Modus sperrt sich selbst.';

  @override
  String get supportBannerShort => 'Video ansehen oder Werbung entfernen';

  @override
  String get watchAdTitle => 'Video ansehen';

  @override
  String get supportVideoNote =>
      'Ein Dankeschön: das Video entfernt die Werbung nicht.';

  @override
  String get supportAdFreeNote =>
      'Mit dem Abo verschwindet das Werbebanner. Wähle monatlich oder jährlich.';

  @override
  String get subscriptionTerms =>
      'Das Abo verlängert sich automatisch, bis du es in Google Play kündigst.';

  @override
  String get bestValue => 'Bester Preis';

  @override
  String get myPlacesTitle => 'Meine Orte';

  @override
  String get myPlacesSubtitle =>
      'Lege Zuhause und deine übliche Haltestelle (meist nahe der Uni) fest, um Verbindungen mit einem Tipp zu erhalten.';

  @override
  String get homeStopLabel => 'Zuhause';

  @override
  String get usualStopLabel => 'Übliche Haltestelle';

  @override
  String get chooseStop => 'Haltestelle wählen';

  @override
  String get clearPlace => 'Entfernen';

  @override
  String get backHome => 'Nach Hause';

  @override
  String get goToUsual => 'Zur üblichen Haltestelle';

  @override
  String get configureMyRoutes => 'Lege deine üblichen Fahrten fest';

  @override
  String get configureMyRoutesSub =>
      'Lege Zuhause und die übliche Haltestelle fest, um Fahrten mit einem Tipp zu erhalten';

  @override
  String get usefulInfoTitle => 'Nützliche Infos';

  @override
  String get infoSecUniversity => 'Universität';

  @override
  String get infoSecTransport => 'Verkehr';

  @override
  String get infoSecCities => 'Städte';

  @override
  String get infoDisclaimer =>
      'Links zu externen Seiten. Fahrpläne, Preise und Kontakte können sich ändern: prüfe immer die offiziellen Quellen.';

  @override
  String get linkUrv => 'URV · Internationale Studierende';

  @override
  String get linkUrvSub => 'Willkommen, Kurse und Dokumente für Neuankömmlinge';

  @override
  String get linkMonbus => 'Monbus';

  @override
  String get linkMonbusSub => 'Offizielle Fahrpläne und Serviceinformationen';

  @override
  String get linkBusplana => 'Busplana';

  @override
  String get linkBusplanaSub => 'Fahrpläne und Informationen der Plana-Busse';

  @override
  String get linkTarragona => 'Stadt Tarragona';

  @override
  String get linkReus => 'Stadt Reus';

  @override
  String get linkSalou => 'Stadt Salou';

  @override
  String get linkTurisme => 'Tourismus Tarragona';

  @override
  String get arcadeButton => 'Wartezeit vertreiben';

  @override
  String get arcadeNew => 'Neu!';

  @override
  String get arcadeMostPlayed => 'Meistgespielt!';

  @override
  String get arcadeFavAdd => 'Zu Favoriten';

  @override
  String get arcadeFavRemove => 'Aus Favoriten entfernen';

  @override
  String get arcadeRecords => 'Erreichte Rekorde';

  @override
  String get arcadeTitle => 'Wartezeit vertreiben';

  @override
  String get arcadeSubtitle => 'Spiele die Minispiele von ErasBus Tarragona';

  @override
  String get gameTicTacToe => 'Tic-Tac-Toe';

  @override
  String get gameBattleship => 'Schiffe versenken';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameMaze => 'Labyrinth';

  @override
  String get gameBusJam => 'Busse und Kleinbusse';

  @override
  String get gameTicTacToeDesc => 'Fordere das Handy heraus';

  @override
  String get gameBattleshipDesc => 'Versenke die feindliche Flotte';

  @override
  String get gameSudokuDesc => 'Fülle das Raster aus';

  @override
  String get gameMazeDesc => 'Finde den Ausgang';

  @override
  String get gameBusJamDesc => 'Bring den roten Bus heraus';

  @override
  String get difficultyEasy => 'Leicht';

  @override
  String get difficultyMedium => 'Mittel';

  @override
  String get difficultyHard => 'Schwer';

  @override
  String get gameNew => 'Neues Spiel';

  @override
  String get gameYouWin => 'Du hast gewonnen!';

  @override
  String get gameYouLose => 'Du hast verloren';

  @override
  String get gameDraw => 'Unentschieden';

  @override
  String get gameYourTurn => 'Du bist dran';

  @override
  String get gameThinking => 'Das Handy denkt nach…';

  @override
  String get gameNoRecord => 'Kein Rekord';

  @override
  String get gameSolved => 'Gelöst!';

  @override
  String get gameClear => 'Löschen';

  @override
  String get gameRestart => 'Neustart';

  @override
  String get gameNextLevel => 'Nächstes Level';

  @override
  String get gameLevelDone => 'Level geschafft!';

  @override
  String get gameMazeHint =>
      'Wische durchs Labyrinth oder nutze die Pfeile bis zur Flagge';

  @override
  String get gameBusJamHint =>
      'Ziehe die Fahrzeuge, um den Weg für den roten Bus freizumachen';

  @override
  String get gameBattleshipHint =>
      'Tippe aufs gegnerische Meer, um zu schießen';

  @override
  String get gameEnemySea => 'Gegnerisches Meer';

  @override
  String get gameYourSea => 'Dein Meer';

  @override
  String get gameHit => 'Treffer!';

  @override
  String get gameMiss => 'Wasser';

  @override
  String get gameSunk => 'Versenkt!';

  @override
  String gameBest(Object value) {
    return 'Rekord: $value';
  }

  @override
  String gameBestMoves(int n) {
    return 'Rekord: $n Züge';
  }

  @override
  String gameMoves(int n) {
    return 'Züge: $n';
  }

  @override
  String gameLevel(int n) {
    return 'Level $n';
  }

  @override
  String get gamePlaceShips =>
      'Platziere deine Schiffe: Tippe aufs Raster, um das nächste Schiff zu setzen. Tippe auf ein Schiff, um es zu entfernen.';

  @override
  String get gameRotate => 'Drehen';

  @override
  String get gameHorizontal => 'Waagerecht';

  @override
  String get gameVertical => 'Senkrecht';

  @override
  String get gameRandom => 'Zufällig';

  @override
  String get gameStart => 'Starten';

  @override
  String get gameShipNoFit => 'Das Schiff passt hier nicht';

  @override
  String get gameFire => 'Du bist dran: Feuer!';

  @override
  String get gameEnemyTurn => 'Der Gegner ist dran…';

  @override
  String get gameYou => 'Du';

  @override
  String get gameOpponent => 'Gegner';

  @override
  String get widgetInPrefix => 'in';

  @override
  String get widgetMinSuffix => 'Min.';

  @override
  String get widgetNoTrips => 'Keine Fahrten geplant';

  @override
  String get widgetHint =>
      'Du kannst das Widget „ErasBus“ zum Startbildschirm hinzufügen: Hintergrund gedrückt halten → Widgets. Es zeigt die nächsten Fahrten für Zuhause und deine übliche Haltestelle.';

  @override
  String get contactTitle => 'Kontakt';

  @override
  String get contactText =>
      'Möchtest du eine neue Funktion vorschlagen oder einen Fehler melden? Schreib uns eine E-Mail:';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get shipCarrier => 'Flugzeugträger (4)';

  @override
  String get shipDestroyer => 'Zerstörer (3)';

  @override
  String get shipPatrol => 'Patrouillenboot (2)';

  @override
  String get gamePlay => 'Spielen';

  @override
  String get gameDifficulty => 'Schwierigkeit';

  @override
  String get gameTicTacToeHow =>
      'Bilde vor dem Handy eine Reihe aus drei Symbolen: waagerecht, senkrecht oder diagonal. Du spielst X und beginnst.';

  @override
  String get gameBattleshipHow =>
      'Platziere deine Flotte (ein Flugzeugträger, zwei Zerstörer, zwei Patrouillenboote) und versenke die gegnerische, bevor das Handy deine versenkt. Die Schwierigkeit bestimmt, wie clever das Handy ist.';

  @override
  String get gameSudokuHow =>
      'Fülle das Raster mit den Zahlen 1 bis 9, ohne sie in Zeilen, Spalten und 3×3-Blöcken zu wiederholen. Je schwerer, desto weniger Zahlen sind vorgegeben.';

  @override
  String get gameMazeHow =>
      'Fahre den Bus vom Start zur Flagge. Das Labyrinth ist jedes Mal anders und wird mit der Schwierigkeit größer.';

  @override
  String get gameBusJamHow =>
      'Schiebe Busse und Kleinbusse, um den Weg freizumachen und den roten Bus aus dem Parkplatz zu bringen. Jede Stufe hat 10 Level, die nacheinander freigeschaltet werden: je weniger Züge, desto besser.';

  @override
  String get gameBlocks => 'Blockpuzzle 1010';

  @override
  String get game2048 => '2048';

  @override
  String get gameMemory => 'Memory';

  @override
  String get gameWordle => 'Wort des Tages';

  @override
  String get gameFlow => 'Punkte verbinden';

  @override
  String get gameBlocksDesc => 'Vervollständige Zeilen und Spalten';

  @override
  String get game2048Desc => 'Verbinde gleiche Zahlen';

  @override
  String get gameMemoryDesc => 'Finde alle Paare';

  @override
  String get gameWordleDesc => 'Jeden Tag ein neues Wort';

  @override
  String get gameFlowDesc => 'Verbinde die Farben ohne Kreuzung';

  @override
  String get gameBlocksHow =>
      'Ziehe die Teile auf das 10×10-Raster: Jede vollständige Zeile oder Spalte verschwindet. Je mehr Linien gleichzeitig, desto mehr Punkte. Das Spiel endet, wenn kein Teil mehr passt. Leicht: kleine Teile; schwer: größere Teile.';

  @override
  String get game2048How =>
      'Wische, um alle Kacheln zu bewegen: Kacheln mit derselben Zahl verschmelzen und verdoppeln sich. Erreiche 2048! Schwierigkeit: leicht 5×5, mittel 4×4, schwer 3×3.';

  @override
  String get gameMemoryHow =>
      'Drehe zwei Karten gleichzeitig um und finde alle Paare in möglichst kurzer Zeit und mit wenigen Zügen. Leicht: 6 Paare; mittel: 8; schwer: 12.';

  @override
  String get gameWordleHow =>
      'Errate das Wort mit 5 Buchstaben in 6 Versuchen. Grün: richtiger Buchstabe am richtigen Platz; gelb: im Wort, aber woanders; grau: nicht enthalten. Das Wort ist für alle gleich und wechselt täglich, in der Sprache der App.';

  @override
  String get gameArrows => 'Pfeile';

  @override
  String get gameArrowsHow =>
      'Tippe die Pfeile an, um sie vom Spielfeld zu schieben – aber Achtung: Ihr Weg muss frei sein. Manche Pfeile blockieren andere, wähle also die richtige Reihenfolge, um jedes Level zu schaffen. Du hast 3 Leben: Jeder blockierte Pfeil, den du antippst, kostet eins. Schwierigkeit: größeres Feld und mehr Pfeile.';

  @override
  String get gameArrowsHint => 'Tippe einen Pfeil mit freiem Weg an';

  @override
  String gameArrowsLeft(int n) {
    return 'Pfeile: $n';
  }

  @override
  String wordleAttempts(int n) {
    return '$n Versuche';
  }

  @override
  String get gameFlowHow =>
      'Verbinde jedes Paar gleichfarbiger Punkte mit einer Linie, ohne Kreuzungen. Es gibt nur eine Lösung, und sie füllt alle Felder. Schwierigkeit: größer und mehr Farben.';

  @override
  String get gameBlocksHint => 'Ziehe ein Teil auf das Raster';

  @override
  String get game2048Hint => 'Wische in eine Richtung';

  @override
  String get gameMemoryHint => 'Tippe zwei Karten an, um sie umzudrehen';

  @override
  String get gameWordleHint =>
      'Gib ein Wort mit 5 Buchstaben ein und drücke ENTER';

  @override
  String get gameFlowHint =>
      'Ziehe von einem Punkt zum anderen derselben Farbe';

  @override
  String get gameOver => 'Spiel vorbei';

  @override
  String get gamePerfect => 'Perfekt!';

  @override
  String get wordleToday => 'Wort des Tages';

  @override
  String get wordleNotEnough => '5 Buchstaben nötig';

  @override
  String get wordleComeBack => 'Komm morgen für ein neues Wort wieder!';

  @override
  String get wordleShare => 'Ergebnis teilen';

  @override
  String get wordlePractice => 'Zufallswort';

  @override
  String gameScore(int n) {
    return 'Punkte: $n';
  }

  @override
  String gameBestScore(int n) {
    return 'Rekord: $n';
  }

  @override
  String wordleAnswer(Object word) {
    return 'Das Wort war $word';
  }

  @override
  String get gameBackAgain => 'Zum Beenden noch einmal zurück';

  @override
  String get wordlePressEnter => 'Zum Bestätigen ENTER drücken';

  @override
  String get wordleEnter => 'ENTER';

  @override
  String get gameFlowFillAll => 'Paare verbunden! Jetzt alle Felder füllen';

  @override
  String get gameSnake => 'Snake';

  @override
  String get gameMines => 'Minesweeper';

  @override
  String get gameChess => 'Schach';

  @override
  String get gameChessHow =>
      'Du spielst Weiß gegen das Handy. Tippe auf eine Figur und dann auf das Zielfeld: Die möglichen Züge leuchten auf. Es gelten alle Regeln: Rochade, en passant und Umwandlung. Wer Schachmatt setzt, gewinnt. Je höher die Stufe, desto weiter denkt das Handy voraus.';

  @override
  String get gameCheckers => 'Dame';

  @override
  String get gameCheckersHow =>
      'Italienische Dame: Du hast die hellen Steine, unten. Steine ziehen diagonal vorwärts und schlagen durch Überspringen; Schlagen ist Pflicht, und es muss der Zug gewählt werden, der die meisten Steine nimmt. Ein Stein darf keine Dame schlagen. Wer die letzte Reihe erreicht, wird Dame. Du gewinnst, wenn du alles blockierst oder schlägst.';

  @override
  String get gameCheck => 'Schach!';

  @override
  String get gameStalemate => 'Patt: Remis';

  @override
  String get gamePromote => 'Figur wählen';

  @override
  String get gameMustCapture => 'Schlagzwang!';

  @override
  String gameWins(int n) {
    return 'Siege: $n';
  }

  @override
  String get gameSolitaire => 'Solitär';

  @override
  String get gameSlide => 'Schiebepuzzle';

  @override
  String get gameConnections => 'Verbindungen';

  @override
  String get gameFlappy => 'Fliegender Bus';

  @override
  String get gameQuiz => 'Katalonien-Quiz';

  @override
  String get gameSnakeHow =>
      'Steuere den Bus per Wischen (oder Pfeiltasten) und friss die Haltestellen, um zu wachsen, ohne dich selbst zu berühren. Leicht: die Ränder sind offen; mittel und schwer: Wände blockieren und es wird schneller.';

  @override
  String get gameMinesHow =>
      'Decke alle Felder ohne Mine auf. Die Zahlen zeigen, wie viele Minen ringsum liegen. Lang drücken (oder Flaggenmodus), um eine Mine zu markieren. Der erste Tipp ist immer sicher. Je schwerer, desto mehr Minen.';

  @override
  String get gameSolitaireHow =>
      'Klondike-Solitär: Bringe alle Karten auf die vier Ablagen, vom Ass bis zum König, nach Farbe. Auf den Spalten legst du Karten absteigend in wechselnden Farben ab. Tippe eine Karte an und dann das Ziel; ein zweiter Tipp schickt sie zur Ablage.';

  @override
  String get gameSlideHow =>
      'Schiebe die Plättchen in die Reihenfolge ab 1, mit der Lücke am Ende. Leicht 3×3, mittel 4×4, schwer 5×5.';

  @override
  String get gameConnectionsHow =>
      '16 Wörter zu Tarragona, Katalonien und Spanien: Ordne sie in 4 Gruppen zu je 4 mit etwas Gemeinsamem. Du hast 4 Fehler.';

  @override
  String get gameFlappyHow =>
      'Tippe auf den Bildschirm, damit der Bus springt und zwischen den Gebäuden hindurchfliegt. Je schwerer, desto schneller und enger die Lücken.';

  @override
  String get gameQuizHow =>
      '10 gemischte Fragen zu Tarragona, Santa Tecla, Spanien und Katalonien. Wähle die richtige Antwort aus vier.';

  @override
  String get gameSnakeHint => 'Wische zum Starten und Lenken';

  @override
  String get gameMinesHint =>
      'Tippen zum Aufdecken, lang drücken für die Flagge';

  @override
  String get gameSolitaireHint => 'Karte antippen, dann das Ziel';

  @override
  String get gameSlideHint => 'Tippe ein Plättchen neben der Lücke';

  @override
  String get gameConnectionsHint => 'Wähle 4 Wörter derselben Gruppe';

  @override
  String get gameFlappyHint => 'Tippen zum Springen';

  @override
  String get gameMinesDig => 'Aufdecken';

  @override
  String get gameMinesFlag => 'Flagge';

  @override
  String get quizCatTarragona => 'Tarragona';

  @override
  String get quizCatSantaTecla => 'Santa Tecla';

  @override
  String get quizCatSpain => 'Spanien';

  @override
  String get quizCatCatalonia => 'Katalonien';

  @override
  String quizScore(int score, int total) {
    return '$score von $total';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Frage $n von $total';
  }

  @override
  String get quizNext => 'Weiter';

  @override
  String get quizFinish => 'Ergebnis ansehen';

  @override
  String get connMistakes => 'Fehler';

  @override
  String connSolvedCount(int n) {
    return 'Gelöst: $n';
  }

  @override
  String get connOneAway => 'Fast: eins fehlt!';

  @override
  String get connSubmit => 'Bestätigen';

  @override
  String get connShuffle => 'Mischen';

  @override
  String get rewardedArrowsMessage =>
      'Sieh dir eine kurze Werbung an, um ein Leben zu bekommen und das Level fortzusetzen.';

  @override
  String get rewardedArrowsButton => 'Ein Leben holen';

  @override
  String get rewardedReviveTitle => 'Spiel wiederherstellen?';

  @override
  String get rewardedReviveMessage =>
      'Sieh dir eine kurze Werbung an, um dort weiterzumachen, wo du warst, und behalte deine Punkte.';

  @override
  String get rewardedBlocksMessage =>
      'Sieh dir eine kurze Werbung an: Das Spielfeld wird geleert und du behältst deine Punkte.';

  @override
  String get rewardedReviveButton => 'Spiel wiederherstellen';

  @override
  String get rewardedClearButton => 'Feld leeren und weiterspielen';

  @override
  String get rewardedSkipTitle => 'Level überspringen?';

  @override
  String get rewardedSkipMessage =>
      'Sieh dir eine kurze Werbung an, um das Level zu überspringen.';

  @override
  String get rewardedSkipButton => 'Level überspringen';

  @override
  String get rewardedPeekTitle => 'Alle Karten zeigen?';

  @override
  String get rewardedPeekMessage =>
      'Sieh dir eine kurze Werbung an: Die Karten bleiben ein paar Sekunden aufgedeckt.';

  @override
  String get rewardedPeekButton => 'Alle Karten zeigen';

  @override
  String get rewardedUndoTitle => 'Letzte Züge rückgängig machen?';

  @override
  String get rewardedUndoMessage =>
      'Sieh dir eine kurze Werbung an, um die letzten 3 Züge rückgängig zu machen.';

  @override
  String get rewardedUndoButton => '3 Züge zurück';

  @override
  String get rewardedWatch => 'Werbung ansehen';

  @override
  String get rewardedContinue => 'Weiter';

  @override
  String get rewardedNo => 'Nein, danke';

  @override
  String get rewardedFreeNote => 'Du kannst es sofort tun, ohne Werbung.';

  @override
  String get gameSkipped => 'Level übersprungen';
}
