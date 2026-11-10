import 'dart:math';

/// Puzzle "Collega i punti": coppie di punti dello stesso colore da unire con
/// un percorso, senza incroci. Si genera da una soluzione che copre tutta la
/// griglia, quindi è sempre risolvibile.
class FlowPuzzle {
  final int n;
  final List<(int, int)> endpoints; // per colore: (estremo A, estremo B)
  final List<List<int>> solution; // percorsi della soluzione
  const FlowPuzzle(this.n, this.endpoints, this.solution);

  /// Dimensione e numero di colori in base alla difficoltà.
  static (int, int) paramsFor(int difficulty) => const [(5, 4), (6, 5), (7, 6)][difficulty];

  static FlowPuzzle generate(int difficulty, Random r) {
    final (n, colors) = paramsFor(difficulty);
    final path = _hamiltonianPath(n, r);
    final total = n * n;
    // Taglia il percorso in [colors] segmenti lunghi almeno 3 celle.
    const minLen = 3;
    final cuts = <int>[];
    while (true) {
      cuts.clear();
      final spare = total - colors * minLen;
      final extra = List<int>.filled(colors, 0);
      for (var i = 0; i < spare; i++) {
        extra[r.nextInt(colors)]++;
      }
      var pos = 0;
      for (var i = 0; i < colors; i++) {
        pos += minLen + extra[i];
        cuts.add(pos);
      }
      break;
    }
    final segments = <List<int>>[];
    var start = 0;
    for (final c in cuts) {
      segments.add(path.sublist(start, c));
      start = c;
    }
    return FlowPuzzle(n, [for (final s in segments) (s.first, s.last)], segments);
  }

  /// Percorso hamiltoniano casuale sulla griglia: parte dal serpentone e lo
  /// rimescola con mosse "backbite" (restano sempre percorsi che toccano tutte le celle).
  static List<int> _hamiltonianPath(int n, Random r) {
    var path = <int>[
      for (var y = 0; y < n; y++)
        for (var x = 0; x < n; x++) y * n + (y.isEven ? x : n - 1 - x)
    ];
    final iterations = n * n * 20;
    for (var it = 0; it < iterations; it++) {
      if (r.nextBool()) path = path.reversed.toList();
      final head = path.last;
      final hx = head % n, hy = head ~/ n;
      final neighbors = <int>[];
      for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
        final nx = hx + d[0], ny = hy + d[1];
        if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
        neighbors.add(ny * n + nx);
      }
      final pick = neighbors[r.nextInt(neighbors.length)];
      final j = path.indexOf(pick);
      if (j >= path.length - 2) continue; // è già il vicino nel percorso
      path = [...path.sublist(0, j + 1), ...path.sublist(j + 1).reversed];
    }
    return path;
  }
}

/// Stato di gioco: i percorsi disegnati dall'utente.
class FlowBoard {
  final FlowPuzzle puzzle;
  final List<List<int>> paths; // per colore, parte da un estremo
  int? active;

  FlowBoard(this.puzzle)
      : paths = List.generate(puzzle.endpoints.length, (_) => <int>[]);

  int? endpointColor(int cell) {
    for (var c = 0; c < puzzle.endpoints.length; c++) {
      if (puzzle.endpoints[c].$1 == cell || puzzle.endpoints[c].$2 == cell) return c;
    }
    return null;
  }

  int? colorAt(int cell) {
    for (var c = 0; c < paths.length; c++) {
      if (paths[c].contains(cell)) return c;
    }
    return null;
  }

  bool _isComplete(int c) {
    final p = paths[c];
    if (p.length < 2) return false;
    final (a, b) = puzzle.endpoints[c];
    return (p.first == a && p.last == b) || (p.first == b && p.last == a);
  }

  bool get solved => List.generate(paths.length, _isComplete).every((v) => v);

  /// Tutte le celle coperte (per il "perfetto")?
  bool get perfect => solved && paths.fold<int>(0, (a, p) => a + p.length) == puzzle.n * puzzle.n;

  void begin(int cell) {
    final e = endpointColor(cell);
    if (e != null) {
      paths[e] = [cell];
      active = e;
      return;
    }
    final c = colorAt(cell);
    if (c != null) {
      // riprende da una cella del proprio percorso
      paths[c] = paths[c].sublist(0, paths[c].indexOf(cell) + 1);
      active = c;
    } else {
      active = null;
    }
  }

  bool _adjacent(int a, int b) {
    final n = puzzle.n;
    final dx = (a % n - b % n).abs(), dy = (a ~/ n - b ~/ n).abs();
    return dx + dy == 1;
  }

  void extend(int cell) {
    final a = active;
    if (a == null) return;
    final path = paths[a];
    if (path.isEmpty) return;
    if (_isComplete(a) && path.last != cell && !path.contains(cell)) return;
    final last = path.last;
    if (cell == last) return;
    if (!_adjacent(last, cell)) return;
    final idx = path.indexOf(cell);
    if (idx >= 0) {
      paths[a] = path.sublist(0, idx + 1); // torna indietro
      return;
    }
    final e = endpointColor(cell);
    if (e != null && e != a) return; // non si passa sugli estremi di altri colori
    final other = colorAt(cell);
    if (other != null && other != a) {
      // attraversare un altro percorso lo interrompe da quel punto
      final op = paths[other];
      paths[other] = op.sublist(0, op.indexOf(cell));
    }
    if (_isComplete(a)) return;
    path.add(cell);
  }

  void end() => active = null;
}
