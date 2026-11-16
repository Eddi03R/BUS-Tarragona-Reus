import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/logic/block_logic.dart';
import 'package:reus_tarragona_bus/games/logic/flow_logic.dart';
import 'package:reus_tarragona_bus/games/logic/game2048_logic.dart';
import 'package:reus_tarragona_bus/games/logic/memory_logic.dart';
import 'package:reus_tarragona_bus/games/logic/wordle_logic.dart';
import 'package:reus_tarragona_bus/games/logic/wordle_words.dart';

void main() {
  group('Blocchi 1010', () {
    test('pezzi: facile solo piccoli, ogni pezzo ha celle valide', () {
      for (var d = 0; d < 3; d++) {
        final r = Random(d);
        for (var i = 0; i < 200; i++) {
          final p = BlockLogic.randomPiece(r, d);
          expect(p.cells, isNotEmpty);
          if (d == 0) expect(p.cells.length, lessThanOrEqualTo(4));
          expect(p.width, lessThanOrEqualTo(5));
        }
      }
    });

    test('posizionamento, limiti e sovrapposizioni', () {
      final grid = List<int>.filled(100, 0);
      final h5 = BlockPiece([for (var c = 0; c < 5; c++) (0, c)], 0);
      expect(BlockLogic.canPlace(grid, h5, 0, 5), isTrue);
      expect(BlockLogic.canPlace(grid, h5, 0, 6), isFalse, reason: 'esce a destra');
      expect(BlockLogic.canPlace(grid, h5, 10, 0), isFalse, reason: 'esce in basso');
      BlockLogic.place(grid, h5, 0, 0);
      expect(BlockLogic.canPlace(grid, h5, 0, 2), isFalse, reason: 'occupata');
    });

    test('righe e colonne complete si svuotano (anche insieme)', () {
      final grid = List<int>.filled(100, 0);
      // riga 0 piena tranne l'ultima cella, colonna 9 piena tranne la prima
      for (var c = 0; c < 9; c++) {
        grid[c] = 1;
      }
      for (var r = 1; r < 10; r++) {
        grid[r * 10 + 9] = 1;
      }
      const dot = BlockPiece([(0, 0)], 2);
      final lines = BlockLogic.place(grid, dot, 0, 9);
      expect(lines, 2);
      expect(grid.where((v) => v != 0), isEmpty);
    });

    test('punti: bonus per le combo', () {
      const dot = BlockPiece([(0, 0)], 0);
      expect(BlockLogic.points(dot, 0), 1);
      expect(BlockLogic.points(dot, 2), greaterThan(BlockLogic.points(dot, 1) * 2));
    });
  });

  group('2048', () {
    test('fusione di una riga', () {
      void check(List<int> line, List<int> expected, int gained) {
        final (merged, g) = Game2048.mergeLine(line);
        expect(merged, expected);
        expect(g, gained);
      }

      check([2, 2, 2, 2], [4, 4, 0, 0], 8);
      check([2, 0, 2, 4], [4, 4, 0, 0], 4);
      check([4, 2, 2, 0], [4, 4, 0, 0], 4);
      check([2, 4, 8, 16], [2, 4, 8, 16], 0);
    });

    test('mossa e nuovo numero', () {
      final g = Game2048.fromCells(4, [
        2, 2, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
      ], Random(1));
      expect(g.move(Dir2048.left), isTrue);
      expect(g.cells[0], 4);
      expect(g.score, 4);
      expect(g.cells.where((v) => v != 0).length, 2, reason: 'un nuovo numero compare');
    });

    test('mossa che non cambia nulla non fa apparire numeri', () {
      final g = Game2048.fromCells(4, [
        2, 4, 8, 16,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
      ], Random(1));
      expect(g.move(Dir2048.left), isFalse);
      expect(g.cells.where((v) => v != 0).length, 4);
    });

    test('animazione: le due tessere sommate scivolano nella stessa casella', () {
      final g = Game2048.fromCells(4, [
        2, 0, 2, 4,
        0, 0, 0, 0,
        0, 0, 0, 0,
        0, 0, 0, 0,
      ], Random(1));
      final a = g.ids[0], b = g.ids[2], four = g.ids[3];
      expect(g.move(Dir2048.left), isTrue);
      expect(g.ghosts.map((t) => t.id).toSet(), {a, b});
      expect(g.ghosts.every((t) => t.to == 0 && t.value == 2), isTrue);
      expect(g.mergedIds, {g.ids[0]});
      expect(g.ids[1], four, reason: 'la tessera non sommata mantiene la sua identità');
      expect(g.spawnedId, isNotNull);
      for (var i = 0; i < 16; i++) {
        expect(g.ids[i] == 0, g.cells[i] == 0);
      }
    });

    test('partita finita quando non ci sono mosse', () {
      final g = Game2048.fromCells(4, [
        2, 4, 2, 4,
        4, 2, 4, 2,
        2, 4, 2, 4,
        4, 2, 4, 2,
      ], Random(1));
      expect(g.canMove, isFalse);
      final h = Game2048.fromCells(4, [
        2, 4, 2, 4,
        4, 2, 4, 2,
        2, 4, 2, 4,
        4, 2, 4, 4,
      ], Random(1));
      expect(h.canMove, isTrue);
    });

    test('partita casuale: mosse a caso non rompono nulla (punteggio e valori)', () {
      final r = Random(3);
      for (final size in [3, 4, 5]) {
        final g = Game2048(size, r);
        for (var i = 0; i < 300 && g.canMove; i++) {
          g.move(Dir2048.values[r.nextInt(4)]);
          for (final v in g.cells) {
            expect(v == 0 || (v & (v - 1)) == 0, isTrue, reason: 'potenza di 2');
          }
        }
        expect(g.score, greaterThanOrEqualTo(0));
      }
    });
  });

  group('Memory', () {
    for (var d = 0; d < 3; d++) {
      test('difficoltà $d: ogni simbolo compare due volte', () {
        final pairs = MemoryLogic.pairsFor(d);
        final deck = MemoryLogic.deal(pairs, Random(d));
        expect(deck.length, pairs * 2);
        for (var s = 0; s < pairs; s++) {
          expect(deck.where((v) => v == s).length, 2);
        }
        expect(deck.length % MemoryLogic.columnsFor(d), 0);
      });
    }
  });

  group('Parola del giorno', () {
    test('liste: parole di 5 lettere a-z, senza doppioni, abbastanza lunghe', () {
      for (final e in wordleWords.entries) {
        expect(e.value.length, greaterThan(70), reason: e.key);
        expect(e.value.toSet().length, e.value.length, reason: '${e.key}: doppioni');
        for (final w in e.value) {
          expect(RegExp(r'^[a-z]{5}$').hasMatch(w), isTrue, reason: '${e.key}: $w');
        }
      }
      expect(wordleWords.keys.toSet(), {'it', 'en', 'es', 'ca', 'de'});
    });

    test('colori come Wordle, anche con lettere ripetute', () {
      List<LetterState> ev(String g, String a) => WordleLogic.evaluate(g, a);
      expect(ev('crane', 'crane'), List.filled(5, LetterState.correct));
      // "speed" contro "abide": la prima e è presente, la seconda no se una sola nella soluzione
      final r = ev('speed', 'abide');
      expect(r[2], LetterState.present); // e (prima occorrenza)
      expect(r[3], LetterState.absent); // e (seconda): in "abide" ce n'è una sola, già usata
      expect(r[0], LetterState.absent);
      expect(ev('ottoo', 'otter')[0], LetterState.correct);
    });

    test('parola del giorno: stabile nello stesso giorno, cambia col giorno', () {
      final d = DateTime(2026, 11, 10, 8);
      final same = WordleLogic.dailyWord('it', DateTime(2026, 11, 10, 23, 59));
      expect(WordleLogic.dailyWord('it', d), same);
      final next = WordleLogic.dailyWord('it', DateTime(2026, 11, 11));
      expect(next, isNot(same));
      // 30 giorni consecutivi: tutte diverse
      final week = {for (var i = 0; i < 30; i++) WordleLogic.dailyWord('en', d.add(Duration(days: i)))};
      expect(week.length, 30);
    });
  });

  group('Collega i punti', () {
    for (var d = 0; d < 3; d++) {
      test('difficoltà $d: soluzione che copre tutta la griglia', () {
        final r = Random(100 + d);
        for (var k = 0; k < 10; k++) {
          final p = FlowPuzzle.generate(d, r);
          final (n, maxColors) = FlowPuzzle.paramsFor(d);
          expect(p.endpoints.length, lessThanOrEqualTo(maxColors));
          expect(p.endpoints.length, greaterThanOrEqualTo(4));
          // una sola soluzione: unite le coppie, la griglia è per forza piena
          expect(p.solutionCount(maxNodes: 2000000), 1);
          final cells = p.solution.expand((s) => s).toList();
          expect(cells.length, n * n);
          expect(cells.toSet().length, n * n, reason: 'nessuna cella ripetuta');
          // ogni segmento è un percorso di celle adiacenti, lungo almeno 3
          for (final s in p.solution) {
            expect(s.length, greaterThanOrEqualTo(3));
            for (var i = 1; i < s.length; i++) {
              final dx = (s[i] % n - s[i - 1] % n).abs();
              final dy = (s[i] ~/ n - s[i - 1] ~/ n).abs();
              expect(dx + dy, 1);
            }
          }
        }
      });
    }

    test('rifare la soluzione disegnando la risolve ed è "perfetta"', () {
      final p = FlowPuzzle.generate(1, Random(5));
      final b = FlowBoard(p);
      expect(b.solved, isFalse);
      for (final s in p.solution) {
        b.begin(s.first);
        for (final c in s.skip(1)) {
          b.extend(c);
        }
        b.end();
      }
      expect(b.solved, isTrue);
      expect(b.perfect, isTrue);
    });

    test('attraversare un altro percorso lo interrompe; tornare indietro accorcia', () {
      final p = FlowPuzzle.generate(0, Random(8));
      final b = FlowBoard(p);
      final s0 = p.solution[0], s1 = p.solution[1];
      b.begin(s1.first);
      for (final c in s1.skip(1)) {
        b.extend(c);
      }
      b.end();
      expect(b.paths[1].length, s1.length);
      // percorso 0 che passa sopra una cella del percorso 1: se adiacente, lo interrompe
      b.begin(s0.first);
      b.extend(s0[1]);
      b.end();
      // tornare indietro
      b.begin(s0.first);
      b.extend(s0[1]);
      b.extend(s0.first);
      expect(b.paths[0].length, 1);
    });
  });
}
