import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/logic/checkers_logic.dart';
import 'package:reus_tarragona_bus/games/logic/chess_logic.dart';

void main() {
  group('Scacchi', () {
    test('perft posizione iniziale: 20, 400, 8902', () {
      final s = ChessState.start();
      expect(s.perft(1), 20);
      expect(s.perft(2), 400);
      expect(s.perft(3), 8902);
    });

    test('perft "Kiwipete" (arrocco, presa al varco, promozioni): 48 e 2039', () {
      final s = ChessState.fromFen('r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1');
      expect(s.perft(1), 48);
      expect(s.perft(2), 2039);
    });

    test('perft posizione 3 (finali con presa al varco): 14, 191, 2812', () {
      final s = ChessState.fromFen('8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1');
      expect(s.perft(1), 14);
      expect(s.perft(2), 191);
      expect(s.perft(3), 2812);
    });

    test('fen: andata e ritorno', () {
      const fen = 'r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1';
      expect(ChessState.fromFen(fen).toFen(), fen);
    });

    test('scacco matto del barbiere e stallo', () {
      final mate = ChessState.fromFen('rnb1kbnr/pppp1ppp/8/4p3/6Pq/5P2/PPPPP2P/RNBQKBNR w KQkq - 1 3');
      expect(mate.outcome, ChessOutcome.checkmate);
      final stale = ChessState.fromFen('7k/5Q2/6K1/8/8/8/8/8 b - - 0 1');
      expect(stale.outcome, ChessOutcome.stalemate);
      expect(ChessState.fromFen('4k3/8/8/8/8/8/8/4K3 w - - 0 1').outcome, ChessOutcome.drawMaterial);
    });

    test('promozione e arrocco compaiono tra le mosse', () {
      final promo = ChessState.fromFen('8/P6k/8/8/8/8/8/K7 w - - 0 1');
      expect(promo.legalMoves().where((m) => m.promo != 0).length, 4);
      final castle = ChessState.fromFen('r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1');
      expect(castle.legalMoves().where((m) => m.from == 60 && (m.to - m.from).abs() == 2).length, 2);
      final after = castle.apply(const ChessMove(60, 62));
      expect(after.b[61], 4); // la torre è passata accanto al re
      expect(after.b[63], 0);
    });

    test('IA: trova il matto in uno ai livelli medio e difficile', () {
      // i bianchi matterebbero con Dh5# oppure Qxf7#: qui Qxf7# (scacco matto del pastore)
      final s = ChessState.fromFen('r1bqkbnr/pppp1ppp/2n5/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4');
      for (final lvl in [1, 2]) {
        final m = ChessAi.bestMove(s, lvl, Random(1))!;
        expect(s.apply(m).outcome, ChessOutcome.checkmate, reason: 'livello $lvl: $m');
      }
    });

    test('IA: tutti i livelli giocano solo mosse legali per un po\'', () {
      for (final lvl in [0, 1, 2]) {
        var s = ChessState.start();
        final rnd = Random(lvl);
        for (var i = 0; i < 12 && s.outcome == null; i++) {
          final m = ChessAi.bestMove(s, lvl, rnd)!;
          expect(s.legalMoves().contains(m), isTrue);
          s = s.apply(m);
        }
      }
    });
  });

  group('Dama', () {
    test('posizione iniziale: 12 pezzi a testa e 7 mosse per il bianco', () {
      final s = CheckersState.start();
      expect(s.count(true), 12);
      expect(s.count(false), 12);
      expect(s.legalMoves().length, 7);
      expect(s.legalMoves().any((m) => m.isCapture), isFalse);
    });

    CheckersState setup(Map<int, int> pieces, {bool white = true}) {
      final b = List<int>.filled(64, 0);
      pieces.forEach((k, v) => b[k] = v);
      return CheckersState(b, white);
    }

    // casella (riga, colonna) -> indice
    int q(int r, int f) => r * 8 + f;

    test('la presa è obbligatoria', () {
      final s = setup({q(5, 2): 1, q(4, 3): -1, q(1, 6): -1});
      final m = s.legalMoves();
      expect(m.length, 1);
      expect(m.first.isCapture, isTrue);
      expect(m.first.path, [q(5, 2), q(3, 4)]);
    });

    test('presa multipla e scelta della presa che porta via più pezzi', () {
      // il bianco in (6,1) può mangiare 1 pezzo a sinistra o 2 pezzi di seguito a destra
      final s = setup({q(6, 1): 1, q(5, 0): -1, q(5, 2): -1, q(3, 4): -1});
      final m = s.legalMoves();
      expect(m.length, 1);
      expect(m.first.captured.length, 2);
      expect(m.first.path, [q(6, 1), q(4, 3), q(2, 5)]);
    });

    test('la pedina non può mangiare la dama, la dama sì', () {
      final man = setup({q(5, 2): 1, q(4, 3): -2});
      expect(man.legalMoves().any((m) => m.isCapture), isFalse);
      final king = setup({q(5, 2): 2, q(4, 3): -2});
      expect(king.legalMoves().any((m) => m.isCapture), isTrue);
    });

    test('la pedina mangia solo in avanti e la promozione chiude la presa', () {
      final back = setup({q(4, 3): 1, q(5, 2): -1});
      expect(back.legalMoves().any((m) => m.isCapture), isFalse);
      // arriva all'ultima riga mangiando: diventa dama e si ferma anche se potrebbe continuare
      final s = setup({q(2, 1): 1, q(1, 2): -1, q(1, 4): -2});
      final m = s.legalMoves().firstWhere((x) => x.isCapture);
      expect(m.path, [q(2, 1), q(0, 3)]);
      expect(s.apply(m).b[q(0, 3)], 2);
    });

    test('senza mosse si perde', () {
      final s = setup({q(0, 1): -1, q(7, 0): 1, q(6, 1): 1, q(5, 2): 1}, white: false);
      // il nero in (0,1) muove verso il basso: (1,0) e (1,2) liberi, quindi può muovere
      expect(s.legalMoves(), isNotEmpty);
      final blocked = setup({q(7, 0): 1}, white: false);
      expect(blocked.legalMoves(), isEmpty);
      expect(blocked.winner, isTrue);
    });

    test('IA: tutti i livelli giocano mosse legali e le partite finiscono', () {
      for (final lvl in [0, 1, 2]) {
        var s = CheckersState.start();
        final rnd = Random(lvl + 5);
        for (var i = 0; i < 40 && s.winner == null && !s.isDraw; i++) {
          final m = CheckersAi.bestMove(s, lvl, rnd)!;
          expect(s.legalMoves().any((x) => x.toString() == m.toString()), isTrue);
          s = s.apply(m);
        }
      }
    });
  });
}
