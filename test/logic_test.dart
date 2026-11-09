import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/data/schedule_repository.dart';
import 'package:reus_tarragona_bus/services/calendar_resolver.dart';
import 'package:reus_tarragona_bus/services/journey_planner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CalendarResolver', () {
    test('giorno della settimana → calendario', () {
      expect(CalendarResolver.dayTypeFor(DateTime(2026, 11, 9)), DayType.weekday); // lunedì
      expect(CalendarResolver.dayTypeFor(DateTime(2026, 11, 14)), DayType.saturday);
      expect(CalendarResolver.dayTypeFor(DateTime(2026, 11, 15)), DayType.sunday);
      expect(CalendarResolver.dayTypeFor(DateTime(2026, 8, 12)), DayType.weekdayAugust);
      expect(CalendarResolver.dayTypeFor(DateTime(2026, 8, 15)), DayType.saturday);
    });

    test('fascia notturna: dalle 23:00 alle 07:30', () {
      expect(CalendarResolver.calendarIdForDateTime(DateTime(2026, 11, 9, 23, 0)), 'night');
      expect(CalendarResolver.calendarIdForDateTime(DateTime(2026, 11, 10, 2, 0)), 'night');
      expect(CalendarResolver.calendarIdForDateTime(DateTime(2026, 11, 10, 7, 29)), 'night');
      expect(CalendarResolver.calendarIdForDateTime(DateTime(2026, 11, 10, 7, 30)), 'weekday');
      expect(CalendarResolver.calendarIdForDateTime(DateTime(2026, 11, 9, 22, 59)), 'weekday');
    });

    test('NT2 Reus–Salou: lug-ago ogni notte, altrimenti ven/sab notte', () {
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 7, 14, 23, 30)), isTrue);
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 11, 13, 23, 30)), isTrue); // ven
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 11, 14, 23, 30)), isTrue); // sab
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 11, 11, 23, 30)), isFalse); // mer
      // sabato alle 02:00 appartiene alla notte di venerdì
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 11, 14, 2, 0)), isTrue);
      // lunedì alle 02:00 appartiene alla notte di domenica
      expect(CalendarResolver.isNightSalouAvailable(DateTime(2026, 11, 16, 2, 0)), isFalse);
    });

    test('NT3 circolare: solo ven/sab notte, tutto l\'anno', () {
      expect(CalendarResolver.isNightNt3Available(DateTime(2026, 7, 14, 23, 30)), isFalse);
      expect(CalendarResolver.isNightNt3Available(DateTime(2026, 7, 17, 23, 30)), isTrue);
      expect(CalendarResolver.isNightNt3Available(DateTime(2026, 11, 15, 1, 0)), isTrue); // notte di sabato
    });
  });

  group('JourneyPlanner', () {
    late ScheduleRepository repo;
    late JourneyPlanner planner;

    setUpAll(() async {
      repo = ScheduleRepository.instance;
      await repo.load();
      planner = JourneyPlanner(repo);
    });

    const calendars = [
      'weekday', 'weekday_august', 'saturday', 'sunday',
      'night', 'night_salou', 'night_nt3',
    ];

    test('parseTime', () {
      expect(JourneyPlanner.parseTime('7:05'), const TimeOfDay(hour: 7, minute: 5));
      expect(JourneyPlanner.parseTime('-'), isNull);
      expect(JourneyPlanner.parseTime(''), isNull);
      expect(JourneyPlanner.parseTime('abc'), isNull);
    });

    for (final cal in calendars) {
      test('$cal: ogni direzione ha corse e le ricerche sono coerenti', () {
        final dirs = repo.calendar(cal).directions.values;
        expect(dirs, isNotEmpty);
        var checked = 0;
        for (final dir in dirs) {
          final first = dir.stopIds.first;
          final last = dir.stopIds.last;
          // Dall'inizio: tutte le corse partono dopo l'orario di riferimento.
          const ref = TimeOfDay(hour: 0, minute: 0);
          final res = planner.search(
            calendarId: cal,
            originId: first,
            destinationId: last,
            mode: SearchMode.departAfter,
            reference: cal.startsWith('night') ? const TimeOfDay(hour: 22, minute: 0) : ref,
          );
          if (res.isEmpty) continue;
          checked++;
          for (final r in res) {
            expect(r.servedStops.first.stopId, first);
            expect(r.servedStops.last.stopId, last);
            expect(r.travelTime.inMinutes, greaterThanOrEqualTo(0));
            expect(r.travelTime.inMinutes, lessThan(180), reason: '$cal $first→$last');
          }
          // Ordinate per partenza crescente (con scavalco della mezzanotte).
          int svc(TimeOfDay t) =>
              (cal.startsWith('night') && t.hour < 12) ? t.hour * 60 + t.minute + 1440 : t.hour * 60 + t.minute;
          for (var i = 1; i < res.length; i++) {
            expect(svc(res[i].departureTime), greaterThanOrEqualTo(svc(res[i - 1].departureTime)));
          }
          expect(planner.directionFor(cal, first, last), dir.code);
          // direzione inversa non collegata
          expect(planner.directionFor(cal, last, first) == dir.code, isFalse);
        }
        expect(checked, greaterThan(0), reason: '$cal: nessuna ricerca ha dato risultati');
      });
    }

    test('arriveBy: tutti gli arrivi sono entro l\'orario e in ordine decrescente', () {
      final dir = repo.calendar('weekday').directions.values.first;
      final res = planner.search(
        calendarId: 'weekday',
        originId: dir.stopIds.first,
        destinationId: dir.stopIds.last,
        mode: SearchMode.arriveBy,
        reference: const TimeOfDay(hour: 12, minute: 0),
      );
      expect(res, isNotEmpty);
      int m(TimeOfDay t) => t.hour * 60 + t.minute;
      for (final r in res) {
        expect(m(r.arrivalTime), lessThanOrEqualTo(12 * 60));
      }
      for (var i = 1; i < res.length; i++) {
        expect(m(res[i].arrivalTime), lessThanOrEqualTo(m(res[i - 1].arrivalTime)));
      }
    });

    test('notte: le corse dopo mezzanotte seguono quelle prima di mezzanotte', () {
      final dir = repo.calendar('night_salou').directions['RS']!;
      final res = planner.search(
        calendarId: 'night_salou',
        originId: dir.stopIds.first,
        destinationId: 'pl_europa_salou',
        mode: SearchMode.departAfter,
        reference: const TimeOfDay(hour: 22, minute: 0),
      );
      expect(res, isNotEmpty);
      expect(res.first.departureTime.hour, greaterThanOrEqualTo(22));
      expect(res.last.departureTime.hour, lessThan(12), reason: 'ultima corsa dopo mezzanotte');
    });

    test('Flash Back e Tropical: Plaça Europa raggiungibile di notte da Reus', () {
      final res = planner.search(
        calendarId: 'night_salou',
        originId: 'reus_centre',
        destinationId: 'pl_europa_salou',
        mode: SearchMode.departAfter,
        reference: const TimeOfDay(hour: 22, minute: 0),
      );
      expect(res.map((r) => '${r.departureTime.hour}:${r.departureTime.minute}'), isNotEmpty);
      expect(res.first.arrivalTime.hour, anyOf(23, 0));
    });
  });
}
