import 'dart:math';

class SudokuPuzzle {
  final List<int> puzzle; // 0 = vuota
  final List<int> solution;
  const SudokuPuzzle(this.puzzle, this.solution);
}

class SudokuLogic {
  static int _used(List<int> g, int i) {
    final r = i ~/ 9, c = i % 9;
    var mask = 0;
    for (var k = 0; k < 9; k++) {
      mask |= 1 << g[r * 9 + k];
      mask |= 1 << g[k * 9 + c];
    }
    final br = (r ~/ 3) * 3, bc = (c ~/ 3) * 3;
    for (var rr = 0; rr < 3; rr++) {
      for (var cc = 0; cc < 3; cc++) {
        mask |= 1 << g[(br + rr) * 9 + bc + cc];
      }
    }
    return mask;
  }

  static int _candidates(List<int> g, int i) => ~_used(g, i) & 0x3FE;

  static int _bits(int m) {
    var c = 0;
    while (m != 0) {
      m &= m - 1;
      c++;
    }
    return c;
  }

  /// Conta le soluzioni fino a [limit].
  static int countSolutions(List<int> grid, {int limit = 2}) {
    final g = List<int>.from(grid);
    var count = 0;
    void solve() {
      if (count >= limit) return;
      var bestIdx = -1, bestMask = 0, bestCnt = 10;
      for (var i = 0; i < 81; i++) {
        if (g[i] != 0) continue;
        final m = _candidates(g, i);
        final c = _bits(m);
        if (c == 0) return;
        if (c < bestCnt) {
          bestCnt = c;
          bestIdx = i;
          bestMask = m;
          if (c == 1) break;
        }
      }
      if (bestIdx == -1) {
        count++;
        return;
      }
      for (var d = 1; d <= 9; d++) {
        if ((bestMask & (1 << d)) == 0) continue;
        g[bestIdx] = d;
        solve();
        if (count >= limit) break;
      }
      g[bestIdx] = 0;
    }

    solve();
    return count;
  }

  static List<int> generateSolved(Random r) {
    final g = List<int>.filled(81, 0);
    bool fill() {
      var bestIdx = -1, bestMask = 0, bestCnt = 10;
      for (var i = 0; i < 81; i++) {
        if (g[i] != 0) continue;
        final m = _candidates(g, i);
        final c = _bits(m);
        if (c == 0) return false;
        if (c < bestCnt) {
          bestCnt = c;
          bestIdx = i;
          bestMask = m;
        }
      }
      if (bestIdx == -1) return true;
      final digits = [for (var d = 1; d <= 9; d++) if ((bestMask & (1 << d)) != 0) d]..shuffle(r);
      for (final d in digits) {
        g[bestIdx] = d;
        if (fill()) return true;
      }
      g[bestIdx] = 0;
      return false;
    }

    fill();
    return g;
  }

  /// Celle da svuotare in base alla difficoltà.
  static int blanksFor(int difficultyIndex) => const [36, 46, 52][difficultyIndex];

  static SudokuPuzzle generate(int difficultyIndex, Random r) {
    final solution = generateSolved(r);
    final puzzle = List<int>.from(solution);
    final target = blanksFor(difficultyIndex);
    final order = List<int>.generate(81, (i) => i)..shuffle(r);
    var removed = 0;
    for (final i in order) {
      if (removed >= target) break;
      final v = puzzle[i];
      puzzle[i] = 0;
      if (countSolutions(puzzle) == 1) {
        removed++;
      } else {
        puzzle[i] = v;
      }
    }
    return SudokuPuzzle(puzzle, solution);
  }

  /// Indici con un numero duplicato su riga, colonna o riquadro.
  static Set<int> conflicts(List<int> g) {
    final bad = <int>{};
    void check(List<int> idx) {
      final seen = <int, int>{};
      for (final i in idx) {
        final v = g[i];
        if (v == 0) continue;
        if (seen.containsKey(v)) {
          bad..add(i)..add(seen[v]!);
        } else {
          seen[v] = i;
        }
      }
    }

    for (var k = 0; k < 9; k++) {
      check([for (var c = 0; c < 9; c++) k * 9 + c]);
      check([for (var r = 0; r < 9; r++) r * 9 + k]);
      final br = (k ~/ 3) * 3, bc = (k % 3) * 3;
      check([
        for (var r = 0; r < 3; r++)
          for (var c = 0; c < 3; c++) (br + r) * 9 + bc + c
      ]);
    }
    return bad;
  }
}
