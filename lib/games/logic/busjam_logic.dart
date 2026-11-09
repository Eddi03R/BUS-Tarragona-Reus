import 'dart:math';

/// Un mezzo sulla griglia 6x6. [fixed] è la riga (se orizzontale) o la colonna.
class JamVehicle {
  final bool horizontal;
  final int len;
  final int fixed;
  const JamVehicle(this.horizontal, this.len, this.fixed);
}

class JamLevel {
  final List<JamVehicle> vehicles; // il numero 0 è il bus rosso
  final List<int> start; // posizione lungo l'asse (colonna o riga di partenza)
  final int minMoves;
  const JamLevel(this.vehicles, this.start, this.minMoves);
}

class JamLogic {
  static const size = 6;
  static const exitRow = 2;

  static List<bool> occupancy(List<JamVehicle> v, List<int> pos) {
    final occ = List<bool>.filled(size * size, false);
    for (var i = 0; i < v.length; i++) {
      for (var k = 0; k < v[i].len; k++) {
        final x = v[i].horizontal ? pos[i] + k : v[i].fixed;
        final y = v[i].horizontal ? v[i].fixed : pos[i] + k;
        occ[y * size + x] = true;
      }
    }
    return occ;
  }

  /// Posizioni minima e massima raggiungibili dal mezzo [i], con gli altri fermi.
  static (int, int) reach(List<JamVehicle> v, List<int> pos, int i, List<bool> occ) {
    final veh = v[i];
    bool free(int p) {
      final x = veh.horizontal ? p : veh.fixed;
      final y = veh.horizontal ? veh.fixed : p;
      return !occ[y * size + x];
    }

    var lo = pos[i];
    while (lo - 1 >= 0 && free(lo - 1)) {
      lo--;
    }
    var hi = pos[i];
    while (hi + veh.len < size && free(hi + veh.len)) {
      hi++;
    }
    return (lo, hi);
  }

  static bool solved(List<JamVehicle> v, List<int> pos) => pos[0] == size - v[0].len;

  static int _key(List<int> pos) {
    var k = 0;
    for (final p in pos) {
      k = k * 6 + p;
    }
    return k;
  }

  /// Numero minimo di mosse (uno scorrimento di qualsiasi lunghezza = 1 mossa),
  /// oppure null se irrisolvibile (o troppo grande da esplorare).
  static int? solve(List<JamVehicle> v, List<int> start, {int maxStates = 150000}) {
    if (solved(v, start)) return 0;
    final seen = <int>{_key(start)};
    var frontier = <List<int>>[start];
    var depth = 0;
    while (frontier.isNotEmpty) {
      depth++;
      final next = <List<int>>[];
      for (final pos in frontier) {
        final occ = occupancy(v, pos);
        for (var i = 0; i < v.length; i++) {
          final (lo, hi) = reach(v, pos, i, occ);
          for (var p = lo; p <= hi; p++) {
            if (p == pos[i]) continue;
            final np = List<int>.from(pos)..[i] = p;
            final key = _key(np);
            if (!seen.add(key)) continue;
            if (solved(v, np)) return depth;
            next.add(np);
          }
        }
      }
      if (seen.length > maxStates) return null;
      frontier = next;
    }
    return null;
  }

  static const maxLevel = 30;

  /// Livello [level] (1..30): sempre lo stesso per lo stesso numero, risolvibile
  /// e sempre più difficile. Il bus rosso (id 0) è sulla riga di uscita.
  static JamLevel generate(int level) {
    final r = Random(level * 7919 + 13);
    final target = min(3 + (level * 0.7).round(), 18);
    final count = min(5 + level ~/ 4, 11);
    JamLevel? best;
    for (var attempt = 0; attempt < 120; attempt++) {
      final vehicles = <JamVehicle>[const JamVehicle(true, 2, exitRow)];
      final pos = <int>[r.nextInt(3)]; // il rosso parte a colonna 0..2
      final occ = occupancy(vehicles, pos);
      var tries = 0;
      while (vehicles.length < count && tries < 200) {
        tries++;
        final horizontal = r.nextBool();
        final len = r.nextInt(10) < 7 ? 2 : 3;
        final fixed = r.nextInt(size);
        if (horizontal && fixed == exitRow) continue; // bloccherebbe il rosso
        final p = r.nextInt(size - len + 1);
        final cells = [
          for (var k = 0; k < len; k++)
            horizontal ? fixed * size + p + k : (p + k) * size + fixed
        ];
        if (cells.any((c) => occ[c])) continue;
        for (final c in cells) {
          occ[c] = true;
        }
        vehicles.add(JamVehicle(horizontal, len, fixed));
        pos.add(p);
      }
      final moves = solve(vehicles, pos);
      if (moves == null || moves == 0) continue;
      final candidate = JamLevel(vehicles, pos, moves);
      if (best == null || moves > best.minMoves) best = candidate;
      if (moves >= target) return candidate;
    }
    return best ??
        const JamLevel([JamVehicle(true, 2, exitRow)], [0], 1);
  }
}
