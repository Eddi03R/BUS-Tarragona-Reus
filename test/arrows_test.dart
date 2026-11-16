import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/games/logic/arrows_logic.dart';
import 'package:reus_tarragona_bus/games/wordle_screen.dart';

void main() {
  group('Frecce', () {
    for (var d = 0; d < 3; d++) {
      test('difficoltà $d: livelli validi, sempre risolvibili e non banali', () {
        for (var lv = 1; lv <= 25; lv++) {
          final l = ArrowsLogic.generate(d, lv);
          final (n, maxLen) = ArrowsLogic.paramsFor(d);
          expect(l.n, n);
          expect(l.arrows.length, greaterThanOrEqualTo(6));
          final all = l.arrows.expand((a) => a.cells).toList();
          expect(all.toSet().length, all.length, reason: 'frecce sovrapposte');
          for (final a in l.arrows) {
            expect(a.cells.length, inInclusiveRange(2, maxLen));
            for (var i = 1; i < a.cells.length; i++) {
              final dx = a.cells[i] % n - a.cells[i - 1] % n;
              final dy = a.cells[i] ~/ n - a.cells[i - 1] ~/ n;
              expect(dx.abs() + dy.abs(), 1);
              if (i == a.cells.length - 1) expect((dx, dy), (a.dx, a.dy));
            }
          }
          final removed = List<bool>.filled(l.arrows.length, false);
          // all'inizio almeno una freccia è bloccata e almeno una è libera
          final free = [for (var i = 0; i < l.arrows.length; i++) l.canExit(i, removed)];
          expect(free.contains(true), isTrue);
          expect(free.contains(false), isTrue);
          // la strada di una freccia non passa mai sul suo stesso corpo
          for (var i = 0; i < l.arrows.length; i++) {
            expect(l.ray(i).any(l.arrows[i].cells.contains), isFalse);
          }
          for (final i in l.solution) {
            expect(l.canExit(i, removed), isTrue, reason: 'livello $lv non risolvibile');
            removed[i] = true;
          }
          expect(removed.every((r) => r), isTrue);
        }
      });
    }

    test('stesso livello = stesso schema; una freccia bloccata dice dopo quante caselle', () {
      final a = ArrowsLogic.generate(1, 3), b = ArrowsLogic.generate(1, 3);
      expect([for (final x in a.arrows) x.cells], [for (final x in b.arrows) x.cells]);
      final removed = List<bool>.filled(a.arrows.length, false);
      final blocked = [
        for (var i = 0; i < a.arrows.length; i++)
          if (!a.canExit(i, removed)) i
      ].first;
      expect(a.blockedAfter(blocked, removed), isNotNull);
      expect(a.blockedAfter(blocked, removed)!, lessThan(a.ray(blocked).length));
    });
  });

  test('Parola casuale: tentativi per difficoltà', () {
    expect(WordleScreen.attemptsFor(Difficulty.easy), 7);
    expect(WordleScreen.attemptsFor(Difficulty.medium), 6);
    expect(WordleScreen.attemptsFor(Difficulty.hard), 5);
  });
}
