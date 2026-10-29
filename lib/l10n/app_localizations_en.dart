// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ErasBus Tarragona';

  @override
  String get lineSubtitle => 'Line e4 · Monbus';

  @override
  String get mapTooltip => 'Stop map';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get departureLabel => 'Departure';

  @override
  String get arrivalLabel => 'Arrival';

  @override
  String get chooseDifferentStops => 'Choose two different stops.';

  @override
  String get inFavorites => 'In favourites';

  @override
  String get saveAsFavorite => 'Save as favourite';

  @override
  String get whenTravel => 'When do you want to travel?';

  @override
  String get departAfter => 'Depart after';

  @override
  String get arriveBy => 'Arrive by';

  @override
  String get holidaySwitch => 'Holiday (use Sunday timetable)';

  @override
  String get nightServiceSwitch => 'Night service';

  @override
  String calendarApplied(Object label) {
    return 'Timetable used: $label';
  }

  @override
  String get findBus => 'Find the bus';

  @override
  String get selectStop => 'Select a stop';

  @override
  String get searchStopOrCity => 'Search stop or city…';

  @override
  String get noOtherBusToday => 'No more buses today for this route';

  @override
  String get nextBusArriving => 'arriving now';

  @override
  String nextBusInMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'in $minutes min',
      one: 'in 1 min',
    );
    return '$_temp0';
  }

  @override
  String nextBusInHours(Object hours) {
    return 'in ${hours}h';
  }

  @override
  String nextBusInHoursMinutes(Object hours, Object minutes) {
    return 'in ${hours}h $minutes min';
  }

  @override
  String thenAt(Object time) {
    return 'then at $time';
  }

  @override
  String subscriptionExpiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Pass expired $days days ago',
      one: 'Pass expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get subscriptionExpiresToday => 'Pass: expires today';

  @override
  String subscriptionExpiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Pass: expires in $days days',
      one: 'Pass: expires in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get lastBusBadge => 'Last bus of the night';

  @override
  String get recommendedBus => 'Recommended bus';

  @override
  String get noDirectTrip => 'No direct trip';

  @override
  String noDirectTripMessage(Object origin, Object destination) {
    return 'There is no direct trip from \"$origin\" to \"$destination\" on this line. Try swapping origin and destination.';
  }

  @override
  String get noBusFound => 'No bus found';

  @override
  String noBusFoundDepartMessage(Object calendar) {
    return 'There are no more departures after this time for the \"$calendar\" timetable. Try another time or day.';
  }

  @override
  String get noBusFoundArriveMessage =>
      'No trips arrive in time. Try a later deadline or another day.';

  @override
  String get viewRouteOnMap => 'View the route on the map';

  @override
  String get tripDetailsTitle => 'Trip details';

  @override
  String get shareTooltip => 'Share';

  @override
  String get fromLabel => 'FROM';

  @override
  String get toLabel => 'TO';

  @override
  String get direct => 'Direct';

  @override
  String stopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stops',
      one: '1 stop',
    );
    return '$_temp0';
  }

  @override
  String get routeOnMap => 'Route on the map';

  @override
  String get stopsOfThisTrip => 'Stops on this trip';

  @override
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar) {
    return 'Bus $origin → $destination\nDepart at $dep, arrive at $arr ($minutes min) — $calendar.';
  }

  @override
  String get lineStopsTitle => 'Line stops';

  @override
  String get calculatingRoute => 'Calculating road route…';

  @override
  String get routeUnavailable =>
      'Road route unavailable, showing straight lines';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get appearanceSubtitle =>
      'Light, dark, or follow the device settings.';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get themeColor => 'Theme colour';

  @override
  String get themeColorSubtitle => 'Choose the app\'s main colour.';

  @override
  String get colorGreen => 'Monbus green';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorCoral => 'Coral red';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorPetrol => 'Petrol blue';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle =>
      'Choose the app\'s language or follow the device.';

  @override
  String get languageSystem => 'Automatic';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languageCatalan => 'Catalan';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageGerman => 'German';

  @override
  String get subscription => 'Pass';

  @override
  String get subscriptionSubtitle =>
      'Register your pass to be reminded when it expires. Just a reminder: it isn\'t linked to any ticketing system.';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get duration => 'Duration';

  @override
  String get oneMonth => '1 month';

  @override
  String get twoMonths => '2 months';

  @override
  String get threeMonths => '3 months';

  @override
  String get customDuration => 'Custom';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get chooseDate => 'Choose date';

  @override
  String get saveSubscription => 'Save pass';

  @override
  String get removeSubscription => 'Remove pass';

  @override
  String get chooseCustomExpiryWarning => 'Choose a custom expiry date.';

  @override
  String expiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expired $days days ago',
      one: 'Expired 1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Expires today';

  @override
  String expiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Expires in $days days',
      one: 'Expires in 1 day',
    );
    return '$_temp0';
  }

  @override
  String expiryLabel(Object date) {
    return 'Expiry: $date';
  }

  @override
  String get calWeekday => 'Weekday (Mon-Fri)';

  @override
  String get calWeekdayAugust => 'Weekday (August)';

  @override
  String get calSaturday => 'Saturday';

  @override
  String get calSundayHoliday => 'Sunday / holiday';

  @override
  String get calNight => 'Night service';

  @override
  String get directionReusTarragona => 'Reus → Tarragona';

  @override
  String get directionTarragonaReus => 'Tarragona → Reus';

  @override
  String minutesAbbrev(Object minutes) {
    return '$minutes min';
  }

  @override
  String get loadError => 'Error loading the timetables:';

  @override
  String get infoTitle => 'Info';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyP1 =>
      'The app does not collect or transmit any personal data to external servers.';

  @override
  String get privacyPolicyP2 =>
      'Preferences (theme, language) and pass data are saved only on your device via SharedPreferences and are never shared.';

  @override
  String get privacyPolicyP3 =>
      'The app does not use analytics, profiling cookies, or third-party tracking services.';

  @override
  String get privacyPolicyP4 =>
      'Pass data is deleted on uninstall or by tapping \"Remove pass\" in settings.';

  @override
  String get privacyPolicyContact => 'Contact: lumestudio.app@gmail.com';

  @override
  String get copyright => '© 2024–2026 Lume Labs App. All rights reserved.';

  @override
  String get nightServiceSalou => 'Night service Salou';

  @override
  String get calNightSalou => 'Night Salou';

  @override
  String get calNightNt3 => 'NT3 Tarragona-Salou';

  @override
  String walkToPoiBanner(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min walk',
      one: '1 min walk',
    );
    return '$_temp0';
  }

  @override
  String walkFromStop(Object stop) {
    return 'From stop: $stop';
  }

  @override
  String get poiSectionTitle => 'PLACES';

  @override
  String get stopsSectionTitle => 'STOPS';

  @override
  String get whereDoYouWantToGo => 'Where do you want to go?';

  @override
  String get titleDaylife => 'Where are we going today?';

  @override
  String get titleNightlife => 'Where are we going tonight?';

  @override
  String get gpsDetecting => 'Detecting location…';

  @override
  String get change => 'Change';

  @override
  String get categoryUniversity => 'University';

  @override
  String get categoryNightlife => 'Nightlife';

  @override
  String get categoryAllStops => 'All stops';

  @override
  String get locationTitle => 'Location';

  @override
  String get locationSubtitle =>
      'Use GPS to automatically find the nearest bus stop.';

  @override
  String get locationEnabled => 'GPS location detection';

  @override
  String get locationEnabledSubtitle =>
      'Location is only used locally and is never transmitted.';

  @override
  String get locationPermissionDenied =>
      'Location permission denied. Enable it in device settings.';

  @override
  String get privacySection1Title => 'Data collection';

  @override
  String get privacySection2Title => 'GPS location';

  @override
  String get privacySection3Title => 'Analytics and tracking';

  @override
  String get privacySection4Title => 'Maps and external services';

  @override
  String get privacyPolicyP2loc =>
      'The app may request GPS location access to suggest the nearest bus stop. Location is processed on-device only and never transmitted. Permission is optional and can be disabled in Settings.';

  @override
  String get privacyPolicyP4osm =>
      'Map tiles are provided by OpenStreetMap (tile.openstreetmap.org). No personal data is transmitted in these requests.';

  @override
  String get privacyViewOnline => 'View full privacy policy online';
}
