import 'dart:math';

/// Puzzle "Collega i punti": coppie di punti dello stesso colore da unire con
/// un percorso, senza incroci. Si genera da una soluzione che copre tutta la
/// griglia e si tiene solo se è l'**unica** soluzione possibile: così, unite
/// tutte le coppie, i riquadri sono per forza tutti occupati.
class FlowPuzzle {
  final int n;
  final List<(int, int)> endpoints; // per colore: (estremo A, estremo B)
  final List<List<int>> solution; // percorsi della soluzione
  const FlowPuzzle(this.n, this.endpoints, this.solution);

  /// Dimensione e numero massimo di colori in base alla difficoltà.
  static (int, int) paramsFor(int difficulty) => const [(5, 6), (6, 7), (7, 8)][difficulty];

  static const _minColors = [4, 5, 6];

  static FlowPuzzle generate(int difficulty, Random r) {
    final (n, maxColors) = paramsFor(difficulty);
    FlowPuzzle? fallback;
    for (var attempt = 0; attempt < 4000; attempt++) {
      final segments = _cut(_hamiltonianPath(n, r), n, r);
      if (segments == null ||
          segments.length > maxColors ||
          segments.length < _minColors[difficulty]) {
        continue;
      }
      final p = FlowPuzzle(n, [for (final s in segments) (s.first, s.last)], segments);
      fallback ??= p;
      if (p.solutionCount() == 1) return p;
    }
    // Praticamente impossibile arrivare qui; in ogni caso lo schema è risolvibile.
    return fallback ?? FlowPuzzle(n, [for (var y = 0; y < n; y++) (y * n, y * n + n - 1)],
        [for (var y = 0; y < n; y++) [for (var x = 0; x < n; x++) y * n + x]]);
  }

  static bool _adj(int a, int b, int n) {
    final dx = (a % n - b % n).abs(), dy = (a ~/ n - b ~/ n).abs();
    return dx + dy == 1;
  }

  /// Taglia il percorso in segmenti che non si "toccano da soli" (nessuna
  /// scorciatoia possibile dentro un colore) e lunghi almeno 3 celle.
  static List<List<int>>? _cut(List<int> path, int n, Random r) {
    final segments = <List<int>>[];
    var seg = <int>[];
    for (final c in path) {
      var touches = false;
      for (var i = 0; i < seg.length - 1; i++) {
        if (_adj(seg[i], c, n)) {
          touches = true;
          break;
        }
      }
      // ogni tanto taglia anche senza obbligo, per variare le lunghezze
      if (touches || (seg.length >= 3 && r.nextInt(9) == 0)) {
        if (seg.length < 3) return null;
        segments.add(seg);
        seg = <int>[];
      }
      seg.add(c);
    }
    if (seg.length < 3) return null;
    segments.add(seg);
    return segments;
  }

  /// Conta le soluzioni (fino a [limit]) in cui ogni coppia è unita senza
  /// incroci, **anche senza riempire la griglia**. Basta cercare i percorsi
  /// senza scorciatoie: ogni altra soluzione si accorcia in una di queste.
  /// Restituisce [limit] anche se la ricerca diventa troppo lunga.
  int solutionCount({int limit = 2, int maxNodes = 60000}) {
    final k = endpoints.length;
    final occ = List<int>.filled(n * n, -1);
    final head = <int>[], target = <int>[];
    for (var c = 0; c < k; c++) {
      occ[endpoints[c].$1] = c;
      occ[endpoints[c].$2] = c;
      head.add(endpoints[c].$1);
      target.add(endpoints[c].$2);
    }
    final done = List<bool>.filled(k, false);
    final nb = [
      for (var i = 0; i < n * n; i++)
        [
          if (i % n > 0) i - 1,
          if (i % n < n - 1) i + 1,
          if (i >= n) i - n,
          if (i < n * (n - 1)) i + n,
        ]
    ];
    var nodes = 0, found = 0;
    final seen = List<int>.filled(n * n, 0);
    var stamp = 0;
    final queue = List<int>.filled(n * n, 0);

    bool reachable(int c) {
      stamp++;
      var qh = 0, qt = 0;
      queue[qt++] = head[c];
      seen[head[c]] = stamp;
      while (qh < qt) {
        final v = queue[qh++];
        for (final w in nb[v]) {
          if (w == target[c]) return true;
          if (occ[w] != -1 || seen[w] == stamp) continue;
          seen[w] = stamp;
          queue[qt++] = w;
        }
      }
      return false;
    }

    List<int> moves(int c) {
      final h = head[c];
      if (nb[h].contains(target[c])) return [target[c]];
      final out = <int>[];
      for (final w in nb[h]) {
        if (occ[w] != -1) continue;
        var ok = true;
        for (final x in nb[w]) {
          if (x != h && x != target[c] && occ[x] == c) {
            ok = false;
            break;
          }
        }
        if (ok) out.add(w);
      }
      return out;
    }

    void search() {
      if (found >= limit) return;
      if (++nodes > maxNodes) {
        found = limit;
        return;
      }
      int? best;
      List<int>? bestMoves;
      for (var c = 0; c < k; c++) {
        if (done[c]) continue;
        if (!reachable(c)) return;
        final m = moves(c);
        if (m.isEmpty) return;
        if (bestMoves == null || m.length < bestMoves.length) {
          best = c;
          bestMoves = m;
        }
      }
      if (best == null) {
        found++;
        return;
      }
      final c = best, h = head[c];
      for (final w in bestMoves!) {
        if (w == target[c]) {
          done[c] = true;
          search();
          done[c] = false;
        } else {
          occ[w] = c;
          head[c] = w;
          search();
          head[c] = h;
          occ[w] = -1;
        }
        if (found >= limit) return;
      }
    }

    search();
    return found;
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
