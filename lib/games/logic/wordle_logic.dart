import 'dart:math';
import 'wordle_words.dart';

enum LetterState { absent, present, correct }

class WordleLogic {
  static const wordLength = 5;
  static const maxAttempts = 6;

  /// Colora un tentativo come Wordle (gestisce bene le lettere ripetute).
  static List<LetterState> evaluate(String guess, String answer) {
    final g = guess.toLowerCase(), a = answer.toLowerCase();
    final result = List<LetterState>.filled(g.length, LetterState.absent);
    final remaining = <String, int>{};
    for (var i = 0; i < a.length; i++) {
      if (i < g.length && g[i] == a[i]) {
        result[i] = LetterState.correct;
      } else {
        remaining[a[i]] = (remaining[a[i]] ?? 0) + 1;
      }
    }
    for (var i = 0; i < g.length; i++) {
      if (result[i] == LetterState.correct) continue;
      final left = remaining[g[i]] ?? 0;
      if (left > 0) {
        result[i] = LetterState.present;
        remaining[g[i]] = left - 1;
      }
    }
    return result;
  }

  static List<String> wordsFor(String language) =>
      wordleWords[language] ?? wordleWords['en']!;

  /// Giorni dal 1 gennaio 2024 (data locale): uguale per tutti nello stesso giorno.
  static int dayNumber(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(2024, 1, 1)).inDays;

  /// Parola del giorno: stessa per tutti gli utenti della stessa lingua.
  static String dailyWord(String language, DateTime date) {
    final words = wordsFor(language);
    final seed = language.codeUnits.fold<int>(7, (a, b) => a * 31 + b);
    final order = List<int>.generate(words.length, (i) => i)..shuffle(Random(seed));
    return words[order[dayNumber(date) % words.length]];
  }

  static String randomWord(String language, Random r) {
    final words = wordsFor(language);
    return words[r.nextInt(words.length)];
  }
}
