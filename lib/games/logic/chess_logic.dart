import 'dart:math';

/// Scacchi: regole complete (arrocco, presa al varco, promozione, scacco matto,
/// stallo, regola delle 50 mosse, materiale insufficiente) e un avversario a
/// 3 livelli. Pezzi: 1 pedone, 2 cavallo, 3 alfiere, 4 torre, 5 donna, 6 re;
/// positivi = bianchi, negativi = neri. Casella = riga * 8 + colonna, con la
/// riga 0 in alto (ottava traversa, lato dei neri).
class ChessMove {
  final int from;
  final int to;
  final int promo; // 0 oppure 2..5
  const ChessMove(this.from, this.to, [this.promo = 0]);

  @override
  bool operator ==(Object o) => o is ChessMove && o.from == from && o.to == to && o.promo == promo;
  @override
  int get hashCode => from * 4096 + to * 8 + promo;

  @override
  String toString() => '${ChessState.sqName(from)}${ChessState.sqName(to)}${promo == 0 ? '' : 'nbrq'[promo - 2]}';
}

enum ChessOutcome { checkmate, stalemate, drawFifty, drawMaterial }

class ChessState {
  final List<int> b;
  final bool white; // tocca ai bianchi
  final int castle; // bit0 O-O bianco, bit1 O-O-O bianco, bit2 O-O nero, bit3 O-O-O nero
  final int ep; // casella "di passaggio" per la presa al varco, o -1
  final int half; // semimosse dall'ultima presa/mossa di pedone
  final int full;

  ChessState(this.b, this.white, this.castle, this.ep, this.half, this.full);

  static const startFen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1';

  factory ChessState.start() => ChessState.fromFen(startFen);

  static String sqName(int s) => '${'abcdefgh'[s % 8]}${8 - s ~/ 8}';

  factory ChessState.fromFen(String fen) {
    final parts = fen.trim().split(RegExp(r'\s+'));
    final b = List<int>.filled(64, 0);
    var r = 0, f = 0;
    for (final ch in parts[0].split('')) {
      if (ch == '/') {
        r++;
        f = 0;
      } else if (RegExp(r'[1-8]').hasMatch(ch)) {
        f += int.parse(ch);
      } else {
        const map = {'p': 1, 'n': 2, 'b': 3, 'r': 4, 'q': 5, 'k': 6};
        final v = map[ch.toLowerCase()]!;
        b[r * 8 + f] = ch == ch.toLowerCase() ? -v : v;
        f++;
      }
    }
    final white = parts.length < 2 || parts[1] == 'w';
    var castle = 0;
    final c = parts.length > 2 ? parts[2] : '-';
    if (c.contains('K')) castle |= 1;
    if (c.contains('Q')) castle |= 2;
    if (c.contains('k')) castle |= 4;
    if (c.contains('q')) castle |= 8;
    var ep = -1;
    if (parts.length > 3 && parts[3] != '-') {
      ep = (8 - int.parse(parts[3][1])) * 8 + 'abcdefgh'.indexOf(parts[3][0]);
    }
    final half = parts.length > 4 ? int.parse(parts[4]) : 0;
    final full = parts.length > 5 ? int.parse(parts[5]) : 1;
    return ChessState(b, white, castle, ep, half, full);
  }

  String toFen() {
    final sb = StringBuffer();
    for (var r = 0; r < 8; r++) {
      var empty = 0;
      for (var f = 0; f < 8; f++) {
        final p = b[r * 8 + f];
        if (p == 0) {
          empty++;
          continue;
        }
        if (empty > 0) {
          sb.write(empty);
          empty = 0;
        }
        final ch = 'pnbrqk'[p.abs() - 1];
        sb.write(p > 0 ? ch.toUpperCase() : ch);
      }
      if (empty > 0) sb.write(empty);
      if (r < 7) sb.write('/');
    }
    final cs = '${castle & 1 != 0 ? 'K' : ''}${castle & 2 != 0 ? 'Q' : ''}${castle & 4 != 0 ? 'k' : ''}${castle & 8 != 0 ? 'q' : ''}';
    return '$sb ${white ? 'w' : 'b'} ${cs.isEmpty ? '-' : cs} ${ep < 0 ? '-' : sqName(ep)} $half $full';
  }

  static const _knight = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)];
  static const _king = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)];
  static const _diag = [(-1, -1), (-1, 1), (1, -1), (1, 1)];
  static const _orth = [(-1, 0), (1, 0), (0, -1), (0, 1)];

  static bool _in(int r, int f) => r >= 0 && r < 8 && f >= 0 && f < 8;

  /// La casella [sq] è attaccata da un pezzo del colore indicato?
  static bool attacked(List<int> b, int sq, bool byWhite) {
    final r = sq ~/ 8, f = sq % 8;
    final s = byWhite ? 1 : -1;
    // pedoni: un pedone bianco in (r+1, f±1) attacca (r, f)
    final pr = byWhite ? r + 1 : r - 1;
    for (final df in const [-1, 1]) {
      if (_in(pr, f + df) && b[pr * 8 + f + df] == s * 1) return true;
    }
    for (final (dr, df) in _knight) {
      final rr = r + dr, ff = f + df;
      if (_in(rr, ff) && b[rr * 8 + ff] == s * 2) return true;
    }
    for (final (dr, df) in _king) {
      final rr = r + dr, ff = f + df;
      if (_in(rr, ff) && b[rr * 8 + ff] == s * 6) return true;
    }
    for (final (dr, df) in _diag) {
      var rr = r + dr, ff = f + df;
      while (_in(rr, ff)) {
        final p = b[rr * 8 + ff];
        if (p != 0) {
          if (p == s * 3 || p == s * 5) return true;
          break;
        }
        rr += dr;
        ff += df;
      }
    }
    for (final (dr, df) in _orth) {
      var rr = r + dr, ff = f + df;
      while (_in(rr, ff)) {
        final p = b[rr * 8 + ff];
        if (p != 0) {
          if (p == s * 4 || p == s * 5) return true;
          break;
        }
        rr += dr;
        ff += df;
      }
    }
    return false;
  }

  int _kingSq(bool w) => b.indexOf(w ? 6 : -6);

  bool inCheck([bool? side]) {
    final w = side ?? white;
    final k = _kingSq(w);
    return k >= 0 && attacked(b, k, !w);
  }

  List<ChessMove> _pseudo() {
    final out = <ChessMove>[];
    final s = white ? 1 : -1;
    for (var sq = 0; sq < 64; sq++) {
      final p = b[sq];
      if (p == 0 || (p > 0) != white) continue;
      final r = sq ~/ 8, f = sq % 8;
      switch (p.abs()) {
        case 1:
          final dir = white ? -1 : 1;
          final startRow = white ? 6 : 1;
          final lastRow = white ? 0 : 7;
          void push(int to) {
            if (to ~/ 8 == lastRow) {
              for (final pr in const [5, 4, 3, 2]) {
                out.add(ChessMove(sq, to, pr));
              }
            } else {
              out.add(ChessMove(sq, to));
            }
          }
          final one = (r + dir) * 8 + f;
          if (_in(r + dir, f) && b[one] == 0) {
            push(one);
            if (r == startRow && b[(r + 2 * dir) * 8 + f] == 0) {
              out.add(ChessMove(sq, (r + 2 * dir) * 8 + f));
            }
          }
          for (final df in const [-1, 1]) {
            final rr = r + dir, ff = f + df;
            if (!_in(rr, ff)) continue;
            final to = rr * 8 + ff;
            if ((b[to] != 0 && (b[to] > 0) != white) || to == ep) push(to);
          }
        case 2:
          for (final (dr, df) in _knight) {
            final rr = r + dr, ff = f + df;
            if (_in(rr, ff) && (b[rr * 8 + ff] == 0 || (b[rr * 8 + ff] > 0) != white)) {
              out.add(ChessMove(sq, rr * 8 + ff));
            }
          }
        case 6:
          for (final (dr, df) in _king) {
            final rr = r + dr, ff = f + df;
            if (_in(rr, ff) && (b[rr * 8 + ff] == 0 || (b[rr * 8 + ff] > 0) != white)) {
              out.add(ChessMove(sq, rr * 8 + ff));
            }
          }
          // arrocco
          final home = white ? 60 : 4;
          if (sq == home && !attacked(b, home, !white)) {
            final ks = white ? 1 : 4, qs = white ? 2 : 8;
            if (castle & ks != 0 &&
                b[home + 1] == 0 &&
                b[home + 2] == 0 &&
                b[home + 3] == s * 4 &&
                !attacked(b, home + 1, !white) &&
                !attacked(b, home + 2, !white)) {
              out.add(ChessMove(sq, home + 2));
            }
            if (castle & qs != 0 &&
                b[home - 1] == 0 &&
                b[home - 2] == 0 &&
                b[home - 3] == 0 &&
                b[home - 4] == s * 4 &&
                !attacked(b, home - 1, !white) &&
                !attacked(b, home - 2, !white)) {
              out.add(ChessMove(sq, home - 2));
            }
          }
        default:
          final dirs = p.abs() == 3
              ? _diag
              : p.abs() == 4
                  ? _orth
                  : _king;
          for (final (dr, df) in dirs) {
            var rr = r + dr, ff = f + df;
            while (_in(rr, ff)) {
              final t = b[rr * 8 + ff];
              if (t == 0) {
                out.add(ChessMove(sq, rr * 8 + ff));
              } else {
                if ((t > 0) != white) out.add(ChessMove(sq, rr * 8 + ff));
                break;
              }
              rr += dr;
              ff += df;
            }
          }
      }
    }
    return out;
  }

  List<ChessMove>? _legalCache;

  List<ChessMove> legalMoves() {
    final cached = _legalCache;
    if (cached != null) return cached;
    final res = <ChessMove>[];
    for (final m in _pseudo()) {
      final n = apply(m);
      if (!n.inCheck(white)) res.add(m);
    }
    return _legalCache = res;
  }

  List<ChessMove> movesFrom(int sq) => [for (final m in legalMoves()) if (m.from == sq) m];

  /// Gioca [m] (si assume legale) e restituisce il nuovo stato.
  ChessState apply(ChessMove m) {
    final nb = List<int>.of(b);
    final p = nb[m.from];
    final cap = nb[m.to];
    nb[m.to] = m.promo != 0 ? (white ? m.promo : -m.promo) : p;
    nb[m.from] = 0;
    var nep = -1;
    if (p.abs() == 1) {
      if (m.to == ep) {
        nb[white ? m.to + 8 : m.to - 8] = 0; // presa al varco
      }
      if ((m.to - m.from).abs() == 16) nep = (m.to + m.from) ~/ 2;
    }
    if (p.abs() == 6 && (m.to - m.from).abs() == 2) {
      // arrocco: sposta la torre
      if (m.to > m.from) {
        nb[m.from + 1] = nb[m.from + 3];
        nb[m.from + 3] = 0;
      } else {
        nb[m.from - 1] = nb[m.from - 4];
        nb[m.from - 4] = 0;
      }
    }
    var nc = castle;
    if (p == 6) nc &= ~3;
    if (p == -6) nc &= ~12;
    for (final s in [m.from, m.to]) {
      if (s == 63) nc &= ~1;
      if (s == 56) nc &= ~2;
      if (s == 7) nc &= ~4;
      if (s == 0) nc &= ~8;
    }
    final reset = p.abs() == 1 || cap != 0;
    return ChessState(nb, !white, nc, nep, reset ? 0 : half + 1, white ? full : full + 1);
  }

  bool get _insufficientMaterial {
    var minors = 0;
    for (final p in b) {
      final a = p.abs();
      if (a == 1 || a == 4 || a == 5) return false;
      if (a == 2 || a == 3) minors++;
    }
    return minors <= 1;
  }

  ChessOutcome? get outcome {
    if (legalMoves().isEmpty) return inCheck() ? ChessOutcome.checkmate : ChessOutcome.stalemate;
    if (half >= 100) return ChessOutcome.drawFifty;
    if (_insufficientMaterial) return ChessOutcome.drawMaterial;
    return null;
  }

  /// Conta le posizioni raggiungibili in [depth] mosse (per i test).
  int perft(int depth) {
    if (depth == 0) return 1;
    var n = 0;
    for (final m in legalMoves()) {
      n += depth == 1 ? 1 : apply(m).perft(depth - 1);
    }
    return n;
  }
}

/// Avversario: ricerca negamax con potatura alfa-beta.
class ChessAi {
  static const _val = [0, 100, 320, 330, 500, 900, 0];

  /// Valutazione dal punto di vista dei bianchi (centipedoni).
  static int evaluate(ChessState s) {
    var score = 0;
    for (var sq = 0; sq < 64; sq++) {
      final p = s.b[sq];
      if (p == 0) continue;
      final a = p.abs();
      final r = sq ~/ 8, f = sq % 8;
      var v = _val[a];
      final centre = 3.5 - (f - 3.5).abs() + 3.5 - (r - 3.5).abs(); // 0..7
      if (a == 1) {
        final adv = p > 0 ? 6 - r : r - 1; // 0..5
        v += adv * 6 + (f >= 2 && f <= 5 ? 4 : 0);
      } else if (a == 2 || a == 3) {
        v += (centre * 4).round();
      } else if (a == 5) {
        v += (centre * 1).round();
      }
      score += p > 0 ? v : -v;
    }
    return score;
  }

  static int _order(ChessState s, ChessMove m) {
    final victim = s.b[m.to].abs();
    var o = victim != 0 ? 10 * _val[victim] - _val[s.b[m.from].abs()] : 0;
    if (m.promo != 0) o += 800;
    return o;
  }

  static int _search(ChessState s, int depth, int alpha, int beta, int ply) {
    final moves = s.legalMoves();
    if (moves.isEmpty) {
      return s.inCheck() ? -100000 + ply : 0;
    }
    if (s.half >= 100) return 0;
    if (depth == 0) {
      final e = evaluate(s);
      return s.white ? e : -e;
    }
    moves.sort((a, c) => _order(s, c).compareTo(_order(s, a)));
    var best = -1000000;
    for (final m in moves) {
      final v = -_search(s.apply(m), depth - 1, -beta, -alpha, ply + 1);
      if (v > best) best = v;
      if (best > alpha) alpha = best;
      if (alpha >= beta) break;
    }
    return best;
  }

  /// Sceglie la mossa. [level]: 0 facile, 1 medio, 2 difficile.
  static ChessMove? bestMove(ChessState s, int level, [Random? rand]) {
    final r = rand ?? Random();
    final moves = s.legalMoves();
    if (moves.isEmpty) return null;
    // facile: spesso a caso, altrimenti la presa/mossa migliore a un passo
    if (level == 0 && r.nextDouble() < 0.55) return moves[r.nextInt(moves.length)];
    var pieces = 0;
    for (final p in s.b) {
      if (p != 0) pieces++;
    }
    final depth = level == 0 ? 1 : level == 1 ? 2 : (pieces <= 10 ? 4 : 3);
    final list = List<ChessMove>.of(moves)..shuffle(r);
    list.sort((a, c) => _order(s, c).compareTo(_order(s, a)));
    ChessMove? best;
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

  /// Versione per `compute`: riceve la FEN, restituisce [da, a, promozione].
  static List<int>? searchFen(List<Object> args) {
    final s = ChessState.fromFen(args[0] as String);
    final m = bestMove(s, args[1] as int);
    return m == null ? null : [m.from, m.to, m.promo];
  }
}
