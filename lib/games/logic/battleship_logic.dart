import 'dart:math';

class BattleshipBoard {
  static const size = 8;
  static const shipLengths = [4, 3, 3, 2, 2];

  final List<int> ship = List<int>.filled(size * size, -1); // id nave o -1
  final List<bool> shot = List<bool>.filled(size * size, false);
  final List<List<int>> shipCells = [];

  BattleshipBoard();

  factory BattleshipBoard.random(Random r) {
    final b = BattleshipBoard();
    for (var id = 0; id < shipLengths.length; id++) {
      final len = shipLengths[id];
      while (true) {
        final horizontal = r.nextBool();
        final x = r.nextInt(horizontal ? size - len + 1 : size);
        final y = r.nextInt(horizontal ? size : size - len + 1);
        final cells = [
          for (var k = 0; k < len; k++) horizontal ? y * size + x + k : (y + k) * size + x
        ];
        if (cells.any((c) => b.ship[c] != -1)) continue;
        for (final c in cells) {
          b.ship[c] = id;
        }
        b.shipCells.add(cells);
        break;
      }
    }
    return b;
  }

  /// Spara su [idx]; true se colpisce una nave.
  bool fire(int idx) {
    shot[idx] = true;
    return ship[idx] != -1;
  }

  bool isSunk(int id) => shipCells[id].every((c) => shot[c]);

  bool get allSunk => List.generate(shipCells.length, (i) => i).every(isSunk);
}

/// Avversario: caccia a scacchiera, poi insegue i colpi andati a segno.
class BattleshipAi {
  static int nextShot(BattleshipBoard b, Random r) {
    const size = BattleshipBoard.size;
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
        final pool = aligned.isNotEmpty ? aligned : candidates.toList();
        return pool[r.nextInt(pool.length)];
      }
    }
    final parity = <int>[
      for (var i = 0; i < size * size; i++)
        if (!b.shot[i] && ((i % size) + (i ~/ size)) % 2 == 0) i
    ];
    final free = parity.isNotEmpty
        ? parity
        : [for (var i = 0; i < size * size; i++) if (!b.shot[i]) i];
    return free[r.nextInt(free.length)];
  }
}
