import 'dart:math';

enum Mark { none, x, o }

class TicTacToeLogic {
  static const lines = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8],
    [0, 3, 6], [1, 4, 7], [2, 5, 8],
    [0, 4, 8], [2, 4, 6],
  ];

  static Mark winner(List<Mark> b) {
    for (final l in lines) {
      final m = b[l[0]];
      if (m != Mark.none && m == b[l[1]] && m == b[l[2]]) return m;
    }
    return Mark.none;
  }

  /// Le tre celle della linea vincente, o null.
  static List<int>? winningLine(List<Mark> b) {
    for (final l in lines) {
      final m = b[l[0]];
      if (m != Mark.none && m == b[l[1]] && m == b[l[2]]) return l;
    }
    return null;
  }

  static bool isFull(List<Mark> b) => !b.contains(Mark.none);

  /// Mossa migliore (minimax): contro questa non si perde mai.
  static int bestMove(List<Mark> b, Mark ai) {
    final human = ai == Mark.o ? Mark.x : Mark.o;
    var bestScore = -1000;
    var bestIdx = -1;
    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.none) continue;
      b[i] = ai;
      final score = _minimax(b, false, ai, human, 1);
      b[i] = Mark.none;
      if (score > bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }
    return bestIdx;
  }

  static int _minimax(List<Mark> b, bool aiTurn, Mark ai, Mark human, int depth) {
    final w = winner(b);
    if (w == ai) return 10 - depth;
    if (w == human) return depth - 10;
    if (isFull(b)) return 0;
    var best = aiTurn ? -1000 : 1000;
    for (var i = 0; i < 9; i++) {
      if (b[i] != Mark.none) continue;
      b[i] = aiTurn ? ai : human;
      final s = _minimax(b, !aiTurn, ai, human, depth + 1);
      b[i] = Mark.none;
      best = aiTurn ? max(best, s) : min(best, s);
    }
    return best;
  }

  static int randomMove(List<Mark> b, Random r) {
    final free = [for (var i = 0; i < 9; i++) if (b[i] == Mark.none) i];
    return free[r.nextInt(free.length)];
  }
}
