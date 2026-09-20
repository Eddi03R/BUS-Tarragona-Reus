import 'package:flutter/material.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';

enum SearchMode { departAfter, arriveBy }

class JourneyPlanner {
  final ScheduleRepository repo;
  JourneyPlanner(this.repo);

  static TimeOfDay? parseTime(String value) {
    if (value == '-' || value.trim().isEmpty) return null;
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  static int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Il servizio notturno attraversa la mezzanotte (es. 23:30 -> 00:00): le
  /// ore dalla mezzanotte in poi vanno trattate come "giorno di servizio
  /// successivo" (convenzione comune nei trasporti, tipo GTFS con ore >24),
  /// altrimenti "0:04" sembrerebbe precedere "23:24" invece di seguirlo.
  static int _serviceMinutes(TimeOfDay t, bool overnight) {
    final m = _minutes(t);
    return (overnight && t.hour < 12) ? m + 24 * 60 : m;
  }

  /// Cerca tutte le corse utili tra [originId] e [destinationId] nel
  /// calendario [calendarId], in base al [mode] e all'orario di riferimento
  /// [reference] (partenza minima oppure arrivo massimo).
  List<JourneyResult> search({
    required String calendarId,
    required String originId,
    required String destinationId,
    required SearchMode mode,
    required TimeOfDay reference,
  }) {
    final calendar = repo.calendar(calendarId);
    final overnight = calendarId == 'night';
    final results = <JourneyResult>[];
    final referenceMin = _serviceMinutes(reference, overnight);

    for (final dir in calendar.directions.values) {
      final oIdx = dir.indexOfStop(originId);
      final dIdx = dir.indexOfStop(destinationId);
      if (oIdx == -1 || dIdx == -1 || oIdx >= dIdx) continue;

      for (final trip in dir.trips) {
        final depStr = trip[oIdx];
        final arrStr = trip[dIdx];
        final dep = parseTime(depStr);
        final arr = parseTime(arrStr);
        if (dep == null || arr == null) continue;

        final depMin = _serviceMinutes(dep, overnight);
        final arrMin = _serviceMinutes(arr, overnight);
        if (arrMin < depMin) continue; // riga incoerente, scarta

        if (mode == SearchMode.departAfter) {
          if (depMin < referenceMin) continue;
        } else {
          if (arrMin > referenceMin) continue;
        }

        results.add(JourneyResult(
          directionCode: dir.code,
          directionLabel: dir.label,
          departureTime: dep,
          arrivalTime: arr,
          travelTime: Duration(minutes: arrMin - depMin),
        ));
      }
    }

    if (mode == SearchMode.departAfter) {
      results.sort((a, b) => _serviceMinutes(a.departureTime, overnight)
          .compareTo(_serviceMinutes(b.departureTime, overnight)));
    } else {
      results.sort((a, b) => _serviceMinutes(b.arrivalTime, overnight)
          .compareTo(_serviceMinutes(a.arrivalTime, overnight)));
    }

    return results;
  }

  /// Direzione (RT/TR) che collega le due fermate nel calendario dato,
  /// oppure null se non esiste una corsa diretta in quell'ordine.
  String? directionFor(String calendarId, String originId, String destinationId) {
    final calendar = repo.calendar(calendarId);
    for (final dir in calendar.directions.values) {
      final oIdx = dir.indexOfStop(originId);
      final dIdx = dir.indexOfStop(destinationId);
      if (oIdx != -1 && dIdx != -1 && oIdx < dIdx) return dir.code;
    }
    return null;
  }
}
