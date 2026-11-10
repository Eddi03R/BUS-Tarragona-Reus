import 'dart:math';

enum Dir2048 { up, down, left, right }

class Game2048 {
  final int n;
  final Random _r;
  late List<int> cells;
  int score = 0;

  Game2048(this.n, this._r) {
    cells = List.filled(n * n, 0);
    _spawn();
    _spawn();
  }

  Game2048.fromCells(this.n, List<int> initial, this._r) {
    cells = List<int>.from(initial);
  }

  /// Fonde una riga verso l'inizio: restituisce la nuova riga e i punti guadagnati.
  static (List<int>, int) mergeLine(List<int> line) {
    final nz = line.where((v) => v != 0).toList();
    final out = <int>[];
    var gained = 0;
    for (var i = 0; i < nz.length; i++) {
      if (i + 1 < nz.length && nz[i] == nz[i + 1]) {
        out.add(nz[i] * 2);
        gained += nz[i] * 2;
        i++;
      } else {
        out.add(nz[i]);
      }
    }
    while (out.length < line.length) {
      out.add(0);
    }
    return (out, gained);
  }

  void _spawn() {
    final free = [for (var i = 0; i < cells.length; i++) if (cells[i] == 0) i];
    if (free.isEmpty) return;
    cells[free[_r.nextInt(free.length)]] = _r.nextInt(10) == 0 ? 4 : 2;
  }

  /// Esegue la mossa; true se qualcosa è cambiato (e allora appare un nuovo numero).
  bool move(Dir2048 d) {
    var changed = false;
    for (var k = 0; k < n; k++) {
      final idx = <int>[
        for (var i = 0; i < n; i++)
          switch (d) {
            Dir2048.left => k * n + i,
            Dir2048.right => k * n + (n - 1 - i),
            Dir2048.up => i * n + k,
            Dir2048.down => (n - 1 - i) * n + k,
          }
      ];
      final line = [for (final i in idx) cells[i]];
      final (merged, gained) = mergeLine(line);
      score += gained;
      for (var i = 0; i < n; i++) {
        if (cells[idx[i]] != merged[i]) changed = true;
        cells[idx[i]] = merged[i];
      }
    }
    if (changed) _spawn();
    return changed;
  }

  bool get canMove {
    if (cells.contains(0)) return true;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        final v = cells[r * n + c];
        if (c + 1 < n && cells[r * n + c + 1] == v) return true;
        if (r + 1 < n && cells[(r + 1) * n + c] == v) return true;
      }
    }
    return false;
  }

  int get maxTile => cells.reduce(max);
}
