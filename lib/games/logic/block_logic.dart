import 'dart:math';

/// Pezzo di Blocchi 1010: celle come (riga, colonna) relative.
class BlockPiece {
  final List<(int, int)> cells;
  final int color; // 0..n-1 (per il colore)
  const BlockPiece(this.cells, this.color);

  int get height => cells.map((c) => c.$1).reduce(max) + 1;
  int get width => cells.map((c) => c.$2).reduce(max) + 1;
}

class BlockLogic {
  static const size = 10;
  static const colors = 7;

  static List<(int, int)> _shape(List<String> rows) => [
        for (var r = 0; r < rows.length; r++)
          for (var c = 0; c < rows[r].length; c++)
            if (rows[r][c] == '#') (r, c)
      ];

  static final Map<String, List<(int, int)>> _small = {
    'dot': _shape(['#']),
    'h2': _shape(['##']),
    'v2': _shape(['#', '#']),
    'h3': _shape(['###']),
    'v3': _shape(['#', '#', '#']),
    'sq2': _shape(['##', '##']),
    'l1': _shape(['#.', '##']),
    'l2': _shape(['.#', '##']),
    'l3': _shape(['##', '#.']),
    'l4': _shape(['##', '.#']),
    'h4': _shape(['####']),
    'v4': _shape(['#', '#', '#', '#']),
  };

  static final Map<String, List<(int, int)>> _big = {
    'h5': _shape(['#####']),
    'v5': _shape(['#', '#', '#', '#', '#']),
    'sq3': _shape(['###', '###', '###']),
    'r23': _shape(['###', '###']),
    'r32': _shape(['##', '##', '##']),
    'L1': _shape(['#..', '#..', '###']),
    'L2': _shape(['..#', '..#', '###']),
    'L3': _shape(['###', '#..', '#..']),
    'L4': _shape(['###', '..#', '..#']),
  };

  /// Insieme di forme in base alla difficoltà (0 facile, 1 medio, 2 difficile).
  static List<List<(int, int)>> pool(int difficulty) {
    final small = _small.values.toList();
    final big = _big.values.toList();
    switch (difficulty) {
      case 0:
        return small.where((s) => s.length <= 4).toList();
      case 1:
        return [...small, ...big];
      default:
        return [...small, ...big, ...big]; // i pezzi grandi sono più frequenti
    }
  }

  static BlockPiece randomPiece(Random r, int difficulty) {
    final p = pool(difficulty);
    return BlockPiece(p[r.nextInt(p.length)], r.nextInt(colors));
  }

  static bool canPlace(List<int> grid, BlockPiece p, int row, int col) {
    for (final (dr, dc) in p.cells) {
      final rr = row + dr, cc = col + dc;
      if (rr < 0 || cc < 0 || rr >= size || cc >= size) return false;
      if (grid[rr * size + cc] != 0) return false;
    }
    return true;
  }

  static bool canPlaceAnywhere(List<int> grid, BlockPiece p) {
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        if (canPlace(grid, p, r, c)) return true;
      }
    }
    return false;
  }

  /// Posiziona il pezzo e svuota righe e colonne complete. Restituisce
  /// quante linee sono state svuotate.
  static int place(List<int> grid, BlockPiece p, int row, int col) {
    for (final (dr, dc) in p.cells) {
      grid[(row + dr) * size + col + dc] = p.color + 1;
    }
    final fullRows = [
      for (var r = 0; r < size; r++)
        if (List.generate(size, (c) => grid[r * size + c]).every((v) => v != 0)) r
    ];
    final fullCols = [
      for (var c = 0; c < size; c++)
        if (List.generate(size, (r) => grid[r * size + c]).every((v) => v != 0)) c
    ];
    for (final r in fullRows) {
      for (var c = 0; c < size; c++) {
        grid[r * size + c] = 0;
      }
    }
    for (final c in fullCols) {
      for (var r = 0; r < size; r++) {
        grid[r * size + c] = 0;
      }
    }
    return fullRows.length + fullCols.length;
  }

  /// Punti: una per cella, più bonus crescente per le linee (combo).
  static int points(BlockPiece p, int lines) => p.cells.length + lines * lines * 10;
}
