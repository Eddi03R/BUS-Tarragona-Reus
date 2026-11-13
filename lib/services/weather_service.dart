import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Meteo attuale e probabilità di pioggia a breve in un punto.
class WeatherInfo {
  final int temp;
  final bool rainingNow;
  final int rainChanceNext3h; // 0-100
  final bool sunny; // cielo sereno di giorno
  const WeatherInfo({
    required this.temp,
    required this.rainingNow,
    required this.rainChanceNext3h,
    required this.sunny,
  });
}

enum WeatherKind { rainingNow, maybeRain, sunny }

/// Cosa mostrare in home (e per quale luogo), se c'è qualcosa da dire.
class WeatherAdvice {
  final WeatherKind kind;
  final String place;
  final int temp;
  const WeatherAdvice(this.kind, this.place, this.temp);
}

/// Sceglie l'avviso più utile tra partenza e destinazione:
/// piove ora (destinazione prima) > potrebbe piovere > bel tempo.
WeatherAdvice? pickAdvice({
  WeatherInfo? origin,
  String? originPlace,
  WeatherInfo? destination,
  String? destinationPlace,
  bool rainOnly = false,
}) {
  final entries = <(WeatherInfo, String)>[
    if (destination != null) (destination, destinationPlace ?? ''),
    if (origin != null) (origin, originPlace ?? ''),
  ];
  for (final (w, place) in entries) {
    if (w.rainingNow) return WeatherAdvice(WeatherKind.rainingNow, place, w.temp);
  }
  for (final (w, place) in entries) {
    if (w.rainChanceNext3h >= 50) return WeatherAdvice(WeatherKind.maybeRain, place, w.temp);
  }
  if (rainOnly) return null;
  for (final (w, place) in entries) {
    if (w.sunny) return WeatherAdvice(WeatherKind.sunny, place, w.temp);
  }
  return null;
}

/// Trasforma la risposta di Open-Meteo in [WeatherInfo].
WeatherInfo? parseOpenMeteo(Map<String, dynamic> json) {
  final cur = json['current'] as Map<String, dynamic>?;
  if (cur == null) return null;
  final temp = (cur['temperature_2m'] as num?)?.round();
  if (temp == null) return null;
  final code = (cur['weather_code'] as num?)?.toInt() ?? -1;
  final precip = (cur['precipitation'] as num?)?.toDouble() ?? 0;
  final isDay = (cur['is_day'] as num?)?.toInt() == 1;
  // 51-67 pioggerella/pioggia, 80-82 rovesci, 95-99 temporali
  final rainCode = (code >= 51 && code <= 67) || (code >= 80 && code <= 82) || code >= 95;
  final hourly = (json['hourly'] as Map<String, dynamic>?)?['precipitation_probability'] as List?;
  var chance = 0;
  if (hourly != null) {
    for (final v in hourly.take(3)) {
      if (v is num && v > chance) chance = v.round();
    }
  }
  return WeatherInfo(
    temp: temp,
    rainingNow: rainCode || precip >= 0.1,
    rainChanceNext3h: chance,
    sunny: isDay && (code == 0 || code == 1),
  );
}

/// Meteo da Open-Meteo (gratuito, senza chiave). Risposte in cache per 15
/// minuti; in caso di errore o rete assente restituisce null senza rumore.
class WeatherService {
  WeatherService._();
  static final WeatherService instance = WeatherService._();

  /// Sostituibile nei test.
  @visibleForTesting
  Future<String?> Function(Uri url) fetcher = _defaultFetch;

  static Future<String?> _defaultFetch(Uri url) async {
    try {
      final r = await http.get(url).timeout(const Duration(seconds: 6));
      return r.statusCode == 200 ? r.body : null;
    } catch (_) {
      return null;
    }
  }

  final Map<String, (DateTime, WeatherInfo?)> _cache = {};

  Future<WeatherInfo?> at(double lat, double lng) async {
    final key = '${lat.toStringAsFixed(2)},${lng.toStringAsFixed(2)}';
    final hit = _cache[key];
    if (hit != null && DateTime.now().difference(hit.$1) < const Duration(minutes: 15)) {
      return hit.$2;
    }
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toStringAsFixed(3),
      'longitude': lng.toStringAsFixed(3),
      'current': 'temperature_2m,precipitation,weather_code,is_day',
      'hourly': 'precipitation_probability',
      'forecast_hours': '3',
      'timezone': 'auto',
    });
    WeatherInfo? info;
    final body = await fetcher(url);
    if (body != null) {
      try {
        info = parseOpenMeteo(jsonDecode(body) as Map<String, dynamic>);
      } catch (_) {}
    }
    // Gli errori si ricordano per poco, così non si insiste a ogni schermata.
    _cache[key] = (info == null ? DateTime.now().subtract(const Duration(minutes: 12)) : DateTime.now(), info);
    return info;
  }
}
