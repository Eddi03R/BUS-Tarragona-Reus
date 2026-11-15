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
  String get goButton => 'Go';

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
  String weatherRainingNow(Object place, int temp) {
    return 'It\'s raining in $place, take an umbrella with you! It\'s $temp°';
  }

  @override
  String weatherMaybeRain(int temp) {
    return 'It might rain, better bring an umbrella just in case. It\'s $temp°';
  }

  @override
  String weatherMaybeRainIn(Object place, int temp) {
    return 'It might rain in $place, better bring an umbrella just in case. It\'s $temp°';
  }

  @override
  String weatherSunny(int temp) {
    return 'Enjoy a beautiful sunny day! It\'s $temp°';
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
  String get lastBusBadge => 'Last bus to this destination';

  @override
  String get tripInfoTitle => 'Trip info';

  @override
  String get payCashOnly =>
      'Tickets on board: cash ONLY, no card or electronic payment';

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
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  ) {
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
  String get subscription => 'Transport pass';

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
  String get gameSoundsTitle => 'Game sounds';

  @override
  String get gameSoundsSubtitle =>
      'Sound effects in the minigames (wins, moves, explosions…). Off by default.';

  @override
  String get gameSoundsOff => 'Turn sounds off';

  @override
  String get gameSoundsOn => 'Turn sounds on';

  @override
  String get tutorialSkip => 'Skip';

  @override
  String get tutorialNext => 'Next';

  @override
  String get tutorialDone => 'Done';

  @override
  String get tutorialReview => 'Replay the tutorial';

  @override
  String get tutorialReviewSub => 'A short guide to using the app';

  @override
  String get tutorial1Title => 'Find your ride';

  @override
  String get tutorial1Text =>
      'Here is the departure (usually found by GPS) and here the arrival: tap to choose. Then press “Go” to see the buses.';

  @override
  String get tutorial2Title => 'Quick trips';

  @override
  String get tutorial2Text =>
      'Set your home and usual stop to leave with one tap. After a search, tap the star ★ in the trip details to save it as a favourite.';

  @override
  String get tutorial3Title => 'Beat the wait';

  @override
  String get tutorial3Text =>
      'Waiting for the bus? Here you\'ll find plenty of minigames to pass the time.';

  @override
  String get tutorial4Title => 'Write to us';

  @override
  String get tutorial4Text =>
      'To request a feature or report a bug, write to us from Settings → Info → Contact us.';

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
      'Map tiles are provided by OpenStreetMap (tile.openstreetmap.org). No personal data is transmitted in these requests. Weather is provided by Open-Meteo (api.open-meteo.com): the request contains the stop\'s coordinates and, as with any connection, the IP address; no other personal data.';

  @override
  String get privacyViewOnline => 'View full privacy policy online';

  @override
  String recommendedStopTitle(Object stop) {
    return 'Recommended stop: $stop';
  }

  @override
  String get recommendedStopNote =>
      'The bus stops here even though it is not in the official route. The time shown is Plaça Europa\'s and may differ by a few minutes.';

  @override
  String get nightMapsNote =>
      'Night buses are not on Google Maps: the route shown may be different.';

  @override
  String get alightAt => 'Get off at:';

  @override
  String get alightHere => 'Get off here';

  @override
  String get recommendedLabel => 'recommended';

  @override
  String get supportTitle => 'Support the developer';

  @override
  String get supportSubtitle =>
      'The app is free. If it\'s useful to you, you can help keep it going.';

  @override
  String get watchAdButton => 'Support the developer by watching an ad';

  @override
  String get adNotReady => 'Ad not ready yet, try again in a few seconds.';

  @override
  String get adThanks => 'Thanks for your support! 💚';

  @override
  String get removeAdsTitle => 'Remove ads';

  @override
  String removeAdsMonthly(Object price) {
    return '$price / month';
  }

  @override
  String removeAdsYearly(Object price) {
    return '$price / year';
  }

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get premiumActive => 'Thank you! You have the ad-free version.';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get adPrivacyOptions => 'Ad privacy options';

  @override
  String get supportLinkButton => 'Support the developer';

  @override
  String get subscriptionUnavailable => 'Subscription not available right now.';

  @override
  String get privacySection5Title => 'Ads and purchases';

  @override
  String get privacyPolicyP5 =>
      'On Android the app shows ads through Google AdMob, which may use the device\'s advertising ID and similar data to serve ads; in Europe this only happens after your consent, which you can change in Settings. The ad-free subscription is handled by Google Play: the app does not receive or store your payment details. The website also shows a banner ad through Google AdSense (in Europe only after your consent).';

  @override
  String get analyticsConsentText =>
      'We use anonymous statistics (Google Analytics) to improve the app. Do you accept?';

  @override
  String get analyticsAccept => 'Accept';

  @override
  String get analyticsReject => 'Decline';

  @override
  String get analyticsSwitchTitle => 'Anonymous statistics';

  @override
  String get analyticsSwitchSubtitle =>
      'They help us improve the app (Google Analytics).';

  @override
  String get privacySection6Title => 'Statistics and diagnostics';

  @override
  String get privacyPolicyP6 =>
      'With your consent we use Google Analytics (Firebase) for anonymous usage statistics, such as which searches are made and which features are used; you can turn it off at any time in Settings. On Android we also use Firebase Crashlytics, which sends technical crash reports (device type, Android version, error) so we can fix them. We do not collect your name, email or location.';

  @override
  String get privacyAndStats => 'Privacy and statistics';

  @override
  String get notSet => 'Not set';

  @override
  String get settingOn => 'On';

  @override
  String get settingOff => 'Off';

  @override
  String get specialThemes => 'Special themes';

  @override
  String get specialThemesNote =>
      'Christmas is always light and Halloween always dark: the mode locks itself.';

  @override
  String get supportBannerShort => 'Watch a video or remove ads';

  @override
  String get watchAdTitle => 'Watch a video';

  @override
  String get supportVideoNote =>
      'A way to say thanks: the video does not remove ads.';

  @override
  String get supportAdFreeNote =>
      'With the subscription the ad banner disappears. Choose monthly or yearly.';

  @override
  String get subscriptionTerms =>
      'The subscription renews automatically until you cancel it in Google Play.';

  @override
  String get bestValue => 'Best value';

  @override
  String get myPlacesTitle => 'My places';

  @override
  String get myPlacesSubtitle =>
      'Set Home and your usual stop (usually near the university) to get journeys in one tap from the home screen.';

  @override
  String get homeStopLabel => 'Home';

  @override
  String get usualStopLabel => 'Usual stop';

  @override
  String get chooseStop => 'Choose a stop';

  @override
  String get clearPlace => 'Remove';

  @override
  String get backHome => 'Go home';

  @override
  String get goToUsual => 'To my usual stop';

  @override
  String get configureMyRoutes => 'Set up your usual journeys';

  @override
  String get configureMyRoutesSub =>
      'Set Home and your usual stop to get journeys in one tap';

  @override
  String get usefulInfoTitle => 'Useful info';

  @override
  String get infoSecUniversity => 'University';

  @override
  String get infoSecTransport => 'Transport';

  @override
  String get infoSecCities => 'Cities';

  @override
  String get infoDisclaimer =>
      'Links to external sites. Timetables, prices and contacts may change: always check the official sources.';

  @override
  String get linkUrv => 'URV · International students';

  @override
  String get linkUrvSub => 'Welcome, courses and documents for new arrivals';

  @override
  String get linkMonbus => 'Monbus';

  @override
  String get linkMonbusSub => 'Official timetables and service information';

  @override
  String get linkBusplana => 'Busplana';

  @override
  String get linkBusplanaSub => 'Plana bus timetables and information';

  @override
  String get linkTarragona => 'Tarragona City Council';

  @override
  String get linkReus => 'Reus City Council';

  @override
  String get linkSalou => 'Salou City Council';

  @override
  String get linkTurisme => 'Tarragona Tourism';

  @override
  String get arcadeButton => 'Beat the wait';

  @override
  String get arcadeNew => 'New!';

  @override
  String get arcadeMostPlayed => 'Most played!';

  @override
  String get arcadeFavAdd => 'Add to favourites';

  @override
  String get arcadeFavRemove => 'Remove from favourites';

  @override
  String get arcadeRecords => 'Records reached';

  @override
  String get arcadeTitle => 'Beat the wait';

  @override
  String get arcadeSubtitle => 'Play the ErasBus Tarragona mini games';

  @override
  String get gameTicTacToe => 'Tic-tac-toe';

  @override
  String get gameBattleship => 'Battleship';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameMaze => 'Maze';

  @override
  String get gameBusJam => 'Buses and minibuses';

  @override
  String get gameTicTacToeDesc => 'Challenge the phone';

  @override
  String get gameBattleshipDesc => 'Sink the enemy fleet';

  @override
  String get gameSudokuDesc => 'Complete the grid';

  @override
  String get gameMazeDesc => 'Find the exit';

  @override
  String get gameBusJamDesc => 'Get the red bus out';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyMedium => 'Medium';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get gameNew => 'New game';

  @override
  String get gameYouWin => 'You won!';

  @override
  String get gameYouLose => 'You lost';

  @override
  String get gameDraw => 'Draw';

  @override
  String get gameYourTurn => 'Your turn';

  @override
  String get gameThinking => 'The phone is thinking…';

  @override
  String get gameNoRecord => 'No record yet';

  @override
  String get gameSolved => 'Solved!';

  @override
  String get gameClear => 'Clear';

  @override
  String get gameRestart => 'Restart';

  @override
  String get gameNextLevel => 'Next level';

  @override
  String get gameLevelDone => 'Level complete!';

  @override
  String get gameMazeHint =>
      'Swipe on the maze or use the arrows to reach the flag';

  @override
  String get gameBusJamHint =>
      'Drag the vehicles to clear the road for the red bus';

  @override
  String get gameBattleshipHint => 'Tap the enemy sea to fire';

  @override
  String get gameEnemySea => 'Enemy sea';

  @override
  String get gameYourSea => 'Your sea';

  @override
  String get gameHit => 'Hit!';

  @override
  String get gameMiss => 'Miss';

  @override
  String get gameSunk => 'Sunk!';

  @override
  String gameBest(Object value) {
    return 'Best: $value';
  }

  @override
  String gameBestMoves(int n) {
    return 'Best: $n moves';
  }

  @override
  String gameMoves(int n) {
    return 'Moves: $n';
  }

  @override
  String gameLevel(int n) {
    return 'Level $n';
  }

  @override
  String get gamePlaceShips =>
      'Place your ships: tap the grid to place the next ship. Tap a ship to remove it.';

  @override
  String get gameRotate => 'Rotate';

  @override
  String get gameHorizontal => 'Horizontal';

  @override
  String get gameVertical => 'Vertical';

  @override
  String get gameRandom => 'Random';

  @override
  String get gameStart => 'Start';

  @override
  String get gameShipNoFit => 'The ship doesn\'t fit here';

  @override
  String get gameFire => 'Your turn: fire!';

  @override
  String get gameEnemyTurn => 'Opponent\'s turn…';

  @override
  String get gameYou => 'You';

  @override
  String get gameOpponent => 'Opponent';

  @override
  String get widgetInPrefix => 'in';

  @override
  String get widgetMinSuffix => 'min';

  @override
  String get widgetNoTrips => 'No trips scheduled';

  @override
  String get widgetHint =>
      'You can add the “ErasBus” widget to your phone\'s home screen: long-press the background → Widgets. It shows the next trips for Home and your usual stop.';

  @override
  String get contactTitle => 'Contact us';

  @override
  String get contactText =>
      'Want to request a new feature or report a bug? Send us an email:';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get shipCarrier => 'Aircraft carrier (4)';

  @override
  String get shipDestroyer => 'Destroyer (3)';

  @override
  String get shipPatrol => 'Patrol boat (2)';

  @override
  String get gamePlay => 'Play';

  @override
  String get gameDifficulty => 'Difficulty';

  @override
  String get gameTicTacToeHow =>
      'Line up three symbols in a row, column or diagonal before the phone does. You play X and go first.';

  @override
  String get gameBattleshipHow =>
      'Place your fleet (one carrier, two destroyers, two patrol boats) and sink the enemy\'s before the phone sinks yours. Difficulty changes how clever the phone is.';

  @override
  String get gameSudokuHow =>
      'Fill the grid with numbers 1 to 9 without repeating them in rows, columns and 3×3 boxes. The harder it is, the fewer numbers are given.';

  @override
  String get gameMazeHow =>
      'Drive the bus from the start to the flag. The maze is different every time, and the harder it is, the bigger it gets.';

  @override
  String get gameBusJamHow =>
      'Slide buses and minibuses to clear the road and get the red bus out of the car park. Each difficulty has 10 levels to unlock one by one: the fewer moves, the better.';

  @override
  String get gameBlocks => 'Block Puzzle 1010';

  @override
  String get game2048 => '2048';

  @override
  String get gameMemory => 'Memory';

  @override
  String get gameWordle => 'Word of the day';

  @override
  String get gameFlow => 'Connect the dots';

  @override
  String get gameBlocksDesc => 'Complete rows and columns';

  @override
  String get game2048Desc => 'Merge matching numbers';

  @override
  String get gameMemoryDesc => 'Find all the pairs';

  @override
  String get gameWordleDesc => 'A new word every day';

  @override
  String get gameFlowDesc => 'Join the colors without crossing';

  @override
  String get gameBlocksHow =>
      'Drag the pieces onto the 10×10 grid: every complete row or column is cleared. The more lines you clear at once, the more points you get. The game ends when no piece fits. Easy: small pieces; hard: bigger pieces.';

  @override
  String get game2048How =>
      'Swipe to move all tiles: tiles with the same number merge and double. Reach 2048! Difficulty: easy 5×5, medium 4×4, hard 3×3.';

  @override
  String get gameMemoryHow =>
      'Flip two cards at a time and find all the pairs in the least time and with the fewest moves. Easy: 6 pairs; medium: 8; hard: 12.';

  @override
  String get gameWordleHow =>
      'Guess the 5-letter word in 6 tries. Green: right letter in the right place; yellow: letter is in the word but elsewhere; grey: not in the word. The word is the same for everyone and changes every day, in the app\'s language.';

  @override
  String get gameArrows => 'Arrows';

  @override
  String get gameArrowsHow =>
      'Tap the arrows to move them off the board, but careful: their path must be clear. Some arrows block others, so pick the right order to complete each level. You have 3 lives: each blocked arrow you tap costs one. Difficulty: bigger board and more arrows.';

  @override
  String get gameArrowsHint => 'Tap an arrow whose way is clear';

  @override
  String gameArrowsLeft(int n) {
    return 'Arrows: $n';
  }

  @override
  String wordleAttempts(int n) {
    return '$n attempts';
  }

  @override
  String get gameFlowHow =>
      'Join each pair of same-coloured dots with a line, without crossings. There is only one solution, and it fills every square. Difficulty: bigger and more colours.';

  @override
  String get gameBlocksHint => 'Drag a piece onto the grid';

  @override
  String get game2048Hint => 'Swipe in any direction';

  @override
  String get gameMemoryHint => 'Tap two cards to flip them';

  @override
  String get gameWordleHint => 'Type a 5-letter word and press ENTER';

  @override
  String get gameFlowHint => 'Drag from one dot to the other of the same color';

  @override
  String get gameOver => 'Game over';

  @override
  String get gamePerfect => 'Perfect!';

  @override
  String get wordleToday => 'Today\'s word';

  @override
  String get wordleNotEnough => 'Needs 5 letters';

  @override
  String get wordleComeBack => 'Come back tomorrow for a new word!';

  @override
  String get wordleShare => 'Share your result';

  @override
  String get wordlePractice => 'Random word';

  @override
  String gameScore(int n) {
    return 'Score: $n';
  }

  @override
  String gameBestScore(int n) {
    return 'Best: $n';
  }

  @override
  String wordleAnswer(Object word) {
    return 'The word was $word';
  }

  @override
  String get gameBackAgain => 'Go back again to exit';

  @override
  String get wordlePressEnter => 'Press ENTER to confirm';

  @override
  String get wordleEnter => 'ENTER';

  @override
  String get gameFlowFillAll => 'Pairs connected! Now fill every square';

  @override
  String get gameSnake => 'Snake';

  @override
  String get gameMines => 'Minesweeper';

  @override
  String get gameChess => 'Chess';

  @override
  String get gameChessHow =>
      'Play White against the phone. Tap a piece, then the square to move it to: the possible moves light up. All rules apply: castling, en passant and promotion. Checkmate wins. The higher the level, the further ahead the phone thinks.';

  @override
  String get gameCheckers => 'Checkers';

  @override
  String get gameCheckersHow =>
      'Italian checkers: you have the light pieces, at the bottom. Men move forward diagonally and capture by jumping an enemy piece; capturing is compulsory and you must take the route that captures the most. A man cannot capture a king. Reaching the far row makes a king. You win by blocking or capturing everything.';

  @override
  String get gameCheck => 'Check!';

  @override
  String get gameStalemate => 'Stalemate: draw';

  @override
  String get gamePromote => 'Choose a piece';

  @override
  String get gameMustCapture => 'You must capture!';

  @override
  String gameWins(int n) {
    return 'Wins: $n';
  }

  @override
  String get gameSolitaire => 'Solitaire';

  @override
  String get gameSlide => 'Sliding puzzle';

  @override
  String get gameConnections => 'Connections';

  @override
  String get gameFlappy => 'Flying bus';

  @override
  String get gameQuiz => 'Catalunya quiz';

  @override
  String get gameSnakeHow =>
      'Steer the bus with a swipe (or the arrow keys) and eat the bus stops to grow, without hitting yourself. Easy: the edges wrap around; medium and hard: walls block you and the speed is higher.';

  @override
  String get gameMinesHow =>
      'Uncover every square without a mine. Numbers tell how many mines are around. Long-press (or flag mode) to mark a mine. The first tap is always safe. The harder the level, the more mines.';

  @override
  String get gameSolitaireHow =>
      'Klondike solitaire: move all cards to the four foundations, from ace to king, by suit. On the columns, stack cards in descending order with alternating colors. Tap a card, then where to put it; a second tap sends it to the foundation.';

  @override
  String get gameSlideHow =>
      'Slide the tiles to put them in order from 1 onwards, with the empty space at the end. Easy 3×3, medium 4×4, hard 5×5.';

  @override
  String get gameConnectionsHow =>
      '16 words about Tarragona, Catalonia and Spain: group them into 4 groups of 4 that have something in common. You have 4 mistakes.';

  @override
  String get gameFlappyHow =>
      'Tap the screen to make the bus jump and fly between the buildings without touching them. The harder the level, the faster you go and the narrower the gaps.';

  @override
  String get gameQuizHow =>
      '10 mixed questions about Tarragona, Santa Tecla, Spain and Catalonia. Pick the right answer out of four.';

  @override
  String get gameSnakeHint => 'Swipe to start and change direction';

  @override
  String get gameMinesHint => 'Tap to uncover, long-press to flag';

  @override
  String get gameSolitaireHint => 'Tap a card, then where to put it';

  @override
  String get gameSlideHint => 'Tap a tile next to the empty space';

  @override
  String get gameConnectionsHint => 'Select 4 words from the same group';

  @override
  String get gameFlappyHint => 'Tap to jump';

  @override
  String get gameMinesDig => 'Uncover';

  @override
  String get gameMinesFlag => 'Flag';

  @override
  String get quizCatTarragona => 'Tarragona';

  @override
  String get quizCatSantaTecla => 'Santa Tecla';

  @override
  String get quizCatSpain => 'Spain';

  @override
  String get quizCatCatalonia => 'Catalonia';

  @override
  String quizScore(int score, int total) {
    return '$score out of $total';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Question $n of $total';
  }

  @override
  String get quizNext => 'Next';

  @override
  String get quizFinish => 'See the result';

  @override
  String get connMistakes => 'Mistakes';

  @override
  String connSolvedCount(int n) {
    return 'Solved: $n';
  }

  @override
  String get connOneAway => 'So close: one away!';

  @override
  String get connSubmit => 'Submit';

  @override
  String get connShuffle => 'Shuffle';

  @override
  String get rewardedArrowsMessage =>
      'Watch a short ad to get one life and keep playing the level.';

  @override
  String get rewardedArrowsButton => 'Get a life';

  @override
  String get rewardedReviveTitle => 'Recover your game?';

  @override
  String get rewardedReviveMessage =>
      'Watch a short ad to carry on where you left off, keeping your score.';

  @override
  String get rewardedBlocksMessage =>
      'Watch a short ad: the board is cleared and you keep your score.';

  @override
  String get rewardedReviveButton => 'Recover the game';

  @override
  String get rewardedClearButton => 'Clear the board and continue';

  @override
  String get rewardedSkipTitle => 'Skip this level?';

  @override
  String get rewardedSkipMessage => 'Watch a short ad to skip the level.';

  @override
  String get rewardedSkipButton => 'Skip the level';

  @override
  String get rewardedPeekTitle => 'Show all the cards?';

  @override
  String get rewardedPeekMessage =>
      'Watch a short ad: the cards stay face up for a few seconds.';

  @override
  String get rewardedPeekButton => 'Show all cards';

  @override
  String get rewardedUndoTitle => 'Undo the last moves?';

  @override
  String get rewardedUndoMessage =>
      'Watch a short ad to undo the last 3 moves.';

  @override
  String get rewardedUndoButton => 'Undo 3 moves';

  @override
  String get rewardedWatch => 'Watch the ad';

  @override
  String get rewardedContinue => 'Continue';

  @override
  String get rewardedNo => 'No, thanks';

  @override
  String get rewardedFreeNote => 'You can do it right away, without an ad.';

  @override
  String get gameSkipped => 'Level skipped';
}
