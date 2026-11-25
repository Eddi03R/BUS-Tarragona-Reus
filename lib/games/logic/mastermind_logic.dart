import 'dart:math';

/// Mastermind: il telefono sceglie un codice di colori, tu lo indovini dagli indizi.
class MastermindLogic {
  /// Pioli del codice, colori in uso e tentativi per difficoltà (0 facile … 2 difficile).
  static int pegs(int d) => const [4, 4, 5][d];
  static int colors(int d) => const [5, 6, 7][d];
  static int attempts(int d) => const [10, 9, 9][d];

  static List<int> newCode(int d, Random r) =>
      List.generate(pegs(d), (_) => r.nextInt(colors(d)));

  /// (esatti, parziali): esatti = colore giusto al posto giusto; parziali =
  /// colore giusto al posto sbagliato.
  static (int, int) score(List<int> code, List<int> guess) {
    var exact = 0;
    final inCode = <int, int>{}, inGuess = <int, int>{};
    for (var i = 0; i < code.length; i++) {
      if (code[i] == guess[i]) {
        exact++;
      } else {
        inCode[code[i]] = (inCode[code[i]] ?? 0) + 1;
        inGuess[guess[i]] = (inGuess[guess[i]] ?? 0) + 1;
      }
    }
    var partial = 0;
    inGuess.forEach((c, n) => partial += min(n, inCode[c] ?? 0));
    return (exact, partial);
  }
}
