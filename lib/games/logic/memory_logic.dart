import 'dart:math';

class MemoryLogic {
  /// Coppie in base alla difficoltà: facile 6 (4×3), medio 8 (4×4), difficile 12 (6×4).
  static int pairsFor(int difficulty) => const [6, 8, 12][difficulty];
  static int columnsFor(int difficulty) => const [3, 4, 4][difficulty];

  /// Mazzo mescolato: ogni simbolo compare esattamente due volte.
  static List<int> deal(int pairs, Random r) {
    final symbols = List<int>.generate(pairs, (i) => i);
    return [...symbols, ...symbols]..shuffle(r);
  }
}
