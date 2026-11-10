import 'dart:math';

class BattleshipBoard {
  static const size = 8;
  static const shipLengths = [4, 3, 3, 2, 2];

  final List<int> ship = List<int>.filled(size * size, -1); // id nave o -1
  final List<bool> shot = List<bool>.filled(size * size, false);
  // Celle di ogni nave (lista vuota = non ancora posizionata).
  final List<List<int>> shipCells =
      List<List<int>>.generate(shipLengths.length, (_) => <int>[]);

  BattleshipBoard();

  factory BattleshipBoard.random(Random r) {
    final b = BattleshipBoard();
    b.fillRandomly(r);
    return b;
  }

  bool isPlaced(int id) => shipCells[id].isNotEmpty;
  bool get allPlaced => List.generate(shipCells.length, isPlaced).every((p) => p);

  /// Celle occupate dalla nave [id] con prua in (x, y), o null se non ci sta
  /// o si sovrappone a un'altra nave.
  List<int>? cellsFor(int id, int x, int y, bool horizontal) {
    final len = shipLengths[id];
    if (x < 0 || y < 0) return null;
    if (horizontal ? x + len > size : y + len > size) return null;
    final cells = [
      for (var k = 0; k < len; k++) horizontal ? y * size + x + k : (y + k) * size + x
    ];
    if (cells.any((c) => ship[c] != -1 && ship[c] != id)) return null;
    return cells;
  }

  /// Posiziona la nave [id]; false se non è possibile.
  bool place(int id, int x, int y, bool horizontal) {
    final cells = cellsFor(id, x, y, horizontal);
    if (cells == null) return false;
    remove(id);
    for (final c in cells) {
      ship[c] = id;
    }
    shipCells[id] = cells;
    return true;
  }

  void remove(int id) {
    for (final c in shipCells[id]) {
      ship[c] = -1;
    }
    shipCells[id] = <int>[];
  }

  void clearShips() {
    for (var id = 0; id < shipCells.length; id++) {
      remove(id);
    }
  }

  /// Posiziona a caso le navi non ancora posizionate.
  void fillRandomly(Random r) {
    for (var id = 0; id < shipLengths.length; id++) {
      if (isPlaced(id)) continue;
      while (true) {
        final horizontal = r.nextBool();
        final x = r.nextInt(size);
        final y = r.nextInt(size);
        if (place(id, x, y, horizontal)) break;
      }
    }
  }

  /// Spara su [idx]; true se colpisce una nave.
  bool fire(int idx) {
    shot[idx] = true;
    return ship[idx] != -1;
  }

  bool isSunk(int id) => shipCells[id].every((c) => shot[c]);

  bool get allSunk => List.generate(shipCells.length, (i) => i).every(isSunk);
}

/// Avversario del telefono. Facile: spara a caso. Medio: dopo un colpo a
/// segno insegue la nave. Difficile: caccia a scacchiera e insegue in linea.
class BattleshipAi {
  static int nextShot(BattleshipBoard b, Random r, {int level = 2}) {
    const size = BattleshipBoard.size;
    List<int> unshot() => [for (var i = 0; i < size * size; i++) if (!b.shot[i]) i];
    if (level == 0) {
      final free = unshot();
      return free[r.nextInt(free.length)];
    }
    final hits = <int>[
      for (var i = 0; i < size * size; i++)
        if (b.shot[i] && b.ship[i] != -1 && !b.isSunk(b.ship[i])) i
    ];
    if (hits.isNotEmpty) {
      final candidates = <int>{};
      for (final h in hits) {
        final x = h % size, y = h ~/ size;
        for (final d in const [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
          final nx = x + d[0], ny = y + d[1];
          if (nx < 0 || ny < 0 || nx >= size || ny >= size) continue;
          final ni = ny * size + nx;
          if (!b.shot[ni]) candidates.add(ni);
        }
      }
      if (candidates.isNotEmpty) {
        if (level >= 2) {
          // Se ci sono due colpi allineati, prosegui sulla stessa linea.
          final aligned = candidates.where((c) {
            final x = c % size, y = c ~/ size;
            return hits.any((h) {
              final hx = h % size, hy = h ~/ size;
              if (hy == y && (hx - x).abs() == 1) {
                final ox = hx + (hx - x);
                return ox >= 0 && ox < size && hits.contains(y * size + ox);
              }
              if (hx == x && (hy - y).abs() == 1) {
                final oy = hy + (hy - y);
                return oy >= 0 && oy < size && hits.contains(oy * size + x);
              }
              return false;
            });
          }).toList();
          if (aligned.isNotEmpty) return aligned[r.nextInt(aligned.length)];
        }
        final pool = candidates.toList();
        return pool[r.nextInt(pool.length)];
      }
    }
    if (level >= 2) {
      final parity = <int>[
        for (var i = 0; i < size * size; i++)
          if (!b.shot[i] && ((i % size) + (i ~/ size)) % 2 == 0) i
      ];
      if (parity.isNotEmpty) return parity[r.nextInt(parity.length)];
    }
    final free = unshot();
    return free[r.nextInt(free.length)];
  }
}
