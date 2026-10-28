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
  String get lastBusBadge => 'Último bus de la noche';

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
  String shareText(Object origin, Object destination, Object dep, Object arr,
      Object minutes, Object calendar) {
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
  String get subscription => 'Abono';

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
      'Los mosaicos del mapa son proporcionados por OpenStreetMap (tile.openstreetmap.org). No se transmiten datos personales en estas solicitudes.';

  @override
  String get privacyViewOnline => 'Ver política de privacidad completa';
}
