import 'dart:math';

/// Puzzle scorrevole n×n: i numeri da 1 a n²-1 e uno spazio vuoto (0).
class SlideLogic {
  static List<int> solved(int n) => [for (var i = 1; i < n * n; i++) i, 0];

  static bool isSolved(List<int> t) {
    for (var i = 0; i < t.length - 1; i++) {
      if (t[i] != i + 1) return false;
    }
    return t.last == 0;
  }

  /// Mescola partendo dalla soluzione con mosse valide: sempre risolvibile.
  static List<int> shuffled(int n, Random rand) {
    final t = solved(n);
    var blank = t.length - 1;
    var prev = -1;
    do {
      for (var k = 0; k < n * n * 25; k++) {
        final r = blank ~/ n, c = blank % n;
        final opts = <int>[
          if (r > 0) blank - n,
          if (r < n - 1) blank + n,
          if (c > 0) blank - 1,
          if (c < n - 1) blank + 1,
        ]..remove(prev);
        final next = opts[rand.nextInt(opts.length)];
        t[blank] = t[next];
        t[next] = 0;
        prev = blank;
        blank = next;
      }
    } while (isSolved(t));
    return t;
  }

  /// Tocca la tessera [i]: se è nella riga o colonna dello spazio vuoto,
  /// scorre insieme alle tessere in mezzo. Restituisce il numero di mosse (0 se non valida).
  static int slide(List<int> t, int n, int i) {
    final blank = t.indexOf(0);
    final r = i ~/ n, c = i % n, br = blank ~/ n, bc = blank % n;
    if (i == blank || (r != br && c != bc)) return 0;
    final step = r == br ? (c < bc ? 1 : -1) : (r < br ? n : -n);
    var cur = blank;
    var count = 0;
    while (cur != i) {
      final from = cur - step;
      t[cur] = t[from];
      cur = from;
      count++;
    }
    t[i] = 0;
    return count;
  }
}
