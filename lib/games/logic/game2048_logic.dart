import 'dart:math';

enum Dir2048 { up, down, left, right }

/// Tessera che sta scivolando verso una fusione (serve solo per l'animazione).
class Ghost2048 {
  final int id;
  final int value;
  final int to; // indice della cella dove si fonde
  const Ghost2048(this.id, this.value, this.to);
}

class Game2048 {
  final int n;
  final Random _r;
  late List<int> cells;
  int score = 0;

  /// Identità delle tessere (0 = vuota), parallela a [cells]: permette di
  /// animare lo spostamento di ogni tessera.
  late List<int> ids;
  int _nextId = 1;

  /// Dati dell'ultima mossa, per l'animazione.
  List<Ghost2048> ghosts = const [];
  Set<int> mergedIds = const {};
  int? spawnedId;

  Game2048(this.n, this._r) {
    cells = List.filled(n * n, 0);
    ids = List.filled(n * n, 0);
    _spawn();
    _spawn();
    spawnedId = null;
  }

  Game2048.fromCells(this.n, List<int> initial, this._r, {this.score = 0}) {
    cells = List<int>.from(initial);
    ids = [for (final v in cells) v == 0 ? 0 : _nextId++];
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
    final at = free[_r.nextInt(free.length)];
    cells[at] = _r.nextInt(10) == 0 ? 4 : 2;
    ids[at] = spawnedId = _nextId++;
  }

  /// Esegue la mossa; true se qualcosa è cambiato (e allora appare un nuovo numero).
  bool move(Dir2048 d) {
    var changed = false;
    final newGhosts = <Ghost2048>[];
    final newMerged = <int>{};
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
      final src = [for (final i in idx) if (cells[i] != 0) i];
      final outV = <int>[], outId = <int>[];
      for (var i = 0; i < src.length; i++) {
        final v = cells[src[i]];
        if (i + 1 < src.length && cells[src[i + 1]] == v) {
          final dest = idx[outV.length];
          newGhosts.add(Ghost2048(ids[src[i]], v, dest));
          newGhosts.add(Ghost2048(ids[src[i + 1]], v, dest));
          final id = _nextId++;
          newMerged.add(id);
          outV.add(v * 2);
          outId.add(id);
          score += v * 2;
          i++;
        } else {
          outV.add(v);
          outId.add(ids[src[i]]);
        }
      }
      for (var i = 0; i < n; i++) {
        final v = i < outV.length ? outV[i] : 0;
        final id = i < outId.length ? outId[i] : 0;
        if (cells[idx[i]] != v) changed = true;
        cells[idx[i]] = v;
        ids[idx[i]] = id;
      }
    }
    if (!changed) return false;
    ghosts = newGhosts;
    mergedIds = newMerged;
    spawnedId = null;
    _spawn();
    return true;
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
