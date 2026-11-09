import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Controlli di coerenza sui dati (fermate, orari, luoghi). Leggono i JSON
/// direttamente: se un orario o un riferimento è sbagliato, il test lo dice.
Map<String, dynamic> _json(String name) =>
    jsonDecode(File('assets/data/$name').readAsStringSync()) as Map<String, dynamic>;

final _timeRe = RegExp(r'^\d{1,2}:\d{2}$');
int _mins(String t) {
  final p = t.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

void main() {
  final stops = (_json('stops.json')['stops'] as List).cast<Map<String, dynamic>>();
  final stopIds = stops.map((s) => s['id'] as String).toSet();

  test('fermate: id unici e coordinate nella zona Reus-Tarragona-Salou', () {
    expect(stopIds.length, stops.length, reason: 'id fermata duplicati');
    for (final s in stops) {
      final lat = (s['lat'] as num).toDouble();
      final lng = (s['lng'] as num).toDouble();
      expect(lat, inInclusiveRange(40.9, 41.3), reason: '${s['id']} lat fuori zona');
      expect(lng, inInclusiveRange(0.9, 1.5), reason: '${s['id']} lng fuori zona');
      expect((s['name'] as String).trim(), isNotEmpty);
    }
  });

  final timetables = [
    'timetable_weekday.json',
    'timetable_weekday_august.json',
    'timetable_saturday.json',
    'timetable_sunday.json',
    'timetable_night.json',
    'timetable_night_salou.json',
    'timetable_night_nt3.json',
  ];

  for (final file in timetables) {
    group('orari $file', () {
      final data = _json(file);
      final night = (data['calendarId'] as String).startsWith('night');
      final dirs = (data['directions'] as Map<String, dynamic>);

      test('ha almeno una direzione e un calendarId', () {
        expect(data['calendarId'], isA<String>());
        expect(dirs, isNotEmpty);
      });

      dirs.forEach((code, dir) {
        final ids = (dir['stops'] as List).cast<String>();
        final trips = (dir['trips'] as List).map((t) => (t as List).cast<String>()).toList();

        test('$code: tutte le fermate esistono in stops.json', () {
          for (final id in ids) {
            expect(stopIds, contains(id), reason: 'fermata sconosciuta: $id');
          }
        });

        test('$code: nessuna fermata ripetuta', () {
          expect(ids.toSet().length, ids.length);
        });

        test('$code: ogni corsa ha una colonna per fermata e orari validi', () {
          expect(trips, isNotEmpty);
          for (var i = 0; i < trips.length; i++) {
            final t = trips[i];
            expect(t.length, ids.length, reason: 'corsa #$i: colonne != fermate');
            for (final v in t) {
              expect(v == '-' || _timeRe.hasMatch(v), isTrue,
                  reason: 'corsa #$i: orario non valido "$v"');
            }
            expect(t.where((v) => v != '-').length, greaterThanOrEqualTo(2),
                reason: 'corsa #$i: meno di 2 fermate servite');
          }
        });

        test('$code: gli orari di ogni corsa non tornano indietro', () {
          for (var i = 0; i < trips.length; i++) {
            var prev = -1;
            for (final v in trips[i]) {
              if (v == '-') continue;
              var m = _mins(v);
              if (night && m < 12 * 60) m += 24 * 60; // dopo mezzanotte
              expect(m, greaterThanOrEqualTo(prev),
                  reason: 'corsa #$i: orario $v precede il precedente');
              prev = m;
            }
          }
        });
      });
    });
  }

  group('luoghi (poi.json)', () {
    final pois = (_json('poi.json')['pois'] as List).cast<Map<String, dynamic>>();

    test('id unici e categorie valide', () {
      expect(pois.map((p) => p['id']).toSet().length, pois.length);
      for (final p in pois) {
        expect(['nightlife', 'university'], contains(p['category']), reason: '${p['id']}');
      }
    });

    test('fermate di riferimento esistenti', () {
      for (final p in pois) {
        expect(stopIds, contains(p['nearestStopId']), reason: '${p['id']} nearestStopId');
        if (p['returnStopId'] != null) {
          expect(stopIds, contains(p['returnStopId']), reason: '${p['id']} returnStopId');
        }
        expect(p['walkMinutes'] as int, greaterThanOrEqualTo(0));
      }
    });

    test('coordinate nella zona e fermata consigliata valida', () {
      for (final p in pois) {
        expect((p['lat'] as num).toDouble(), inInclusiveRange(40.9, 41.3), reason: '${p['id']}');
        expect((p['lng'] as num).toDouble(), inInclusiveRange(0.9, 1.5), reason: '${p['id']}');
        final d = p['dropoff'] as Map<String, dynamic>?;
        if (d != null) {
          expect((d['name'] as String).trim(), isNotEmpty);
          expect((d['lat'] as num).toDouble(), inInclusiveRange(40.9, 41.3));
          expect((d['lng'] as num).toDouble(), inInclusiveRange(0.9, 1.5));
          expect(d['walkMinutes'] as int, greaterThan(0));
        }
      }
    });

    test('Tropical, Enjoy e Flash Back: fermata e coordinate attese', () {
      Map<String, dynamic> byId(String id) => pois.firstWhere((p) => p['id'] == id);
      expect(byId('tropical_salou')['dropoff'], isNotNull);
      expect(byId('enjoy_salou')['dropoff'], isNotNull);
      final fb = byId('flashback_salou');
      expect(fb['nearestStopId'], 'pl_europa_salou');
      expect((fb['lat'] as num).toDouble(), closeTo(41.0769861, 1e-6));
      expect((fb['lng'] as num).toDouble(), closeTo(1.1460503, 1e-6));
    });
  });
}
