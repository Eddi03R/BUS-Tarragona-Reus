// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'ErasBus Tarragona';

  @override
  String get lineSubtitle => 'Línea e4 · Monbus';

  @override
  String get mapTooltip => 'Mapa de paradas';

  @override
  String get settingsTooltip => 'Ajustes';

  @override
  String get departureLabel => 'Salida';

  @override
  String get arrivalLabel => 'Llegada';

  @override
  String get chooseDifferentStops => 'Elige dos paradas diferentes.';

  @override
  String get inFavorites => 'En favoritos';

  @override
  String get saveAsFavorite => 'Guardar como favorita';

  @override
  String get whenTravel => '¿Cuándo quieres viajar?';

  @override
  String get departAfter => 'Salgo después de las';

  @override
  String get arriveBy => 'Llegada antes de las';

  @override
  String get holidaySwitch => 'Festivo (usa horario de domingo)';

  @override
  String get nightServiceSwitch => 'Servicio nocturno';

  @override
  String calendarApplied(Object label) {
    return 'Calendario aplicado: $label';
  }

  @override
  String get findBus => 'Buscar autobús';

  @override
  String get goButton => 'Ir';

  @override
  String get selectStop => 'Selecciona una parada';

  @override
  String get searchStopOrCity => 'Buscar parada o ciudad…';

  @override
  String get noOtherBusToday => 'No hay más autobuses hoy para este trayecto';

  @override
  String get nextBusArriving => 'llegando';

  @override
  String nextBusInMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: 'en $minutes min',
      one: 'en 1 min',
    );
    return '$_temp0';
  }

  @override
  String nextBusInHours(Object hours) {
    return 'en ${hours}h';
  }

  @override
  String nextBusInHoursMinutes(Object hours, Object minutes) {
    return 'en ${hours}h $minutes min';
  }

  @override
  String thenAt(Object time) {
    return 'luego a las $time';
  }

  @override
  String subscriptionExpiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abono caducado hace $days días',
      one: 'Abono caducado hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String weatherRainingNow(Object place, int temp) {
    return 'Está lloviendo en $place, ¡lleva un paraguas! Hay $temp°';
  }

  @override
  String weatherMaybeRain(int temp) {
    return 'Puede que llueva, mejor lleva un paraguas por si acaso. Hay $temp°';
  }

  @override
  String weatherMaybeRainIn(Object place, int temp) {
    return 'Puede que llueva en $place, mejor lleva un paraguas por si acaso. Hay $temp°';
  }

  @override
  String weatherSunny(int temp) {
    return '¡Disfruta de un día soleado! Hay $temp°';
  }

  @override
  String get subscriptionExpiresToday => 'Abono: caduca hoy';

  @override
  String subscriptionExpiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Abono: caduca en $days días',
      one: 'Abono: caduca en 1 día',
    );
    return '$_temp0';
  }

  @override
  String get lastBusBadge => 'Último autobús hacia este destino';

  @override
  String get tripInfoTitle => 'Información del viaje';

  @override
  String get payCashOnly =>
      'Billete a bordo: SOLO efectivo, no se admite pago electrónico';

  @override
  String get recommendedBus => 'Autobús recomendado';

  @override
  String get noDirectTrip => 'Sin trayecto directo';

  @override
  String noDirectTripMessage(Object origin, Object destination) {
    return 'No existe un trayecto directo de \"$origin\" a \"$destination\" en esta línea. Prueba a invertir origen y destino.';
  }

  @override
  String get noBusFound => 'No se ha encontrado ningún autobús';

  @override
  String noBusFoundDepartMessage(Object calendar) {
    return 'No hay más salidas después de esta hora para el calendario \"$calendar\". Prueba otra hora u otro día.';
  }

  @override
  String get noBusFoundArriveMessage =>
      'Ningún trayecto llega a tiempo. Prueba un límite horario más tarde u otro día.';

  @override
  String get viewRouteOnMap => 'Ver el trayecto en el mapa';

  @override
  String get tripDetailsTitle => 'Detalles del viaje';

  @override
  String get shareTooltip => 'Compartir';

  @override
  String get fromLabel => 'DE';

  @override
  String get toLabel => 'A';

  @override
  String get direct => 'Directo';

  @override
  String stopsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count paradas',
      one: '1 parada',
    );
    return '$_temp0';
  }

  @override
  String get routeOnMap => 'Trayecto en el mapa';

  @override
  String get stopsOfThisTrip => 'Paradas de este trayecto';

  @override
  String shareText(
    Object origin,
    Object destination,
    Object dep,
    Object arr,
    Object minutes,
    Object calendar,
  ) {
    return 'Autobús $origin → $destination\nSales a las $dep, llegas a las $arr ($minutes min) — $calendar.';
  }

  @override
  String get lineStopsTitle => 'Paradas de la línea';

  @override
  String get calculatingRoute => 'Calculando trayecto por carretera…';

  @override
  String get routeUnavailable =>
      'Trayecto por carretera no disponible, se muestran líneas directas';

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get appearance => 'Apariencia';

  @override
  String get appearanceSubtitle =>
      'Claro, oscuro o según los ajustes del dispositivo.';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get themeColorSubtitle => 'Elige el color principal de la aplicación.';

  @override
  String get colorGreen => 'Verde Monbus';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorPurple => 'Morado';

  @override
  String get colorMagenta => 'Magenta';

  @override
  String get colorCoral => 'Rojo coral';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorAmber => 'Ámbar';

  @override
  String get colorTeal => 'Turquesa';

  @override
  String get colorPetrol => 'Azul petróleo';

  @override
  String get language => 'Idioma';

  @override
  String get languageSubtitle =>
      'Elige el idioma de la aplicación o sigue el del dispositivo.';

  @override
  String get languageSystem => 'Automático';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageCatalan => 'Catalán';

  @override
  String get languageSpanish => 'Español';

  @override
  String get languageEnglish => 'Inglés';

  @override
  String get languageGerman => 'Alemán';

  @override
  String get subscription => 'Abono de transporte';

  @override
  String get subscriptionSubtitle =>
      'Registra tu abono para recordarte cuándo caduca. Solo es un recordatorio: no está conectado a ningún sistema de billetes.';

  @override
  String get purchaseDate => 'Fecha de compra';

  @override
  String get duration => 'Duración';

  @override
  String get oneMonth => '1 mes';

  @override
  String get twoMonths => '2 meses';

  @override
  String get threeMonths => '3 meses';

  @override
  String get customDuration => 'Personalizada';

  @override
  String get expiryDate => 'Fecha de caducidad';

  @override
  String get chooseDate => 'Elegir fecha';

  @override
  String get saveSubscription => 'Guardar abono';

  @override
  String get removeSubscription => 'Eliminar abono';

  @override
  String get chooseCustomExpiryWarning =>
      'Elige una fecha de caducidad personalizada.';

  @override
  String expiredDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Caducado hace $days días',
      one: 'Caducado hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get expiresToday => 'Caduca hoy';

  @override
  String expiresInDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Caduca en $days días',
      one: 'Caduca en 1 día',
    );
    return '$_temp0';
  }

  @override
  String expiryLabel(Object date) {
    return 'Caducidad: $date';
  }

  @override
  String get calWeekday => 'Laborable (Lun-Vie)';

  @override
  String get calWeekdayAugust => 'Laborable (agosto)';

  @override
  String get calSaturday => 'Sábado';

  @override
  String get calSundayHoliday => 'Domingo / festivo';

  @override
  String get calNight => 'Servicio nocturno';

  @override
  String get directionReusTarragona => 'Reus → Tarragona';

  @override
  String get directionTarragonaReus => 'Tarragona → Reus';

  @override
  String minutesAbbrev(Object minutes) {
    return '$minutes min';
  }

  @override
  String get loadError => 'Error al cargar los horarios:';

  @override
  String get infoTitle => 'Información';

  @override
  String get privacyPolicyTitle => 'Política de privacidad';

  @override
  String get privacyPolicyP1 =>
      'La aplicación no recopila ni transmite datos personales a servidores externos.';

  @override
  String get privacyPolicyP2 =>
      'Las preferencias (tema, idioma) y los datos del abono se guardan solo en tu dispositivo mediante SharedPreferences y nunca se comparten.';

  @override
  String get privacyPolicyP3 =>
      'La aplicación no utiliza análisis de datos, cookies de perfilado ni servicios de seguimiento de terceros.';

  @override
  String get privacyPolicyP4 =>
      'Los datos del abono se eliminan al desinstalar la aplicación o al pulsar «Eliminar abono» en los ajustes.';

  @override
  String get privacyPolicyContact => 'Contacto: lumestudio.app@gmail.com';

  @override
  String get copyright =>
      '© 2024–2026 Lume Labs App. Todos los derechos reservados.';

  @override
  String get nightServiceSalou => 'Servicio nocturno Salou';

  @override
  String get calNightSalou => 'Nocturno Salou';

  @override
  String get calNightNt3 => 'NT3 Tarragona-Salou';

  @override
  String walkToPoiBanner(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes min a pie',
      one: '1 min a pie',
    );
    return '$_temp0';
  }

  @override
  String walkFromStop(Object stop) {
    return 'Desde la parada: $stop';
  }

  @override
  String get poiSectionTitle => 'LUGARES';

  @override
  String get stopsSectionTitle => 'PARADAS';

  @override
  String get whereDoYouWantToGo => '¿Adónde quieres ir?';

  @override
  String get titleDaylife => '¿Dónde vamos hoy?';

  @override
  String get titleNightlife => '¿Dónde vamos esta noche?';

  @override
  String get gpsDetecting => 'Detectando posición…';

  @override
  String get change => 'Cambiar';

  @override
  String get categoryUniversity => 'Universidad';

  @override
  String get categoryNightlife => 'Vida nocturna';

  @override
  String get categoryAllStops => 'Todas las paradas';

  @override
  String get gameSoundsTitle => 'Sonidos de los juegos';

  @override
  String get gameSoundsSubtitle =>
      'Efectos de sonido en los minijuegos (victoria, jugadas, explosiones…). Desactivados por defecto.';

  @override
  String get gameSoundsOff => 'Silenciar sonidos';

  @override
  String get gameSoundsOn => 'Activar sonidos';

  @override
  String get tutorialSkip => 'Saltar';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialDone => 'Listo';

  @override
  String get tutorialReview => 'Ver el tutorial';

  @override
  String get tutorialReviewSub => 'Una breve guía de uso de la app';

  @override
  String get tutorial1Title => 'Busca tu viaje';

  @override
  String get tutorial1Text =>
      'Aquí está la salida (normalmente la detecta el GPS) y aquí la llegada: toca para elegir. Luego pulsa «Ir» para ver los autobuses.';

  @override
  String get tutorial2Title => 'Viajes rápidos';

  @override
  String get tutorial2Text =>
      'Configura tu casa y tu parada habitual para salir con un toque. Tras una búsqueda, toca la estrella ★ en el detalle del viaje para guardarlo en favoritos.';

  @override
  String get tutorial3Title => 'Haz más corta la espera';

  @override
  String get tutorial3Text =>
      '¿Esperando el autobús? Aquí tienes muchos minijuegos para pasar el rato.';

  @override
  String get tutorial4Title => 'Escríbenos';

  @override
  String get tutorial4Text =>
      'Si quieres pedir una función o avisar de un error, escríbenos desde Ajustes → Información → Contáctanos.';

  @override
  String get locationTitle => 'Ubicación';

  @override
  String get locationSubtitle =>
      'Usa el GPS para encontrar automáticamente la parada más cercana.';

  @override
  String get locationEnabled => 'Detección de ubicación GPS';

  @override
  String get locationEnabledSubtitle =>
      'La ubicación se usa solo localmente y nunca se transmite.';

  @override
  String get locationPermissionDenied =>
      'Permiso de ubicación denegado. Actívalo en los ajustes del dispositivo.';

  @override
  String get privacySection1Title => 'Recopilación de datos';

  @override
  String get privacySection2Title => 'Ubicación GPS';

  @override
  String get privacySection3Title => 'Analíticas y seguimiento';

  @override
  String get privacySection4Title => 'Mapas y servicios externos';

  @override
  String get privacyPolicyP2loc =>
      'La app puede solicitar acceso a la ubicación GPS para sugerir la parada más cercana. La ubicación se procesa solo en el dispositivo y nunca se transmite. El permiso es opcional y se puede desactivar en Ajustes.';

  @override
  String get privacyPolicyP4osm =>
      'Los mosaicos del mapa son proporcionados por OpenStreetMap (tile.openstreetmap.org). No se transmiten datos personales en estas solicitudes. El tiempo lo proporciona Open-Meteo (api.open-meteo.com): la solicitud contiene las coordenadas de la parada y, como en toda conexión, la dirección IP; ningún otro dato personal.';

  @override
  String get privacyViewOnline => 'Ver política de privacidad completa';

  @override
  String recommendedStopTitle(Object stop) {
    return 'Parada recomendada: $stop';
  }

  @override
  String get recommendedStopNote =>
      'El autobús para aquí aunque no aparece en el recorrido oficial. La hora mostrada es la de Plaça Europa y puede variar unos minutos.';

  @override
  String get nightMapsNote =>
      'Los autobuses nocturnos no están en Google Maps: el recorrido mostrado puede ser distinto.';

  @override
  String get alightAt => 'Bájate en:';

  @override
  String get alightHere => 'Bájate aquí';

  @override
  String get recommendedLabel => 'recomendada';

  @override
  String get supportTitle => 'Apoya al desarrollador';

  @override
  String get supportSubtitle =>
      'La app es gratuita. Si te resulta útil, puedes ayudarme a mantenerla.';

  @override
  String get watchAdButton => 'Apoya al desarrollador viendo un anuncio';

  @override
  String get adNotReady =>
      'El anuncio aún no está listo, inténtalo de nuevo en unos segundos.';

  @override
  String get adThanks => '¡Gracias por tu apoyo! 💚';

  @override
  String get removeAdsTitle => 'Quitar la publicidad';

  @override
  String removeAdsMonthly(Object price) {
    return '$price / mes';
  }

  @override
  String removeAdsYearly(Object price) {
    return '$price / año';
  }

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get premiumActive => '¡Gracias! Tienes la versión sin publicidad.';

  @override
  String get manageSubscription => 'Gestionar suscripción';

  @override
  String get adPrivacyOptions => 'Opciones de privacidad de anuncios';

  @override
  String get supportLinkButton => 'Apoya al desarrollador';

  @override
  String get subscriptionUnavailable => 'Suscripción no disponible por ahora.';

  @override
  String get privacySection5Title => 'Publicidad y compras';

  @override
  String get privacyPolicyP5 =>
      'En Android la app muestra publicidad mediante Google AdMob, que puede usar el identificador publicitario del dispositivo y datos similares para mostrar anuncios; en Europa solo ocurre con tu consentimiento, que puedes cambiar en Ajustes. La suscripción sin publicidad la gestiona Google Play: la app no recibe ni guarda tus datos de pago. El sitio web también muestra un banner publicitario mediante Google AdSense (en Europa solo con tu consentimiento).';

  @override
  String get analyticsConsentText =>
      'Usamos estadísticas anónimas (Google Analytics) para mejorar la app. ¿Las aceptas?';

  @override
  String get analyticsAccept => 'Aceptar';

  @override
  String get analyticsReject => 'Rechazar';

  @override
  String get analyticsSwitchTitle => 'Estadísticas anónimas';

  @override
  String get analyticsSwitchSubtitle =>
      'Nos ayudan a mejorar la app (Google Analytics).';

  @override
  String get privacySection6Title => 'Estadísticas y diagnóstico';

  @override
  String get privacyPolicyP6 =>
      'Con tu consentimiento usamos Google Analytics (Firebase) para estadísticas de uso anónimas, por ejemplo qué búsquedas se hacen y qué funciones se usan; puedes desactivarlo en cualquier momento en Ajustes. En Android usamos también Firebase Crashlytics, que envía informes técnicos de cierres de la app (tipo de dispositivo, versión de Android, error) para corregirlos. No recopilamos nombre, correo ni ubicación.';

  @override
  String get privacyAndStats => 'Privacidad y estadísticas';

  @override
  String get notSet => 'Sin configurar';

  @override
  String get settingOn => 'Activada';

  @override
  String get settingOff => 'Desactivada';

  @override
  String get specialThemes => 'Temas especiales';

  @override
  String get specialThemesNote =>
      'Navidad es siempre claro y Halloween siempre oscuro: el modo se bloquea solo.';

  @override
  String get supportBannerShort => 'Mira un vídeo o quita la publicidad';

  @override
  String get watchAdTitle => 'Mira un vídeo';

  @override
  String get supportVideoNote =>
      'Una forma de dar las gracias: el vídeo no quita la publicidad.';

  @override
  String get supportAdFreeNote =>
      'Con la suscripción desaparece el banner publicitario. Elige mensual o anual.';

  @override
  String get subscriptionTerms =>
      'La suscripción se renueva automáticamente hasta que la canceles en Google Play.';

  @override
  String get bestValue => 'Mejor precio';

  @override
  String get myPlacesTitle => 'Mis lugares';

  @override
  String get myPlacesSubtitle =>
      'Configura Casa y tu parada habitual (normalmente cerca de la universidad) para tener los viajes con un toque desde la pantalla de inicio.';

  @override
  String get homeStopLabel => 'Casa';

  @override
  String get usualStopLabel => 'Parada habitual';

  @override
  String get chooseStop => 'Elige una parada';

  @override
  String get clearPlace => 'Quitar';

  @override
  String get backHome => 'Volver a casa';

  @override
  String get goToUsual => 'A mi parada habitual';

  @override
  String get configureMyRoutes => 'Configura tus viajes habituales';

  @override
  String get configureMyRoutesSub =>
      'Configura Casa y tu parada habitual para tener los viajes con un toque';

  @override
  String get usefulInfoTitle => 'Información útil';

  @override
  String get infoSecUniversity => 'Universidad';

  @override
  String get infoSecTransport => 'Transporte';

  @override
  String get infoSecCities => 'Ciudades';

  @override
  String get infoDisclaimer =>
      'Enlaces a sitios externos. Los horarios, precios y contactos pueden cambiar: consulta siempre las fuentes oficiales.';

  @override
  String get linkUrv => 'URV · Estudiantes internacionales';

  @override
  String get linkUrvSub => 'Acogida, cursos y documentos para quien llega';

  @override
  String get linkMonbus => 'Monbus';

  @override
  String get linkMonbusSub => 'Horarios e información oficial del servicio';

  @override
  String get linkBusplana => 'Busplana';

  @override
  String get linkBusplanaSub => 'Horarios e información de los autobuses Plana';

  @override
  String get linkTarragona => 'Ayuntamiento de Tarragona';

  @override
  String get linkReus => 'Ayuntamiento de Reus';

  @override
  String get linkSalou => 'Ayuntamiento de Salou';

  @override
  String get linkTurisme => 'Turismo de Tarragona';

  @override
  String get arcadeButton => 'Rompe la espera';

  @override
  String get arcadeNew => '¡Nuevo!';

  @override
  String get arcadeMostPlayed => '¡Más jugados!';

  @override
  String get arcadeFavAdd => 'Añadir a favoritos';

  @override
  String get arcadeFavRemove => 'Quitar de favoritos';

  @override
  String get arcadeRecords => 'Récords logrados';

  @override
  String get arcadeTitle => 'Rompe la espera';

  @override
  String get arcadeSubtitle => 'Juega a los minijuegos de ErasBus Tarragona';

  @override
  String get gameTicTacToe => 'Tres en raya';

  @override
  String get gameBattleship => 'Hundir la flota';

  @override
  String get gameSudoku => 'Sudoku';

  @override
  String get gameMaze => 'Laberinto';

  @override
  String get gameBusJam => 'Buses y minibuses';

  @override
  String get gameTicTacToeDesc => 'Desafía al teléfono';

  @override
  String get gameBattleshipDesc => 'Hunde la flota enemiga';

  @override
  String get gameSudokuDesc => 'Completa la cuadrícula';

  @override
  String get gameMazeDesc => 'Encuentra la salida';

  @override
  String get gameBusJamDesc => 'Saca el autobús rojo';

  @override
  String get difficultyEasy => 'Fácil';

  @override
  String get difficultyMedium => 'Medio';

  @override
  String get difficultyHard => 'Difícil';

  @override
  String get gameNew => 'Nueva partida';

  @override
  String get gameYouWin => '¡Has ganado!';

  @override
  String get gameYouLose => 'Has perdido';

  @override
  String get gameDraw => 'Empate';

  @override
  String get gameYourTurn => 'Tu turno';

  @override
  String get gameThinking => 'El teléfono piensa…';

  @override
  String get gameNoRecord => 'Sin récord';

  @override
  String get gameSolved => '¡Resuelto!';

  @override
  String get gameClear => 'Borrar';

  @override
  String get gameRestart => 'Reiniciar';

  @override
  String get gameNextLevel => 'Siguiente nivel';

  @override
  String get gameLevelDone => '¡Nivel completado!';

  @override
  String get gameMazeHint =>
      'Desliza por el laberinto o usa las flechas hasta la bandera';

  @override
  String get gameBusJamHint =>
      'Arrastra los vehículos para liberar el camino al autobús rojo';

  @override
  String get gameBattleshipHint => 'Toca el mar enemigo para disparar';

  @override
  String get gameEnemySea => 'Mar enemigo';

  @override
  String get gameYourSea => 'Tu mar';

  @override
  String get gameHit => '¡Tocado!';

  @override
  String get gameMiss => 'Agua';

  @override
  String get gameSunk => '¡Hundido!';

  @override
  String gameBest(Object value) {
    return 'Récord: $value';
  }

  @override
  String gameBestMoves(int n) {
    return 'Récord: $n movimientos';
  }

  @override
  String gameMoves(int n) {
    return 'Movimientos: $n';
  }

  @override
  String gameLevel(int n) {
    return 'Nivel $n';
  }

  @override
  String get gamePlaceShips =>
      'Coloca tus barcos: toca la cuadrícula para colocar el siguiente barco. Toca un barco para quitarlo.';

  @override
  String get gameRotate => 'Girar';

  @override
  String get gameHorizontal => 'Horizontal';

  @override
  String get gameVertical => 'Vertical';

  @override
  String get gameRandom => 'Aleatorio';

  @override
  String get gameStart => 'Empezar';

  @override
  String get gameShipNoFit => 'El barco no cabe aquí';

  @override
  String get gameFire => 'Tu turno: ¡dispara!';

  @override
  String get gameEnemyTurn => 'Turno del rival…';

  @override
  String get gameYou => 'Tú';

  @override
  String get gameOpponent => 'Rival';

  @override
  String get widgetInPrefix => 'en';

  @override
  String get widgetMinSuffix => 'min';

  @override
  String get widgetNoTrips => 'Sin viajes previstos';

  @override
  String get widgetHint =>
      'Puedes añadir el widget «ErasBus» a la pantalla de inicio del teléfono: mantén pulsado el fondo → Widgets. Muestra los próximos viajes de Casa y tu parada habitual.';

  @override
  String get contactTitle => 'Contáctanos';

  @override
  String get contactText =>
      '¿Quieres pedir una nueva función o informar de un error? Escríbenos un correo:';

  @override
  String get rateApp => 'Valorar la app';

  @override
  String get shipCarrier => 'Portaaviones (4)';

  @override
  String get shipDestroyer => 'Destructor (3)';

  @override
  String get shipPatrol => 'Patrullera (2)';

  @override
  String get gamePlay => 'Jugar';

  @override
  String get gameDifficulty => 'Dificultad';

  @override
  String get gameTicTacToeHow =>
      'Alinea tres símbolos en fila, columna o diagonal antes que el teléfono. Juegas con la X y empiezas tú.';

  @override
  String get gameBattleshipHow =>
      'Coloca tu flota (un portaaviones, dos destructores, dos patrulleras) y hunde la enemiga antes de que el teléfono hunda la tuya. La dificultad cambia lo astuto que es el teléfono.';

  @override
  String get gameSudokuHow =>
      'Rellena la cuadrícula con los números del 1 al 9 sin repetirlos en filas, columnas y cuadros de 3×3. Cuanto más difícil, menos números ya escritos.';

  @override
  String get gameMazeHow =>
      'Lleva el autobús desde la salida hasta la bandera. El laberinto es siempre distinto y cuanto más difícil, más grande.';

  @override
  String get gameBusJamHow =>
      'Desliza autobuses y minibuses para liberar el camino y sacar el autobús rojo del aparcamiento. Cada dificultad tiene 10 niveles que se desbloquean uno a uno: cuantos menos movimientos, mejor.';

  @override
  String get gameBlocks => 'Bloques 1010';

  @override
  String get game2048 => '2048';

  @override
  String get gameMemory => 'Memoria';

  @override
  String get gameWordle => 'Palabra del día';

  @override
  String get gameFlow => 'Conecta los puntos';

  @override
  String get gameBlocksDesc => 'Completa filas y columnas';

  @override
  String get game2048Desc => 'Une los números iguales';

  @override
  String get gameMemoryDesc => 'Encuentra todas las parejas';

  @override
  String get gameWordleDesc => 'Una palabra nueva cada día';

  @override
  String get gameFlowDesc => 'Une los colores sin cruzar';

  @override
  String get gameBlocksHow =>
      'Arrastra las piezas a la cuadrícula de 10×10: cada fila o columna completa se borra. Cuantas más líneas a la vez, más puntos. La partida termina cuando no cabe ninguna pieza. Fácil: piezas pequeñas; difícil: piezas más grandes.';

  @override
  String get game2048How =>
      'Desliza para mover todas las fichas: las del mismo número se unen y se duplican. ¡Llega a 2048! Dificultad: fácil 5×5, medio 4×4, difícil 3×3.';

  @override
  String get gameMemoryHow =>
      'Da la vuelta a dos cartas a la vez y encuentra todas las parejas en el menor tiempo y con menos movimientos. Fácil: 6 parejas; medio: 8; difícil: 12.';

  @override
  String get gameWordleHow =>
      'Adivina la palabra de 5 letras en 6 intentos. Verde: letra correcta en su sitio; amarillo: está en la palabra pero en otro sitio; gris: no está. La palabra es la misma para todos y cambia cada día, en el idioma de la app.';

  @override
  String get gameArrows => 'Flechas';

  @override
  String get gameArrowsHow =>
      'Toca las flechas para sacarlas del tablero, pero cuidado: su camino debe estar libre. Algunas flechas bloquean a otras, así que elige el orden correcto para completar cada nivel. Tienes 3 vidas: cada flecha bloqueada que tocas te quita una. Dificultad: tablero más grande y más flechas.';

  @override
  String get gameArrowsHint => 'Toca una flecha que tenga el camino libre';

  @override
  String gameArrowsLeft(int n) {
    return 'Flechas: $n';
  }

  @override
  String wordleAttempts(int n) {
    return '$n intentos';
  }

  @override
  String get gameFlowHow =>
      'Une con una línea cada pareja de puntos del mismo color, sin cruces. Solo hay una solución, y llena todas las casillas. Dificultad: más grande y más colores.';

  @override
  String get gameBlocksHint => 'Arrastra una pieza a la cuadrícula';

  @override
  String get game2048Hint => 'Desliza en cualquier dirección';

  @override
  String get gameMemoryHint => 'Toca dos cartas para girarlas';

  @override
  String get gameWordleHint => 'Escribe una palabra de 5 letras y pulsa ENTER';

  @override
  String get gameFlowHint => 'Arrastra de un punto al otro del mismo color';

  @override
  String get gameOver => 'Partida terminada';

  @override
  String get gamePerfect => '¡Perfecto!';

  @override
  String get wordleToday => 'Palabra de hoy';

  @override
  String get wordleNotEnough => 'Faltan letras (5)';

  @override
  String get wordleComeBack => '¡Vuelve mañana para una palabra nueva!';

  @override
  String get wordleShare => 'Comparte tu resultado';

  @override
  String get wordlePractice => 'Palabra aleatoria';

  @override
  String gameScore(int n) {
    return 'Puntos: $n';
  }

  @override
  String gameBestScore(int n) {
    return 'Récord: $n';
  }

  @override
  String wordleAnswer(Object word) {
    return 'La palabra era $word';
  }

  @override
  String get gameBackAgain => 'Vuelve atrás otra vez para salir';

  @override
  String get wordlePressEnter => 'Pulsa ENTER para confirmar';

  @override
  String get wordleEnter => 'ENTER';

  @override
  String get gameFlowFillAll =>
      '¡Parejas unidas! Ahora rellena todas las casillas';

  @override
  String get gameSnake => 'Snake';

  @override
  String get gameMines => 'Buscaminas';

  @override
  String get gameChess => 'Ajedrez';

  @override
  String get gameChessHow =>
      'Juegas con blancas contra el teléfono. Toca una pieza y luego la casilla de destino: los movimientos posibles se iluminan. Valen todas las reglas: enroque, captura al paso y promoción. Gana quien da jaque mate. Cuanto más alto el nivel, más jugadas calcula el teléfono.';

  @override
  String get gameCheckers => 'Damas';

  @override
  String get gameCheckersHow =>
      'Damas italianas: tú tienes las fichas claras, abajo. Las fichas avanzan en diagonal y capturan saltando una ficha rival; la captura es obligatoria y hay que elegir la que se lleve más fichas. Una ficha no puede capturar una dama. Al llegar al final se corona. Gana quien bloquea o captura todo.';

  @override
  String get gameCheck => '¡Jaque!';

  @override
  String get gameStalemate => 'Tablas por ahogado';

  @override
  String get gamePromote => 'Elige la pieza';

  @override
  String get gameMustCapture => '¡Captura obligatoria!';

  @override
  String gameWins(int n) {
    return 'Victorias: $n';
  }

  @override
  String get gameSolitaire => 'Solitario';

  @override
  String get gameSlide => 'Puzle deslizante';

  @override
  String get gameConnections => 'Conexiones';

  @override
  String get gameFlappy => 'Bus volador';

  @override
  String get gameQuiz => 'Quiz Catalunya';

  @override
  String get gameSnakeHow =>
      'Guía el bus con un deslizamiento (o las flechas) y come las paradas para crecer, sin chocar contigo mismo. Fácil: los bordes se cruzan; medio y difícil: los muros bloquean y se va más rápido.';

  @override
  String get gameMinesHow =>
      'Descubre todas las casillas sin mina. Los números indican cuántas minas hay alrededor. Pulsación larga (o modo bandera) para marcar una mina. El primer toque siempre es seguro. Cuanto más difícil, más minas.';

  @override
  String get gameSolitaireHow =>
      'Solitario Klondike: lleva todas las cartas a las cuatro fundaciones, del as al rey, por palo. En las columnas se apilan cartas en orden descendente de colores alternos. Toca una carta y luego dónde ponerla; un segundo toque la manda a la fundación.';

  @override
  String get gameSlideHow =>
      'Desliza las fichas para ordenarlas desde el 1, con el hueco al final. Fácil 3×3, medio 4×4, difícil 5×5.';

  @override
  String get gameConnectionsHow =>
      '16 palabras sobre Tarragona, Cataluña y España: agrúpalas en 4 grupos de 4 con algo en común. Tienes 4 errores.';

  @override
  String get gameFlappyHow =>
      'Toca la pantalla para que el bus salte y pase entre los edificios sin tocarlos. Cuanto más difícil, más rápido y más estrechos los huecos.';

  @override
  String get gameQuizHow =>
      '10 preguntas mezcladas sobre Tarragona, Santa Tecla, España y Cataluña. Elige la respuesta correcta entre cuatro.';

  @override
  String get gameSnakeHint => 'Desliza para empezar y cambiar de dirección';

  @override
  String get gameMinesHint =>
      'Toca para descubrir, pulsación larga para la bandera';

  @override
  String get gameSolitaireHint => 'Toca una carta y luego dónde ponerla';

  @override
  String get gameSlideHint => 'Toca una ficha junto al hueco';

  @override
  String get gameConnectionsHint => 'Selecciona 4 palabras del mismo grupo';

  @override
  String get gameFlappyHint => 'Toca para saltar';

  @override
  String get gameMinesDig => 'Descubrir';

  @override
  String get gameMinesFlag => 'Bandera';

  @override
  String get quizCatTarragona => 'Tarragona';

  @override
  String get quizCatSantaTecla => 'Santa Tecla';

  @override
  String get quizCatSpain => 'España';

  @override
  String get quizCatCatalonia => 'Cataluña';

  @override
  String quizScore(int score, int total) {
    return '$score de $total';
  }

  @override
  String quizQuestionOf(int n, int total) {
    return 'Pregunta $n de $total';
  }

  @override
  String get quizNext => 'Siguiente';

  @override
  String get quizFinish => 'Ver resultado';

  @override
  String get connMistakes => 'Errores';

  @override
  String connSolvedCount(int n) {
    return 'Resueltos: $n';
  }

  @override
  String get connOneAway => '¡Casi! Te falta una.';

  @override
  String get connSubmit => 'Confirmar';

  @override
  String get connShuffle => 'Mezclar';

  @override
  String get rewardedArrowsMessage =>
      'Mira un anuncio breve para conseguir una vida y seguir con el nivel.';

  @override
  String get rewardedArrowsButton => 'Conseguir una vida';

  @override
  String get rewardedReviveTitle => '¿Recuperar la partida?';

  @override
  String get rewardedReviveMessage =>
      'Mira un anuncio breve para seguir donde lo dejaste, manteniendo la puntuación.';

  @override
  String get rewardedBlocksMessage =>
      'Mira un anuncio breve: se vacía el tablero y mantienes la puntuación.';

  @override
  String get rewardedReviveButton => 'Recuperar la partida';

  @override
  String get rewardedClearButton => 'Vaciar el tablero y continuar';

  @override
  String get rewardedSkipTitle => '¿Saltar el nivel?';

  @override
  String get rewardedSkipMessage =>
      'Mira un anuncio breve para saltar el nivel.';

  @override
  String get rewardedSkipButton => 'Saltar el nivel';

  @override
  String get rewardedPeekTitle => '¿Ver todas las cartas?';

  @override
  String get rewardedPeekMessage =>
      'Mira un anuncio breve: las cartas quedan descubiertas unos segundos.';

  @override
  String get rewardedPeekButton => 'Mostrar todas las cartas';

  @override
  String get rewardedUndoTitle => '¿Deshacer las últimas jugadas?';

  @override
  String get rewardedUndoMessage =>
      'Mira un anuncio breve para deshacer las últimas 3 jugadas.';

  @override
  String get rewardedUndoButton => 'Deshacer 3 jugadas';

  @override
  String get rewardedWatch => 'Ver el anuncio';

  @override
  String get rewardedContinue => 'Continuar';

  @override
  String get rewardedNo => 'No, gracias';

  @override
  String get rewardedFreeNote => 'Puedes hacerlo ahora mismo, sin anuncio.';

  @override
  String get gameSkipped => 'Nivel saltado';
}
