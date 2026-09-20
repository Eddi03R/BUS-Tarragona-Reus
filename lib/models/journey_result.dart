import 'package:flutter/material.dart';

/// Un possibile viaggio trovato per una ricerca origine/destinazione.
class JourneyResult {
  final String directionCode; // "RT" / "TR"
  final String directionLabel;
  final TimeOfDay departureTime;
  final TimeOfDay arrivalTime;
  final Duration travelTime;

  JourneyResult({
    required this.directionCode,
    required this.directionLabel,
    required this.departureTime,
    required this.arrivalTime,
    required this.travelTime,
  });

  int get departureMinutes => departureTime.hour * 60 + departureTime.minute;
  int get arrivalMinutes => arrivalTime.hour * 60 + arrivalTime.minute;
}
