import 'dart:math';

/// Labirinto perfetto (un solo percorso tra due celle): generato con DFS.
class Maze {
  static const n = 1, e = 2, s = 4, w = 8;
  final int cols;
  final int rows;
  final List<int> open; // per cella: bit delle direzioni aperte

  Maze(this.cols, this.rows, this.open);

  factory Maze.generate(int cols, int rows, Random r) {
    final open = List<int>.filled(cols * rows, 0);
    final visited = List<bool>.filled(cols * rows, false);
    final stack = <int>[0];
    visited[0] = true;
    while (stack.isNotEmpty) {
      final cur = stack.last;
      final x = cur % cols, y = cur ~/ cols;
      final options = <int>[];
      if (y > 0 && !visited[cur - cols]) options.add(n);
      if (x < cols - 1 && !visited[cur + 1]) options.add(e);
      if (y < rows - 1 && !visited[cur + cols]) options.add(s);
      if (x > 0 && !visited[cur - 1]) options.add(w);
      if (options.isEmpty) {
        stack.removeLast();
        continue;
      }
      final d = options[r.nextInt(options.length)];
      final next = cur + _delta(d, cols);
      open[cur] |= d;
      open[next] |= _opposite(d);
      visited[next] = true;
      stack.add(next);
    }
    return Maze(cols, rows, open);
  }

  static int _delta(int d, int cols) {
    switch (d) {
      case n:
        return -cols;
      case e:
        return 1;
      case s:
        return cols;
      default:
        return -1;
    }
  }

  static int _opposite(int d) {
    switch (d) {
      case n:
        return s;
      case e:
        return w;
      case s:
        return n;
      default:
        return e;
    }
  }

  bool canMove(int x, int y, int dir) => (open[y * cols + x] & dir) != 0;

  /// Lunghezza del percorso più breve da (0,0) a (cols-1, rows-1), o null.
  int? shortestPath() {
    final dist = List<int>.filled(cols * rows, -1);
    final q = <int>[0];
    dist[0] = 0;
    for (var qi = 0; qi < q.length; qi++) {
      final cur = q[qi];
      for (final d in const [n, e, s, w]) {
        if ((open[cur] & d) == 0) continue;
        final nx = cur + _delta(d, cols);
        if (dist[nx] == -1) {
          dist[nx] = dist[cur] + 1;
          q.add(nx);
        }
      }
    }
    final goal = cols * rows - 1;
    return dist[goal] == -1 ? null : dist[goal];
  }
}
