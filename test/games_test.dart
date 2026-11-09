import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/logic/battleship_logic.dart';
import 'package:reus_tarragona_bus/games/logic/busjam_logic.dart';
import 'package:reus_tarragona_bus/games/logic/maze_logic.dart';
import 'package:reus_tarragona_bus/games/logic/sudoku_logic.dart';
import 'package:reus_tarragona_bus/games/logic/tictactoe_logic.dart';

void main() {
  group('Tris', () {
    test('vincitore e pareggio', () {
      final b = List<Mark>.filled(9, Mark.none);
      expect(TicTacToeLogic.winner(b), Mark.none);
      b[0] = b[1] = b[2] = Mark.x;
      expect(TicTacToeLogic.winner(b), Mark.x);
    });

    test('linea vincente', () {
      final b = List<Mark>.filled(9, Mark.none);
      expect(TicTacToeLogic.winningLine(b), isNull);
      b[2] = b[4] = b[6] = Mark.o;
      expect(TicTacToeLogic.winningLine(b), [2, 4, 6]);
    });

    test('il telefono vince se può e blocca se serve', () {
      // O può vincere in 2
      var b = [Mark.o, Mark.o, Mark.none, Mark.x, Mark.x, Mark.none, Mark.none, Mark.none, Mark.none];
      expect(TicTacToeLogic.bestMove(b, Mark.o), 2);
      // X sta per vincere in 5: O deve bloccare
      b = [Mark.x, Mark.none, Mark.none, Mark.none, Mark.x, Mark.none, Mark.none, Mark.none, Mark.none];
      expect(TicTacToeLogic.bestMove(b, Mark.o), 8);
    });

    test('contro mosse casuali il telefono non perde mai (200 partite)', () {
      final r = Random(7);
      for (var g = 0; g < 200; g++) {
        final b = List<Mark>.filled(9, Mark.none);
        var humanTurn = true;
        while (TicTacToeLogic.winner(b) == Mark.none && !TicTacToeLogic.isFull(b)) {
          final m = humanTurn
              ? TicTacToeLogic.randomMove(b, r)
              : TicTacToeLogic.bestMove(b, Mark.o);
          b[m] = humanTurn ? Mark.x : Mark.o;
          humanTurn = !humanTurn;
        }
        expect(TicTacToeLogic.winner(b), isNot(Mark.x), reason: 'partita $g');
      }
    });
  });

  group('Labirinto', () {
    for (final n in [8, 14, 22]) {
      test('${n}x$n: perfetto e risolvibile', () {
        final r = Random(n);
        for (var k = 0; k < 5; k++) {
          final m = Maze.generate(n, n, r);
          final path = m.shortestPath();
          expect(path, isNotNull);
          expect(path!, greaterThanOrEqualTo(2 * (n - 1)));
          // labirinto perfetto: celle - 1 passaggi (ogni passaggio conta due bit)
          final bits = m.open.fold<int>(
              0, (a, o) => a + [Maze.n, Maze.e, Maze.s, Maze.w].where((d) => o & d != 0).length);
          expect(bits, 2 * (n * n - 1));
        }
      });
    }
  });

  group('Sudoku', () {
    test('griglia completa valida', () {
      final g = SudokuLogic.generateSolved(Random(1));
      expect(g.contains(0), isFalse);
      expect(SudokuLogic.conflicts(g), isEmpty);
    });

    for (var d = 0; d < 3; d++) {
      test('difficoltà $d: soluzione unica e coerente', () {
        final p = SudokuLogic.generate(d, Random(10 + d));
        expect(SudokuLogic.countSolutions(p.puzzle), 1);
        for (var i = 0; i < 81; i++) {
          if (p.puzzle[i] != 0) expect(p.puzzle[i], p.solution[i]);
        }
        final blanks = p.puzzle.where((v) => v == 0).length;
        expect(blanks, greaterThanOrEqualTo(30));
      });
    }

    test('conflitti rilevati', () {
      final g = List<int>.filled(81, 0);
      g[0] = 5;
      g[1] = 5; // stessa riga
      expect(SudokuLogic.conflicts(g), {0, 1});
    });
  });

  group('Battaglia navale', () {
    test('navi posizionate senza sovrapporsi', () {
      final r = Random(3);
      for (var k = 0; k < 50; k++) {
        final b = BattleshipBoard.random(r);
        expect(b.shipCells.length, BattleshipBoard.shipLengths.length);
        final all = b.shipCells.expand((c) => c).toList();
        expect(all.toSet().length, all.length);
        expect(all.length, BattleshipBoard.shipLengths.reduce((a, c) => a + c));
      }
    });

    test('posizionamento manuale: limiti, sovrapposizioni, rimozione, casuale', () {
      final b = BattleshipBoard();
      expect(b.allPlaced, isFalse);
      expect(b.place(0, 5, 0, true), isFalse, reason: 'esce dalla griglia (lunga 4)');
      expect(b.place(0, 4, 0, true), isTrue);
      expect(b.place(1, 4, 0, false), isFalse, reason: 'si sovrappone');
      expect(b.place(1, 0, 1, false), isTrue);
      b.remove(0);
      expect(b.isPlaced(0), isFalse);
      expect(b.ship.where((s) => s == 0), isEmpty);
      b.fillRandomly(Random(9));
      expect(b.allPlaced, isTrue);
      final all = b.shipCells.expand((c) => c).toList();
      expect(all.toSet().length, all.length);
      // la nave 1 posizionata a mano è rimasta dov'era
      expect(b.shipCells[1].first, 8);
    });

    test('l\'avversario affonda tutte le navi in al massimo 64 colpi', () {
      final r = Random(5);
      for (var k = 0; k < 30; k++) {
        final b = BattleshipBoard.random(r);
        var shots = 0;
        while (!b.allSunk) {
          final s = BattleshipAi.nextShot(b, r);
          expect(b.shot[s], isFalse, reason: 'colpo ripetuto');
          b.fire(s);
          shots++;
          expect(shots, lessThanOrEqualTo(64));
        }
      }
    });
  });

  group('Bus e minibus', () {
    for (final level in [1, 5, 10, 20, 30]) {
      test('livello $level: risolvibile, bus rosso sulla riga di uscita', () {
        final jam = JamLogic.generate(level);
        expect(jam.vehicles.first.horizontal, isTrue);
        expect(jam.vehicles.first.fixed, JamLogic.exitRow);
        expect(JamLogic.solved(jam.vehicles, jam.start), isFalse);
        final moves = JamLogic.solve(jam.vehicles, jam.start);
        expect(moves, isNotNull);
        expect(moves, jam.minMoves);
        // nessuna sovrapposizione iniziale
        final occ = JamLogic.occupancy(jam.vehicles, jam.start);
        final cells = jam.vehicles.fold<int>(0, (a, v) => a + v.len);
        expect(occ.where((o) => o).length, cells);
      });
    }

    test('stesso livello = stessa configurazione', () {
      final a = JamLogic.generate(7);
      final b = JamLogic.generate(7);
      expect(a.start, b.start);
      expect(a.minMoves, b.minMoves);
    });

    test('i livelli alti non sono più facili dei bassi (in media)', () {
      int avg(Iterable<int> levels) =>
          levels.map((l) => JamLogic.generate(l).minMoves).reduce((a, b) => a + b) ~/ levels.length;
      expect(avg([26, 27, 28, 29, 30]), greaterThanOrEqualTo(avg([1, 2, 3, 4, 5])));
    });
  });
}
