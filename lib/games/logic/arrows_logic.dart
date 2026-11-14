import 'dart:math';

/// Una freccia: una linea spezzata sulla griglia, dalla coda alla punta.
/// La direzione è quella dell'ultimo tratto (penultima cella → punta).
class Arrow {
  final List<int> cells; // coda → punta
  final int dx, dy;
  const Arrow(this.cells, this.dx, this.dy);

  int get head => cells.last;
}

/// Un livello di "Frecce": tocca una freccia e scivola fuori dal tabellone
/// nella sua direzione, ma solo se la strada davanti alla punta è libera.
class ArrowsLevel {
  final int n;
  final List<Arrow> arrows;

  /// Un ordine in cui il livello si risolve di sicuro (indici di [arrows]).
  final List<int> solution;
  const ArrowsLevel(this.n, this.arrows, this.solution);

  /// Celle davanti alla punta, fino al bordo.
  List<int> ray(int i) {
    final a = arrows[i];
    final out = <int>[];
    var x = a.head % n + a.dx, y = a.head ~/ n + a.dy;
    while (x >= 0 && y >= 0 && x < n && y < n) {
      out.add(y * n + x);
      x += a.dx;
      y += a.dy;
    }
    return out;
  }

  /// Quante celle libere ha davanti la freccia [i] prima di una freccia
  /// ancora sul tabellone; null = strada libera fino al bordo.
  int? blockedAfter(int i, List<bool> removed) {
    final occ = <int>{
      for (var j = 0; j < arrows.length; j++)
        if (!removed[j] && j != i) ...arrows[j].cells
    };
    final r = ray(i);
    for (var k = 0; k < r.length; k++) {
      if (occ.contains(r[k])) return k;
    }
    return null;
  }

  bool canExit(int i, List<bool> removed) => !removed[i] && blockedAfter(i, removed) == null;
}

class ArrowsLogic {
  /// Lato della griglia e lunghezza massima delle frecce per difficoltà.
  static (int, int) paramsFor(int difficulty) => const [(7, 5), (10, 7), (13, 9)][difficulty];

  /// Livello deterministico: stessa difficoltà e stesso numero = stesso schema.
  ///
  /// Si costruisce al contrario: ogni freccia aggiunta deve avere la strada
  /// libera rispetto a quelle già messe (che usciranno dopo di lei). Quindi
  /// togliendole nell'ordine inverso il livello si risolve sempre; le frecce
  /// nuove però possono sbarrare la strada alle vecchie.
  static ArrowsLevel generate(int difficulty, int level) {
    final (n, maxLen) = paramsFor(difficulty);
    final r = Random(difficulty * 100003 + level * 7919 + 17);
    final occ = List<bool>.filled(n * n, false);
    final arrows = <Arrow>[];
    const dirs = [(1, 0), (-1, 0), (0, 1), (0, -1)];
    // Per ogni freccia già messa: le celle della sua strada e se è già sbarrata.
    final rays = <Set<int>>[];
    final blocked = <bool>[];
    var fails = 0;
    while (fails < 60) {
      // Tra più candidate sceglie quella che sbarra più strade (meglio se
      // ancora libere): così l'ordine giusto conta davvero.
      Arrow? best;
      var bestScore = -1;
      for (var k = 0; k < 14; k++) {
        // finché si può, niente punte già affacciate sul bordo (sarebbero sempre libere)
        final a = _tryPlace(n, maxLen, occ, r, dirs, minRay: fails < 40 ? 2 : 0);
        if (a == null) continue;
        var score = a.cells.length;
        for (var j = 0; j < rays.length; j++) {
          if (a.cells.any(rays[j].contains)) score += blocked[j] ? 2 : 9;
        }
        if (score > bestScore) {
          bestScore = score;
          best = a;
        }
      }
      if (best == null) {
        fails++;
        continue;
      }
      fails = 0;
      for (var j = 0; j < rays.length; j++) {
        if (best.cells.any(rays[j].contains)) blocked[j] = true;
      }
      for (final c in best.cells) {
        occ[c] = true;
      }
      arrows.add(best);
      final lvl = ArrowsLevel(n, arrows, const []);
      rays.add(lvl.ray(arrows.length - 1).toSet());
      blocked.add(false);
    }
    return ArrowsLevel(n, arrows, [for (var i = arrows.length - 1; i >= 0; i--) i]);
  }

  static Arrow? _tryPlace(int n, int maxLen, List<bool> occ, Random r, List<(int, int)> dirs,
      {int minRay = 0}) {
    final head = r.nextInt(n * n);
    if (occ[head]) return null;
    final (dx, dy) = dirs[r.nextInt(4)];
    final hx = head % n, hy = head ~/ n;
    // la strada davanti alla punta deve essere libera
    final ray = <int>{};
    var x = hx + dx, y = hy + dy;
    while (x >= 0 && y >= 0 && x < n && y < n) {
      if (occ[y * n + x]) return null;
      ray.add(y * n + x);
      x += dx;
      y += dy;
    }
    if (ray.length < minRay) return null;
    // il corpo parte dietro la punta e gira a caso tra le celle libere
    final bx = hx - dx, by = hy - dy;
    if (bx < 0 || by < 0 || bx >= n || by >= n || occ[by * n + bx]) return null;
    final body = <int>[head, by * n + bx];
    final want = 2 + r.nextInt(maxLen - 1);
    var cdx = -dx, cdy = -dy;
    while (body.length < want) {
      final cx = body.last % n, cy = body.last ~/ n;
      final options = <(int, int)>[];
      for (final (ox, oy) in dirs) {
        final nx = cx + ox, ny = cy + oy;
        if (nx < 0 || ny < 0 || nx >= n || ny >= n) continue;
        final c = ny * n + nx;
        if (occ[c] || body.contains(c) || ray.contains(c)) continue;
        options.add((ox, oy));
        // preferisce proseguire dritto: linee più pulite
        if (ox == cdx && oy == cdy) options.add((ox, oy));
      }
      if (options.isEmpty) break;
      final (ox, oy) = options[r.nextInt(options.length)];
      cdx = ox;
      cdy = oy;
      body.add((cy + oy) * n + cx + ox);
    }
    return Arrow(body.reversed.toList(), dx, dy);
  }
}
