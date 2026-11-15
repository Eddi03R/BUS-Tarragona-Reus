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
  String get goButton => 'Vés';

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
  String weatherRainingNow(Object place, int temp) {
    return 'Està plovent a $place, porta un paraigua! Hi ha $temp°';
  }

  @override
  String weatherMaybeRain(int temp) {
    return 'Pot ser que plogui, millor que portis un paraigua per si de cas. Hi ha $temp°';
  }

  @override
  String weatherMaybeRainIn(Object place, int temp) {
    return 'Pot ser que plogui a $place, millor que portis un paraigua per si de cas. Hi ha $temp°';
  }

  @override
  String weatherSunny(int temp) {
    return 'Gaudeix d\'un dia assolellat! Hi ha $temp°';
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
  String get lastBusBadge => 'Últim autobús cap a aquesta destinació';

  @override
  String get tripInfoTitle => 'Informació del viatge';

  @override
  String get payCashOnly =>
      'Bitllet a bord: NOMÉS en efectiu, no s\'admet pagament electrònic';

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
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  ) {
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
  String get subscription => 'Abonament de transport';

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
  String get gameSoundsTitle => 'Sons dels jocs';

  @override
  String get gameSoundsSubtitle =>
      'Efectes de so als minijocs (victòria, jugades, explosions…). Desactivats per defecte.';

  @override
  String get gameSoundsOff => 'Silencia els sons';

  @override
  String get gameSoundsOn => 'Activa els sons';

  @override
  String get tutorialSkip => 'Omet';

  @override
  String get tutorialNext => 'Següent';

  @override
  String get tutorialDone => 'Fet';

  @override
  String get tutorialReview => 'Torna a veure el tutorial';

  @override
  String get tutorialReviewSub => 'Una breu guia d\'ús de l\'app';

  @override
  String get tutorial1Title => 'Busca el teu viatge';

  @override
  String get tutorial1Text =>
      'Aquí hi ha la sortida (normalment la detecta el GPS) i aquí l\'arribada: toca per triar. Després prem «Vés» per veure els autobusos.';

  @override
  String get tutorial2Title => 'Viatges ràpids';

  @override
  String get tutorial2Text =>
      'Configura casa teva i la parada habitual per sortir amb un toc. Després d\'una cerca, toca l\'estrella ★ al detall del viatge per desar-lo als preferits.';

  @override
  String get tutorial3Title => 'Fes més curta l\'espera';

  @override
  String get tutorial3Text =>
      'Esperant l\'autobús? Aquí tens molts minijocs per passar l\'estona.';

  @override
  String get tutorial4Title => 'Escriu-nos';

  @override
  String get tutorial4Text =>
      'Si vols demanar una funció o avisar d\'un error, escriu-nos des de Configuració → Informació → Contacta\'ns.';

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
      'Les tessel·les del mapa les proporciona OpenStreetMap (tile.openstreetmap.org). No es transmeten dades personals en aquestes sol·licituds. El temps el proporciona Open-Meteo (api.open-meteo.com): la sol·licitud conté les coordenades de la parada i, com en qualsevol connexió, l\'adreça IP; cap altra dada personal.';

  @override
  String get privacyViewOnline => 'Veure política de privadesa completa';

  @override
  String recommendedStopTitle(Object stop) {
    return 'Parada recomanada: $stop';
  }

  @override
  String get recommendedStopNote =>
      'L\'autobús para aquí tot i que no apareix al recorregut oficial. L\'hora mostrada és la de Plaça Europa i pot variar uns minuts.';

  @override
  String get nightMapsNote =>
      'Els autobusos nocturns no són a Google Maps: el recorregut mostrat pot ser diferent.';

  @override
  String get alightAt => 'Baixa a:';

  @override
  String get alightHere => 'Baixa aquí';

  @override
  String get recommendedLabel => 'recomanada';

  @override
  String get supportTitle => 'Dona suport al desenvolupador';

  @override
  String get supportSubtitle =>
      'L\'app és gratuïta. Si et resulta útil, em pots ajudar a mantenir-la.';

  @override
  String get watchAdButton => 'Dona suport al desenvolupador mirant un anunci';

  @override
  String get adNotReady =>
      'L\'anunci encara no està llest, torna-ho a provar d\'aquí uns segons.';

  @override
  String get adThanks => 'Gràcies pel suport! 💚';

  @override
  String get removeAdsTitle => 'Treu la publicitat';

  @override
  String removeAdsMonthly(Object price) {
    return '$price / mes';
  }

  @override
  String removeAdsYearly(Object price) {
    return '$price / any';
  }

  @override
  String get restorePurchases => 'Restaura les compres';

  @override
  String get premiumActive => 'Gràcies! Tens la versió sense publicitat.';

  @override
  String get manageSubscription => 'Gestiona la subscripció';

  @override
  String get adPrivacyOptions => 'Opcions de privacitat dels anuncis';

  @override
  String get supportLinkButton => 'Dona suport al desenvolupador';

  @override
  String get subscriptionUnavailable => 'Subscripció no disponible ara mateix.';

  @override
  String get privacySection5Title => 'Publicitat i compres';

  @override
  String get privacyPolicyP5 =>
      'A Android l\'app mostra publicitat mitjançant Google AdMob, que pot fer servir l\'identificador publicitari del dispositiu i dades similars per mostrar anuncis; a Europa només passa amb el teu consentiment, que pots canviar a Configuració. La subscripció sense publicitat la gestiona Google Play: l\'app no rep ni desa les teves dades de pagament. El lloc web també mostra un bàner publicitari mitjançant Google AdSense (a Europa només amb el teu consentiment).';

  @override
  String get analyticsConsentText =>
      'Fem servir estadístiques anònimes (Google Analytics) per millorar l\'app. Les acceptes?';

  @override
  String get analyticsAccept => 'Accepta';

  @override
  String get analyticsReject => 'Rebutja';

  @override
  String get analyticsSwitchTitle => 'Estadístiques anònimes';

  @override
  String get analyticsSwitchSubtitle =>
      'Ens ajuden a millorar l\'app (Google Analytics).';

  @override
  String get privacySection6Title => 'Estadístiques i diagnòstic';

  @override
  String get privacyPolicyP6 =>
      'Amb el teu consentiment fem servir Google Analytics (Firebase) per a estadístiques d\'ús anònimes, per exemple quines cerques es fan i quines funcions s\'utilitzen; ho pots desactivar en qualsevol moment a Configuració. A Android fem servir també Firebase Crashlytics, que envia informes tècnics dels tancaments de l\'app (tipus de dispositiu, versió d\'Android, error) per corregir-los. No recollim nom, correu ni ubicació.';

  @override
  String get privacyAndStats => 'Privacitat i estadístiques';

  @override
  String get notSet => 'Sense configurar';

  @override
  String get settingOn => 'Activada';

  @override
  String get settingOff => 'Desactivada';

  @override
  String get specialThemes => 'Temes especials';

  @override
  String get specialThemesNote =>
      'Nadal és sempre clar i Halloween sempre fosc: el mode es bloqueja tot sol.';

  @override
  String get supportBannerShort => 'Mira un vídeo o treu la publicitat';

  @override
  String get watchAdTitle => 'Mira un vídeo';

  @override
  String get supportVideoNote =>
      'Una manera d\'agrair-ho: el vídeo no treu la publicitat.';

  @override
  String get supportAdFreeNote =>
      'Amb la subscripció desapareix el bàner publicitari. Tria mensual o anual.';

  @override
  String get subscriptionTerms =>
      'La subscripció es renova automàticament fins que la cancel·lis a Google Play.';

  @override
  String get bestValue => 'Millor preu';

  @override
  String get myPlacesTitle => 'Els meus llocs';

  @override
  String get myPlacesSubtitle =>
      'Configura Casa i la teva parada habitual (normalment prop de la universitat) per tenir els trajectes amb un toc des de la pantalla d\'inici.';

  @override
  String get homeStopLabel => 'Casa';

  @override
  String get usualStopLabel => 'Parada habitual';

  @override
  String get chooseStop => 'Tria una parada';

  @override
  String get clearPlace => 'Treu';

  @override
  String get backHome => 'Tornar a casa';

  @override
  String get goToUsual => 'A la meva parada habitual';

  @override
  String get configureMyRoutes => 'Configura els teus trajectes habituals';

  @override
  String get configureMyRoutesSub =>
      'Configura Casa i la parada habitual per tenir els trajectes amb un toc';

  @override
  String get usefulInfoTitle => 'Info útil';

  @override
  String get infoSecUniversity => 'Universitat';

  @override
  String get infoSecTransport => 'Transport';

  @override
  String get infoSecCities => 'Ciutats';

  @override
  String get infoDisclaimer =>
      'Enllaços a llocs externs. Els horaris, preus i contactes poden canviar: consulta sempre les fonts oficials.';

  @override
  String get linkUrv => 'URV · Estudiants internacionals';

  @override
  String get linkUrvSub => 'Acollida, cursos i documents per a qui arriba';

  @override
  String get linkMonbus => 'Monbus';

  @override
  String get linkMonbusSub => 'Horaris i informació oficial del servei';

  @override
  String get linkBusplana => 'Busplana';

  @override
  String get linkBusplanaSub => 'Horaris i informació dels autobusos Plana';

  @override
  String get linkTarragona => 'Ajuntament de Tarragona';

  @override
  String get linkReus => 'Ajuntament de Reus';

  @override
  String get linkSalou => 'Ajuntament de Salou';

  @override
  String get linkTurisme => 'Tarragona Turisme';

  @override
  String get arcadeButton => 'Trenca l\'espera';

  @override
  String get arcadeNew => 'Nou!';

  @override
  String get arcadeMostPlayed => 'Més jugats!';

  @override
  String get arcadeFavAdd => 'Afegeix als preferits';

  @override
  String get arcadeFavRemove => 'Treu dels preferits';

  @override
  String get arcadeRecords => 'Rècords aconseguits';

  @override
  String get arcadeTitle => 'Trenca l\'espera';

  @override
  String get arcadeSubtitle => 'Juga als minijocs d\'ErasBus Tarragona';

  @override
  String get gameTicTacToe => 'Tres en ratlla';

  @override
  String get gameBattleship => 'Enfonsar la flota';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameMaze => 'Laberint';

  @override
  String get gameBusJam => 'Busos i minibusos';

  @override
  String get gameTicTacToeDesc => 'Desafia el telèfon';

  @override
  String get gameBattleshipDesc => 'Enfonsa la flota enemiga';

  @override
  String get gameSudokuDesc => 'Completa la graella';

  @override
  String get gameMazeDesc => 'Troba la sortida';

  @override
  String get gameBusJamDesc => 'Treu l\'autobús vermell';

  @override
  String get difficultyEasy => 'Fàcil';

  @override
  String get difficultyMedium => 'Mitjà';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get gameNew => 'Nova partida';

  @override
  String get gameYouWin => 'Has guanyat!';

  @override
  String get gameYouLose => 'Has perdut';

  @override
  String get gameDraw => 'Empat';

  @override
  String get gameYourTurn => 'El teu torn';

  @override
  String get gameThinking => 'El telèfon pensa…';

  @override
  String get gameNoRecord => 'Sense rècord';

  @override
  String get gameSolved => 'Resolt!';

  @override
  String get gameClear => 'Esborra';

  @override
  String get gameRestart => 'Reinicia';

  @override
  String get gameNextLevel => 'Nivell següent';

  @override
  String get gameLevelDone => 'Nivell completat!';

  @override
  String get gameMazeHint =>
      'Llisca pel laberint o fes servir les fletxes fins a la bandera';

  @override
  String get gameBusJamHint =>
      'Arrossega els vehicles per alliberar el camí a l\'autobús vermell';

  @override
  String get gameBattleshipHint => 'Toca el mar enemic per disparar';

  @override
  String get gameEnemySea => 'Mar enemic';

  @override
  String get gameYourSea => 'El teu mar';

  @override
  String get gameHit => 'Tocat!';

  @override
  String get gameMiss => 'Aigua';

  @override
  String get gameSunk => 'Enfonsat!';

  @override
  String gameBest(Object value) {
    return 'Rècord: $value';
  }

  @override
  String gameBestMoves(int n) {
    return 'Rècord: $n moviments';
  }

  @override
  String gameMoves(int n) {
    return 'Moviments: $n';
  }

  @override
  String gameLevel(int n) {
    return 'Nivell $n';
  }

  @override
  String get gamePlaceShips =>
      'Col·loca els teus vaixells: toca la graella per posar el següent vaixell. Toca un vaixell per treure\'l.';

  @override
  String get gameRotate => 'Gira';

  @override
  String get gameHorizontal => 'Horitzontal';

  @override
  String get gameVertical => 'Vertical';

  @override
  String get gameRandom => 'Aleatori';

  @override
  String get gameStart => 'Comença';

  @override
  String get gameShipNoFit => 'El vaixell no hi cap';

  @override
  String get gameFire => 'El teu torn: dispara!';

  @override
  String get gameEnemyTurn => 'Torn de l\'adversari…';

  @override
  String get gameYou => 'Tu';

  @override
  String get gameOpponent => 'Adversari';

  @override
  String get widgetInPrefix => 'd\'aquí a';

  @override
  String get widgetMinSuffix => 'min';

  @override
  String get widgetNoTrips => 'Cap viatge previst';

  @override
  String get widgetHint =>
      'Pots afegir el widget «ErasBus» a la pantalla d\'inici del telèfon: mantén premut el fons → Widgets. Mostra els propers viatges de Casa i la teva parada habitual.';

  @override
  String get contactTitle => 'Contacta\'ns';

  @override
  String get contactText =>
      'Vols demanar una funció nova o informar d\'un error? Escriu-nos un correu:';

  @override
  String get rateApp => 'Valora l\'app';

  @override
  String get shipCarrier => 'Portaavions (4)';

  @override
  String get shipDestroyer => 'Destructor (3)';

  @override
  String get shipPatrol => 'Patrullera (2)';

  @override
  String get gamePlay => 'Juga';

  @override
  String get gameDifficulty => 'Dificultat';

  @override
  String get gameTicTacToeHow =>
      'Alinea tres símbols en fila, columna o diagonal abans que el telèfon. Tu jugues amb la X i comences.';

  @override
  String get gameBattleshipHow =>
      'Col·loca la teva flota (un portaavions, dos destructors, dues patrulleres) i enfonsa l\'enemiga abans que el telèfon enfonsi la teva. La dificultat canvia com d\'astut és el telèfon.';

  @override
  String get gameSudokuHow =>
      'Omple la graella amb els números de l\'1 al 9 sense repetir-los a files, columnes i requadres de 3×3. Com més difícil, menys números ja escrits.';

  @override
  String get gameMazeHow =>
      'Porta l\'autobús des de la sortida fins a la bandera. El laberint és sempre diferent i com més difícil, més gran.';

  @override
  String get gameBusJamHow =>
      'Llisca autobusos i minibusos per alliberar el camí i treure l\'autobús vermell de l\'aparcament. Cada dificultat té 10 nivells que es desbloquegen un a un: com menys moviments, millor.';

  @override
  String get gameBlocks => 'Blocs 1010';

  @override
  String get game2048 => '2048';

  @override
  String get gameMemory => 'Memòria';

  @override
  String get gameWordle => 'Paraula del dia';

  @override
  String get gameFlow => 'Connecta els punts';

  @override
  String get gameBlocksDesc => 'Completa files i columnes';

  @override
  String get game2048Desc => 'Uneix els números iguals';

  @override
  String get gameMemoryDesc => 'Troba totes les parelles';

  @override
  String get gameWordleDesc => 'Una paraula nova cada dia';

  @override
  String get gameFlowDesc => 'Uneix els colors sense creuar';

  @override
  String get gameBlocksHow =>
      'Arrossega les peces a la graella de 10×10: cada fila o columna completa s\'esborra. Com més línies alhora, més punts. La partida acaba quan no hi cap cap peça. Fàcil: peces petites; difícil: peces més grans.';

  @override
  String get game2048How =>
      'Llisca per moure totes les fitxes: les del mateix número s\'uneixen i es dupliquen. Arriba a 2048! Dificultat: fàcil 5×5, mitjà 4×4, difícil 3×3.';

  @override
  String get gameMemoryHow =>
      'Gira dues cartes alhora i troba totes les parelles en el menor temps i amb menys moviments. Fàcil: 6 parelles; mitjà: 8; difícil: 12.';

  @override
  String get gameWordleHow =>
      'Endevina la paraula de 5 lletres en 6 intents. Verd: lletra correcta al lloc correcte; groc: és a la paraula però en un altre lloc; gris: no hi és. La paraula és la mateixa per a tothom i canvia cada dia, en l\'idioma de l\'app.';

  @override
  String get gameArrows => 'Fletxes';

  @override
  String get gameArrowsHow =>
      'Toca les fletxes per treure-les del tauler, però compte: el seu camí ha d\'estar lliure. Algunes fletxes en bloquegen d\'altres, així que tria l\'ordre correcte per completar cada nivell. Tens 3 vides: cada fletxa bloquejada que toques te\'n treu una. Dificultat: tauler més gran i més fletxes.';

  @override
  String get gameArrowsHint => 'Toca una fletxa que tingui el camí lliure';

  @override
  String gameArrowsLeft(int n) {
    return 'Fletxes: $n';
  }

  @override
  String wordleAttempts(int n) {
    return '$n intents';
  }

  @override
  String get gameFlowHow =>
      'Uneix amb una línia cada parella de punts del mateix color, sense encreuaments. Només hi ha una solució, i omple totes les caselles. Dificultat: més gran i més colors.';

  @override
  String get gameBlocksHint => 'Arrossega una peça a la graella';

  @override
  String get game2048Hint => 'Llisca en qualsevol direcció';

  @override
  String get gameMemoryHint => 'Toca dues cartes per girar-les';

  @override
  String get gameWordleHint => 'Escriu una paraula de 5 lletres i prem ENTER';

  @override
  String get gameFlowHint => 'Arrossega d\'un punt a l\'altre del mateix color';

  @override
  String get gameOver => 'Partida acabada';

  @override
  String get gamePerfect => 'Perfecte!';

  @override
  String get wordleToday => 'Paraula d\'avui';

  @override
  String get wordleNotEnough => 'Calen 5 lletres';

  @override
  String get wordleComeBack => 'Torna demà per una paraula nova!';

  @override
  String get wordleShare => 'Comparteix el resultat';

  @override
  String get wordlePractice => 'Paraula aleatòria';

  @override
  String gameScore(int n) {
    return 'Punts: $n';
  }

  @override
  String gameBestScore(int n) {
    return 'Rècord: $n';
  }

  @override
  String wordleAnswer(Object word) {
    return 'La paraula era $word';
  }

  @override
  String get gameBackAgain => 'Torna enrere una altra vegada per sortir';

  @override
  String get wordlePressEnter => 'Prem ENTER per confirmar';

  @override
  String get wordleEnter => 'ENTER';

  @override
  String get gameFlowFillAll => 'Parelles unides! Ara omple totes les caselles';

  @override
  String get gameSnake => 'Snake';

  @override
  String get gameMines => 'Cerca-mines';

  @override
  String get gameChess => 'Escacs';

  @override
  String get gameChessHow =>
      'Jugues amb blanques contra el telèfon. Toca una peça i després la casella de destí: els moviments possibles s\'il·luminen. Valen totes les regles: enroc, captura al pas i promoció. Guanya qui fa escac i mat. Com més alt el nivell, més jugades calcula el telèfon.';

  @override
  String get gameCheckers => 'Dames';

  @override
  String get gameCheckersHow =>
      'Dames italianes: tu tens les fitxes clares, a baix. Les fitxes avancen en diagonal i capturen saltant una fitxa rival; la captura és obligatòria i cal triar la que se\'n porti més. Una fitxa no pot capturar una dama. En arribar al final es corona. Guanya qui bloqueja o captura tot.';

  @override
  String get gameCheck => 'Escac!';

  @override
  String get gameStalemate => 'Taules per ofegat';

  @override
  String get gamePromote => 'Tria la peça';

  @override
  String get gameMustCapture => 'Captura obligatòria!';

  @override
  String gameWins(int n) {
    return 'Victòries: $n';
  }

  @override
  String get gameSolitaire => 'Solitari';

  @override
  String get gameSlide => 'Trencaclosques lliscant';

  @override
  String get gameConnections => 'Connexions';

  @override
  String get gameFlappy => 'Bus volador';

  @override
  String get gameQuiz => 'Quiz Catalunya';

  @override
  String get gameSnakeHow =>
      'Guia el bus amb un lliscament (o les fletxes) i menja les parades per créixer, sense xocar amb tu mateix. Fàcil: les vores es creuen; mitjà i difícil: els murs bloquegen i es va més ràpid.';

  @override
  String get gameMinesHow =>
      'Descobreix totes les caselles sense mina. Els números diuen quantes mines hi ha al voltant. Pulsació llarga (o mode bandera) per marcar una mina. El primer toc sempre és segur. Com més difícil, més mines.';

  @override
  String get gameSolitaireHow =>
      'Solitari Klondike: porta totes les cartes a les quatre fundacions, de l’as al rei, per coll. A les columnes s’apilen cartes en ordre descendent de colors alterns. Toca una carta i després on posar-la; un segon toc l’envia a la fundació.';

  @override
  String get gameSlideHow =>
      'Llisca les fitxes per ordenar-les des de l’1, amb el buit al final. Fàcil 3×3, mitjà 4×4, difícil 5×5.';

  @override
  String get gameConnectionsHow =>
      '16 paraules sobre Tarragona, Catalunya i Espanya: agrupa-les en 4 grups de 4 amb alguna cosa en comú. Tens 4 errors.';

  @override
  String get gameFlappyHow =>
      'Toca la pantalla perquè el bus salti i passi entre els edificis sense tocar-los. Com més difícil, més ràpid i més estrets els passos.';

  @override
  String get gameQuizHow =>
      '10 preguntes barrejades sobre Tarragona, Santa Tecla, Espanya i Catalunya. Tria la resposta correcta entre quatre.';

  @override
  String get gameSnakeHint => 'Llisca per començar i canviar de direcció';

  @override
  String get gameMinesHint =>
      'Toca per descobrir, pulsació llarga per la bandera';

  @override
  String get gameSolitaireHint => 'Toca una carta i després on posar-la';

  @override
  String get gameSlideHint => 'Toca una fitxa al costat del buit';

  @override
  String get gameConnectionsHint => 'Selecciona 4 paraules del mateix grup';

  @override
  String get gameFlappyHint => 'Toca per saltar';

  @override
  String get gameMinesDig => 'Descobrir';

  @override
  String get gameMinesFlag => 'Bandera';

  @override
  String get quizCatTarragona => 'Tarragona';

  @override
  String get quizCatSantaTecla => 'Santa Tecla';

  @override
  String get quizCatSpain => 'Espanya';

  @override
  String get quizCatCatalonia => 'Catalunya';

  @override
  String quizScore(int score, int total) {
    return '$score de $total';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Pregunta $n de $total';
  }

  @override
  String get quizNext => 'Següent';

  @override
  String get quizFinish => 'Veure el resultat';

  @override
  String get connMistakes => 'Errors';

  @override
  String connSolvedCount(int n) {
    return 'Resolts: $n';
  }

  @override
  String get connOneAway => 'Gairebé! En falta una.';

  @override
  String get connSubmit => 'Confirmar';

  @override
  String get connShuffle => 'Barrejar';

  @override
  String get rewardedArrowsMessage =>
      'Mira un anunci breu per aconseguir una vida i continuar el nivell.';

  @override
  String get rewardedArrowsButton => 'Aconseguir una vida';

  @override
  String get rewardedReviveTitle => 'Vols recuperar la partida?';

  @override
  String get rewardedReviveMessage =>
      'Mira un anunci breu per continuar on ho havies deixat, mantenint la puntuació.';

  @override
  String get rewardedBlocksMessage =>
      'Mira un anunci breu: es buida el tauler i mantens la puntuació.';

  @override
  String get rewardedReviveButton => 'Recuperar la partida';

  @override
  String get rewardedClearButton => 'Buidar el tauler i continuar';

  @override
  String get rewardedSkipTitle => 'Vols saltar el nivell?';

  @override
  String get rewardedSkipMessage => 'Mira un anunci breu per saltar el nivell.';

  @override
  String get rewardedSkipButton => 'Saltar el nivell';

  @override
  String get rewardedPeekTitle => 'Vols veure totes les cartes?';

  @override
  String get rewardedPeekMessage =>
      'Mira un anunci breu: les cartes queden descobertes uns segons.';

  @override
  String get rewardedPeekButton => 'Mostrar totes les cartes';

  @override
  String get rewardedUndoTitle => 'Vols desfer les últimes jugades?';

  @override
  String get rewardedUndoMessage =>
      'Mira un anunci breu per desfer les últimes 3 jugades.';

  @override
  String get rewardedUndoButton => 'Desfer 3 jugades';

  @override
  String get rewardedWatch => 'Veure l’anunci';

  @override
  String get rewardedContinue => 'Continuar';

  @override
  String get rewardedNo => 'No, gràcies';

  @override
  String get rewardedFreeNote => 'Ho pots fer ara mateix, sense anunci.';

  @override
  String get gameSkipped => 'Nivell saltat';
}
