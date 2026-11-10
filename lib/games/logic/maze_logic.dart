import 'dart:math';

/// Labirinto perfetto (un solo percorso tra due celle): generato con DFS.
class Maze {
  static const n = 1, e = 2, s = 4, w = 8;
  final int cols;
  final int rows;
  final List<int> open; // per cella: bit delle direzioni aperte
  final int startX, startY, goalX, goalY;

  Maze(this.cols, this.rows, this.open,
      {this.startX = 0, this.startY = 0, int? goalX, int? goalY})
      : goalX = goalX ?? cols - 1,
        goalY = goalY ?? rows - 1;

  /// Labirinto casuale: algoritmo scelto a caso (percorsi lunghi o ramificati),
  /// cella iniziale casuale e partenza/arrivo in angoli opposti scelti a caso.
  factory Maze.generate(int cols, int rows, Random r) {
    final open = r.nextBool() ? _dfs(cols, rows, r) : _prim(cols, rows, r);
    final sx = r.nextBool() ? 0 : cols - 1;
    final sy = r.nextBool() ? 0 : rows - 1;
    return Maze(cols, rows, open,
        startX: sx, startY: sy, goalX: cols - 1 - sx, goalY: rows - 1 - sy);
  }

  /// Firma del labirinto (per riconoscere due labirinti identici).
  String get signature => '$startX$startY$goalX$goalY${open.join(',')}';

  /// DFS (corridoi lunghi e tortuosi), partendo da una cella a caso.
  static List<int> _dfs(int cols, int rows, Random r) {
    final open = List<int>.filled(cols * rows, 0);
    final visited = List<bool>.filled(cols * rows, false);
    final first = r.nextInt(cols * rows);
    final stack = <int>[first];
    visited[first] = true;
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
    return open;
  }

  /// Prim casuale (tanti bivi e vicoli ciechi corti).
  static List<int> _prim(int cols, int rows, Random r) {
    final open = List<int>.filled(cols * rows, 0);
    final visited = List<bool>.filled(cols * rows, false);
    final frontier = <List<int>>[]; // [cella, direzione]
    void visit(int cell) {
      visited[cell] = true;
      final x = cell % cols, y = cell ~/ cols;
      if (y > 0) frontier.add([cell, n]);
      if (x < cols - 1) frontier.add([cell, e]);
      if (y < rows - 1) frontier.add([cell, s]);
      if (x > 0) frontier.add([cell, w]);
    }

    visit(r.nextInt(cols * rows));
    while (frontier.isNotEmpty) {
      final i = r.nextInt(frontier.length);
      final f = frontier[i];
      frontier[i] = frontier.last;
      frontier.removeLast();
      final from = f[0], d = f[1];
      final to = from + _delta(d, cols);
      if (visited[to]) continue;
      open[from] |= d;
      open[to] |= _opposite(d);
      visit(to);
    }
    return open;
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

  /// Lunghezza del percorso più breve dalla partenza all'arrivo, o null.
  int? shortestPath() {
    final dist = List<int>.filled(cols * rows, -1);
    final start = startY * cols + startX;
    final q = <int>[start];
    dist[start] = 0;
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
    final goal = goalY * cols + goalX;
    return dist[goal] == -1 ? null : dist[goal];
  }
}
