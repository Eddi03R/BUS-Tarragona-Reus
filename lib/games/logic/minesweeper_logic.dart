import 'dart:math';

/// Campo minato: le mine vengono piazzate al primo tocco, così il primo
/// riquadro (e quelli intorno) è sempre sicuro.
class MinesBoard {
  final int rows;
  final int cols;
  final int mines;
  late final List<bool> mine = List.filled(rows * cols, false);
  late final List<int> near = List.filled(rows * cols, 0);
  late final List<bool> open = List.filled(rows * cols, false);
  late final List<bool> flag = List.filled(rows * cols, false);
  bool generated = false;
  bool lost = false;
  int? explodedAt;

  MinesBoard(this.rows, this.cols, this.mines);

  static MinesBoard forDifficulty(int d) => switch (d) {
        0 => MinesBoard(9, 8, 10),
        1 => MinesBoard(11, 9, 18),
        _ => MinesBoard(13, 10, 30),
      };

  int idx(int r, int c) => r * cols + c;

  Iterable<int> neighbors(int i) sync* {
    final r = i ~/ cols, c = i % cols;
    for (var dr = -1; dr <= 1; dr++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (dr == 0 && dc == 0) continue;
        final rr = r + dr, cc = c + dc;
        if (rr >= 0 && rr < rows && cc >= 0 && cc < cols) yield idx(rr, cc);
      }
    }
  }

  void _generate(int safe, Random rand) {
    final banned = {safe, ...neighbors(safe)};
    final cells = [for (var i = 0; i < rows * cols; i++) if (!banned.contains(i)) i]..shuffle(rand);
    for (final i in cells.take(mines)) {
      mine[i] = true;
    }
    for (var i = 0; i < rows * cols; i++) {
      near[i] = neighbors(i).where((j) => mine[j]).length;
    }
    generated = true;
  }

  bool get won {
    if (lost) return false;
    for (var i = 0; i < rows * cols; i++) {
      if (!mine[i] && !open[i]) return false;
    }
    return generated;
  }

  int get flagsLeft => mines - flag.where((f) => f).length;

  void toggleFlag(int i) {
    if (open[i] || lost) return;
    flag[i] = !flag[i];
  }

  /// Scopre un riquadro. Se è già scoperto e le bandiere intorno bastano,
  /// scopre i vicini ("accordo").
  void reveal(int i, Random rand) {
    if (lost || flag[i]) return;
    if (!generated) _generate(i, rand);
    if (open[i]) {
      final f = neighbors(i).where((j) => flag[j]).length;
      if (near[i] > 0 && f == near[i]) {
        for (final j in neighbors(i)) {
          if (!open[j] && !flag[j]) _open(j);
        }
      }
      return;
    }
    _open(i);
  }

  void _open(int start) {
    final stack = [start];
    while (stack.isNotEmpty) {
      final i = stack.removeLast();
      if (open[i] || flag[i]) continue;
      open[i] = true;
      if (mine[i]) {
        lost = true;
        explodedAt = i;
        for (var k = 0; k < rows * cols; k++) {
          if (mine[k]) open[k] = true;
        }
        return;
      }
      if (near[i] == 0) stack.addAll(neighbors(i));
    }
  }
}
