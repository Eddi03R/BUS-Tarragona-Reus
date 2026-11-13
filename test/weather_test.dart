import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/services/weather_service.dart';

void main() {
  Map<String, dynamic> resp({int code = 3, double precip = 0, int day = 1, double t = 17.6, List<int>? chance}) => {
        'current': {'temperature_2m': t, 'precipitation': precip, 'weather_code': code, 'is_day': day},
        'hourly': {'precipitation_probability': chance ?? [0, 0, 0]},
      };

  test('parse: pioggia in corso, probabile, sole', () {
    expect(parseOpenMeteo(resp(code: 61))!.rainingNow, isTrue);
    expect(parseOpenMeteo(resp(precip: 0.4))!.rainingNow, isTrue);
    expect(parseOpenMeteo(resp(code: 95))!.rainingNow, isTrue);
    final maybe = parseOpenMeteo(resp(chance: [10, 70, 20]))!;
    expect(maybe.rainingNow, isFalse);
    expect(maybe.rainChanceNext3h, 70);
    expect(parseOpenMeteo(resp(code: 0))!.sunny, isTrue);
    expect(parseOpenMeteo(resp(code: 0, day: 0))!.sunny, isFalse, reason: 'di notte niente "giornata di sole"');
    expect(parseOpenMeteo(resp(code: 3))!.sunny, isFalse);
    expect(parseOpenMeteo(resp(t: 17.6))!.temp, 18);
    expect(parseOpenMeteo({'x': 1}), isNull);
  });

  WeatherInfo w({int t = 15, bool rain = false, int chance = 0, bool sun = false}) =>
      WeatherInfo(temp: t, rainingNow: rain, rainChanceNext3h: chance, sunny: sun);

  test('avviso: priorità e luogo', () {
    // piove alla destinazione: vince, col nome della destinazione
    var a = pickAdvice(origin: w(sun: true), originPlace: 'Reus', destination: w(rain: true, t: 11), destinationPlace: 'Salou')!;
    expect(a.kind, WeatherKind.rainingNow);
    expect(a.place, 'Salou');
    expect(a.temp, 11);
    // piove solo alla partenza
    a = pickAdvice(origin: w(rain: true), originPlace: 'Reus', destination: w(), destinationPlace: 'Salou')!;
    expect(a.place, 'Reus');
    // potrebbe piovere (>= 50%)
    a = pickAdvice(origin: w(chance: 60), originPlace: 'Reus')!;
    expect(a.kind, WeatherKind.maybeRain);
    expect(pickAdvice(origin: w(chance: 49)), isNull);
    // bel tempo
    a = pickAdvice(origin: w(sun: true, t: 18), originPlace: 'Reus')!;
    expect(a.kind, WeatherKind.sunny);
    expect(a.temp, 18);
    expect(pickAdvice(), isNull);
  });

  test('Nightlife: solo pioggia (niente sole)', () {
    expect(pickAdvice(origin: w(sun: true, t: 18), originPlace: 'Reus', rainOnly: true), isNull);
    final a = pickAdvice(destination: w(rain: true, t: 9), destinationPlace: 'Salou', rainOnly: true)!;
    expect(a.kind, WeatherKind.rainingNow);
    expect(a.place, 'Salou');
    expect(pickAdvice(origin: w(chance: 80), originPlace: 'Reus', rainOnly: true)!.kind, WeatherKind.maybeRain);
  });

  test('servizio: cache e errori silenziosi', () async {
    final ws = WeatherService.instance;
    var calls = 0;
    ws.fetcher = (url) async {
      calls++;
      expect(url.host, 'api.open-meteo.com');
      return '{"current":{"temperature_2m":12.2,"precipitation":0,"weather_code":0,"is_day":1},"hourly":{"precipitation_probability":[0,0,0]}}';
    };
    final a = await ws.at(41.1187, 1.2454);
    final b = await ws.at(41.1187, 1.2454);
    expect(a!.temp, 12);
    expect(identical(a, b), isTrue);
    expect(calls, 1);
    ws.fetcher = (_) async => null;
    expect(await ws.at(40.0, 1.0), isNull);
  });
}
