import 'package:flutter/material.dart';

/// Una fermata realmente servita da una corsa, con il relativo orario di passaggio.
class ServedStop {
  final String stopId;
  final TimeOfDay time;
  const ServedStop({required this.stopId, required this.time});
}

/// Un possibile viaggio trovato per una ricerca origine/destinazione.
class JourneyResult {
  final String directionCode; // "RT" / "TR"
  final String directionLabel;
  final TimeOfDay departureTime;
  final TimeOfDay arrivalTime;
  final Duration travelTime;

  /// Tutte le fermate realmente servite da questa corsa tra origine e
  /// destinazione (inclusi entrambi gli estremi): alcune corse sono
  /// dirette/espresse e saltano molte fermate intermedie, altre le fanno
  /// quasi tutte, come si vede dal PDF ufficiale (colonne con "-").
  final List<ServedStop> servedStops;

  JourneyResult({
    required this.directionCode,
    required this.directionLabel,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelTime,
    required this.servedStops,
  });

  int get departureMinutes => departureTime.hour * 60 + departureTime.minute;
  int get arrivalMinutes => arrivalTime.hour * 60 + arrivalTime.minute;
}
