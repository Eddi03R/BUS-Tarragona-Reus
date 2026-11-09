import 'dart:convert';
import 'dart:ui' show Locale, PlatformDispatcher;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/schedule_repository.dart';
import 'calendar_resolver.dart';
import 'journey_planner.dart';
import 'locale_controller.dart';
import 'my_places_controller.dart';

/// Una corsa pronta per il widget: partenza e arrivo.
class WidgetTrip {
  final DateTime departure;
  final DateTime arrival;
  const WidgetTrip(this.departure, this.arrival);
}

/// Prepara per il widget Android le prossime corse di "Casa" e "Fermata
/// abituale" e le salva in SharedPreferences, dove il widget le legge anche
/// quando l'app è chiusa. Copre 72 ore, quindi resta valido per qualche giorno.
class WidgetSync with WidgetsBindingObserver {
  WidgetSync._();
  static final WidgetSync instance = WidgetSync._();

  static const _channel = MethodChannel('app.lumelabs.bustarragona/widget');
  static const _prefKey = 'widget_data';
  static const hoursAhead = 72;
  static const maxTrips = 10;

  bool _started = false;

  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void start() {
    if (!_supported || _started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    MyPlacesController.instance.addListener(sync);
    LocaleController.instance.addListener(sync);
    sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed || state == AppLifecycleState.paused) sync();
  }

  /// Corse future da [originId] a [destinationId] nelle prossime [hoursAhead] ore,
  /// considerando orari diurni, festivi e servizi notturni (NT2/NT3 solo se attivi).
  static List<WidgetTrip> upcoming(
    ScheduleRepository repo,
    String originId,
    String destinationId,
    DateTime now,
  ) {
    final planner = JourneyPlanner(repo);
    final limit = now.add(const Duration(hours: hoursAhead));
    final found = <int, WidgetTrip>{};

    void add(DateTime dep, Duration travel) {
      if (dep.isBefore(now) || dep.isAfter(limit)) return;
      found[dep.millisecondsSinceEpoch] = WidgetTrip(dep, dep.add(travel));
    }

    for (var d = -1; d <= hoursAhead ~/ 24 + 1; d++) {
      final base = DateTime(now.year, now.month, now.day + d);

      // Servizio diurno (feriale / sabato / domenica / festivo)
      final dayCal = CalendarResolver.calendarIdFor(CalendarResolver.dayTypeFor(base));
      for (final r in planner.search(
        calendarId: dayCal,
        originId: originId,
        destinationId: destinationId,
        mode: SearchMode.departAfter,
        reference: const TimeOfDay(hour: 0, minute: 0),
      )) {
        add(DateTime(base.year, base.month, base.day, r.departureTime.hour, r.departureTime.minute),
            r.travelTime);
      }

      // Servizi notturni della "notte di" [base]: dalle 12:00 in poi stesso giorno,
      // prima di mezzogiorno il giorno dopo.
      final eve = DateTime(base.year, base.month, base.day, 23, 30);
      final nights = <String>[
        'night',
        if (CalendarResolver.isNightSalouAvailable(eve)) 'night_salou',
        if (CalendarResolver.isNightNt3Available(eve)) 'night_nt3',
      ];
      for (final cal in nights) {
        for (final r in planner.search(
          calendarId: cal,
          originId: originId,
          destinationId: destinationId,
          mode: SearchMode.departAfter,
          reference: const TimeOfDay(hour: 12, minute: 0),
        )) {
          final after = r.departureTime.hour < 12 ? 1 : 0;
          add(
            DateTime(base.year, base.month, base.day + after, r.departureTime.hour,
                r.departureTime.minute),
            r.travelTime,
          );
        }
      }
    }
    final list = found.values.toList()
      ..sort((a, b) => a.departure.compareTo(b.departure));
    return list.take(maxTrips).toList();
  }

  Future<AppLocalizations> _l10n() async {
    final wanted = LocaleController.instance.locale ?? PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales
        .where((l) => l.languageCode == wanted.languageCode);
    return AppLocalizations.delegate.load(supported.isNotEmpty ? supported.first : const Locale('en'));
  }

  Future<void> sync() async {
    if (!_supported) return;
    try {
      final repo = ScheduleRepository.instance;
      if (!repo.isLoaded) return;
      final l = await _l10n();
      final places = MyPlacesController.instance;
      final labels = {
        'inPrefix': l.widgetInPrefix,
        'minSuffix': l.widgetMinSuffix,
        'noTrips': l.widgetNoTrips,
        'setup': l.configureMyRoutesSub,
      };
      final Map<String, dynamic> data;
      if (!places.configured) {
        data = {'configured': false, 'labels': labels};
      } else {
        final now = DateTime.now();
        final home = repo.stopById(places.homeStopId!);
        final usual = repo.stopById(places.usualStopId!);
        Map<String, dynamic> route(String title, String from, String to) => {
              'title': '$title  ·  ${repo.stopById(from).city} → ${repo.stopById(to).city}',
              'times': [
                for (final t in upcoming(repo, from, to, now))
                  [t.departure.millisecondsSinceEpoch, t.arrival.millisecondsSinceEpoch],
              ],
            };
        data = {
          'configured': true,
          'labels': labels,
          'routes': [
            route(l.backHome, usual.id, home.id),
            route(l.goToUsual, home.id, usual.id),
          ],
        };
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode(data));
      await _channel.invokeMethod<void>('refresh');
    } catch (e) {
      debugPrint('Widget sync failed: $e');
    }
  }
}
