import 'dart:math';

/// Travasa i colori (water sort): provette da 4 unità; versi la parte di
/// sopra di una provetta in un'altra se è vuota o se in cima ha lo stesso colore.
class WaterSortLogic {
  static const cap = 4;
  static const empties = 2;

  /// Colori per difficoltà (0 facile … 2 difficile).
  static int colors(int d) => const [4, 6, 8][d];

  static bool canPour(List<List<int>> t, int from, int to) {
    if (from == to || t[from].isEmpty || t[to].length >= cap) return false;
    return t[to].isEmpty || t[to].last == t[from].last;
  }

  /// Nuovo stato dopo aver versato [from] in [to] (tutto il colore di sopra che ci sta).
  static List<List<int>> pour(List<List<int>> t, int from, int to) {
    final n = [for (final x in t) List<int>.of(x)];
    final c = n[from].last;
    while (n[from].isNotEmpty && n[from].last == c && n[to].length < cap) {
      n[to].add(n[from].removeLast());
    }
    return n;
  }

  static bool isSolved(List<List<int>> t) =>
      t.every((x) => x.isEmpty || (x.length == cap && x.every((c) => c == x.first)));

  static String _key(List<List<int>> t) => ([for (final x in t) x.join(',')]..sort()).join('|');

  /// Una soluzione (lista di mosse) o null se non la trova entro il limite di stati.
  static List<(int, int)>? solve(List<List<int>> start, {int limit = 60000}) {
    final seen = <String>{_key(start)};
    final path = <(int, int)>[];
    var count = 0;
    bool dfs(List<List<int>> t) {
      if (isSolved(t)) return true;
      if (++count > limit) return false;
      for (var a = 0; a < t.length; a++) {
        if (t[a].isEmpty) continue;
        final uniform = t[a].every((c) => c == t[a].first);
        for (var b = 0; b < t.length; b++) {
          if (!canPour(t, a, b)) continue;
          if (t[b].isEmpty && uniform) continue; // spostare un colore già solo in una vuota non serve
          final n = pour(t, a, b);
          if (!seen.add(_key(n))) continue;
          path.add((a, b));
          if (dfs(n)) return true;
          path.removeLast();
        }
      }
      return false;
    }

    return dfs(start) ? List.of(path) : null;
  }

  /// Provette mescolate a caso (con 2 vuote), garantite risolvibili.
  static List<List<int>> generate(int d, Random r) {
    final n = colors(d);
    List<List<int>> t = [];
    for (var attempt = 0; attempt < 200; attempt++) {
      final units = [for (var c = 0; c < n; c++) ...List.filled(cap, c)]..shuffle(r);
      t = [
        for (var i = 0; i < n; i++) units.sublist(i * cap, (i + 1) * cap),
        for (var i = 0; i < empties; i++) <int>[],
      ];
      if (!isSolved(t) && solve(t) != null) return t;
    }
    return t;
  }
}
