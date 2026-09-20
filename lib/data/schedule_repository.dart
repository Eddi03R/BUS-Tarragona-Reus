import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/stop.dart';
import '../models/line_direction.dart';

/// Carica in memoria fermate e orari dagli asset JSON generati a partire
/// dall'orario ufficiale Monbus (linea e4 Reus - Tarragona).
class ScheduleRepository {
  ScheduleRepository._();
  static final ScheduleRepository instance = ScheduleRepository._();

  List<Stop> _stops = [];
  final Map<String, Calendar> _calendars = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<Stop> get stops => List.unmodifiable(_stops);

  Stop stopById(String id) => _stops.firstWhere((s) => s.id == id);

  Future<void> load() async {
    if (_loaded) return;

    final stopsRaw = await rootBundle.loadString('assets/data/stops.json');
    final stopsJson = jsonDecode(stopsRaw) as Map<String, dynamic>;
    _stops = (stopsJson['stops'] as List)
        .map((e) => Stop.fromJson(e as Map<String, dynamic>))
        .toList();

    for (final file in const [
      'assets/data/timetable_weekday.json',
      'assets/data/timetable_weekday_august.json',
      'assets/data/timetable_saturday.json',
      'assets/data/timetable_sunday.json',
      'assets/data/timetable_night.json',
    ]) {
      final raw = await rootBundle.loadString(file);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final calendar = Calendar.fromJson(json);
      _calendars[calendar.id] = calendar;
    }

    _loaded = true;
  }

  Calendar calendar(String calendarId) => _calendars[calendarId]!;

  /// Fermate effettivamente servite da almeno una direzione del calendario dato.
  List<Stop> stopsForCalendar(String calendarId) {
    final cal = calendar(calendarId);
    final ids = <String>{};
    for (final dir in cal.directions.values) {
      ids.addAll(dir.stopIds);
    }
    return _stops.where((s) => ids.contains(s.id)).toList();
  }
}
