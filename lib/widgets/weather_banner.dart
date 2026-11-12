import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../models/stop.dart';
import '../services/weather_service.dart';

/// Avviso meteo in home (accanto al promemoria dell'abbonamento): pioggia alla
/// partenza o alla destinazione, oppure una bella giornata di sole.
class WeatherBanner extends StatefulWidget {
  final Stop? origin;
  final Stop? destination;
  const WeatherBanner({super.key, this.origin, this.destination});

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> {
  WeatherAdvice? _advice;
  String _loadedFor = '';

  String get _signature => '${widget.origin?.id}|${widget.destination?.id}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant WeatherBanner old) {
    super.didUpdateWidget(old);
    if (_signature != _loadedFor) _load();
  }

  Future<void> _load() async {
    final o = widget.origin, d = widget.destination;
    final sig = _signature;
    _loadedFor = sig;
    if (o == null && d == null) {
      if (_advice != null) setState(() => _advice = null);
      return;
    }
    final ws = WeatherService.instance;
    final results = await Future.wait([
      o == null ? Future.value(null) : ws.at(o.lat, o.lng),
      d == null ? Future.value(null) : ws.at(d.lat, d.lng),
    ]);
    if (!mounted || sig != _loadedFor) return;
    setState(() {
      _advice = pickAdvice(
        origin: results[0],
        originPlace: o?.city,
        destination: results[1],
        destinationPlace: d?.city,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final a = _advice;
    if (a == null) return const SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    final rain = a.kind != WeatherKind.sunny;
    final color = rain ? Colors.blue[700]! : Colors.orange[800]!;
    final text = switch (a.kind) {
      WeatherKind.rainingNow => l.weatherRainingNow(a.place, a.temp),
      WeatherKind.maybeRain => l.weatherMaybeRain(a.temp),
      WeatherKind.sunny => l.weatherSunny(a.temp),
    };
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(rain ? Icons.umbrella_rounded : Icons.wb_sunny_rounded, size: 20, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
