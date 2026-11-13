import 'dart:math';

/// Dama italiana: scacchiera 8x8, 12 pedine a testa sulle caselle scure.
/// Le pedine muovono e mangiano solo in avanti, la dama muove e mangia di una
/// casella in tutte le diagonali. La presa è obbligatoria, si può mangiare più
/// pezzi di seguito e bisogna scegliere la presa che ne porta via di più. La
/// pedina non può mangiare la dama. Una pedina che arriva all'ultima riga
/// diventa dama e il turno finisce lì.
///
/// Pezzi: 1 pedina bianca, 2 dama bianca, -1 pedina nera, -2 dama nera.
/// Casella = riga * 8 + colonna, riga 0 in alto. I bianchi partono in basso e
/// muovono verso l'alto.
class CheckersMove {
  /// Caselle toccate, dalla partenza all'arrivo (3+ caselle se si mangia più volte).
  final List<int> path;

  /// Caselle dei pezzi mangiati.
  final List<int> captured;
  const CheckersMove(this.path, this.captured);

  int get from => path.first;
  int get to => path.last;
  bool get isCapture => captured.isNotEmpty;

  @override
  String toString() => path.join('>');
}

class CheckersState {
  final List<int> b;
  final bool white;
  final int quiet; // mosse consecutive senza prese né mosse di pedina

  CheckersState(this.b, this.white, [this.quiet = 0]);

  factory CheckersState.start() {
    final b = List<int>.filled(64, 0);
    for (var r = 0; r < 8; r++) {
      for (var f = 0; f < 8; f++) {
        if ((r + f) % 2 == 0) continue; // solo caselle scure (r+f dispari)
        if (r < 3) b[r * 8 + f] = -1;
        if (r > 4) b[r * 8 + f] = 1;
      }
    }
    return CheckersState(b, true);
  }

  static bool _in(int r, int f) => r >= 0 && r < 8 && f >= 0 && f < 8;

  bool _mine(int p) => p != 0 && (p > 0) == white;

  List<CheckersMove>? _cache;

  List<CheckersMove> legalMoves() => _cache ??= _generate();

  List<CheckersMove> _generate() {
    final caps = <CheckersMove>[];
    for (var sq = 0; sq < 64; sq++) {
      if (_mine(b[sq])) _captures(sq, [sq], [], caps);
    }
    if (caps.isNotEmpty) {
      var most = 0;
      for (final c in caps) {
        most = max(most, c.captured.length);
      }
      return [for (final c in caps) if (c.captured.length == most) c];
    }
    final moves = <CheckersMove>[];
    for (var sq = 0; sq < 64; sq++) {
      final p = b[sq];
      if (!_mine(p)) continue;
      final r = sq ~/ 8, f = sq % 8;
      final king = p.abs() == 2;
      for (final dr in king ? const [-1, 1] : [white ? -1 : 1]) {
        for (final df in const [-1, 1]) {
          final rr = r + dr, ff = f + df;
          if (_in(rr, ff) && b[rr * 8 + ff] == 0) moves.add(CheckersMove([sq, rr * 8 + ff], const []));
        }
      }
    }
    return moves;
  }

  /// Cerca le prese a partire da [sq]; il pezzo che muove ha lasciato la casella di partenza.
  void _captures(int sq, List<int> path, List<int> taken, List<CheckersMove> out) {
    final start = path.first;
    final piece = b[start];
    final king = piece.abs() == 2;
    final r = sq ~/ 8, f = sq % 8;
    var extended = false;
    for (final dr in king ? const [-1, 1] : [white ? -1 : 1]) {
      for (final df in const [-1, 1]) {
        final mr = r + dr, mf = f + df, lr = r + 2 * dr, lf = f + 2 * df;
        if (!_in(lr, lf)) continue;
        final mid = mr * 8 + mf, land = lr * 8 + lf;
        final target = b[mid];
        if (target == 0 || (target > 0) == white) continue; // niente o proprio
        if (taken.contains(mid)) continue; // un pezzo si mangia una volta sola
        if (!king && target.abs() == 2) continue; // la pedina non mangia la dama
        // la casella d'arrivo deve essere libera (o essere quella di partenza)
        if (b[land] != 0 && land != start) continue;
        extended = true;
        final np = [...path, land];
        final nt = [...taken, mid];
        final promotes = !king && lr == (white ? 0 : 7);
        if (promotes) {
          out.add(CheckersMove(np, nt)); // la promozione chiude la presa
        } else {
          _captures(land, np, nt, out);
        }
      }
    }
    if (!extended && taken.isNotEmpty) out.add(CheckersMove(List.of(path), List.of(taken)));
  }

  CheckersState apply(CheckersMove m) {
    final nb = List<int>.of(b);
    final p = nb[m.from];
    nb[m.from] = 0;
    for (final c in m.captured) {
      nb[c] = 0;
    }
    var np = p;
    final lastRow = white ? 0 : 7;
    if (p.abs() == 1 && m.to ~/ 8 == lastRow) np = p > 0 ? 2 : -2;
    nb[m.to] = np;
    final reset = m.isCapture || p.abs() == 1;
    return CheckersState(nb, !white, reset ? 0 : quiet + 1);
  }

  /// null = si continua; true = vincono i bianchi; false = vincono i neri.
  bool? get winner {
    if (legalMoves().isEmpty) return !white; // chi non può muovere perde
    return null;
  }

  bool get isDraw => quiet >= 40 && winner == null;

  int count(bool whitePieces) {
    var n = 0;
    for (final p in b) {
      if (p != 0 && (p > 0) == whitePieces) n++;
    }
    return n;
  }
}

class CheckersAi {
  static int evaluate(CheckersState s) {
    var score = 0;
    for (var sq = 0; sq < 64; sq++) {
      final p = s.b[sq];
      if (p == 0) continue;
      final r = sq ~/ 8, f = sq % 8;
      var v = p.abs() == 2 ? 190 : 100;
      if (p.abs() == 1) {
        final adv = p > 0 ? 7 - r : r; // 0..7
        v += adv * 4;
        if (r == (p > 0 ? 7 : 0)) v += 6; // riga di fondo ancora presidiata
      }
      if (f == 0 || f == 7) v += 3; // i bordi sono più sicuri
      score += p > 0 ? v : -v;
    }
    return score;
  }

  static int _search(CheckersState s, int depth, int alpha, int beta, int ply) {
    final moves = s.legalMoves();
    if (moves.isEmpty) return -100000 + ply; // chi deve muovere ha perso
    if (s.quiet >= 40) return 0;
    if (depth == 0) {
      final e = evaluate(s);
      return s.white ? e : -e;
    }
    var best = -1000000;
    for (final m in moves) {
      final v = -_search(s.apply(m), depth - 1, -beta, -alpha, ply + 1);
      if (v > best) best = v;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break;
    }
    return best;
  }

  /// [level]: 0 facile, 1 medio, 2 difficile.
  static CheckersMove? bestMove(CheckersState s, int level, [Random? rand]) {
    final r = rand ?? Random();
    final moves = s.legalMoves();
    if (moves.isEmpty) return null;
    if (moves.length == 1) return moves.first;
    if (level == 0 && r.nextDouble() < 0.5) return moves[r.nextInt(moves.length)];
    final depth = level == 0 ? 1 : level == 1 ? 3 : 5;
    final list = List<CheckersMove>.of(moves)..shuffle(r);
    CheckersMove? best;
    var bestScore = -1000000;
    var alpha = -1000000;
    for (final m in list) {
      final v = -_search(s.apply(m), depth - 1, -1000000, -alpha, 1);
      if (v > bestScore) {
        bestScore = v;
        best = m;
      }
      if (bestScore > alpha) alpha = bestScore;
    }
    return best;
  }
}
