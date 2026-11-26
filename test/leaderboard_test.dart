import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/game_art.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/services/leaderboard.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('la sfida ruota: stessa per tutti, cambia ogni settimana', () {
    final w = Leaderboard.weekOf(DateTime.utc(2026, 11, 26));
    expect(Leaderboard.challengeFor(w), Leaderboard.challengeFor(w));
    expect(Leaderboard.challengeFor(w), isNot(Leaderboard.challengeFor(w + 1)));
    // dopo un giro di 8 giochi cambia la difficoltà
    expect(Leaderboard.challengeFor(0), (GameKind.ticTacToe, Difficulty.easy));
    expect(Leaderboard.challengeFor(8), (GameKind.ticTacToe, Difficulty.medium));
  });

  test('la settimana cambia il lunedì', () {
    // 2026-11-23 è un lunedì
    final mon = Leaderboard.weekOf(DateTime(2026, 11, 23));
    expect(Leaderboard.weekOf(DateTime(2026, 11, 22)), mon - 1);
    expect(Leaderboard.weekOf(DateTime(2026, 11, 29)), mon);
    expect(Leaderboard.weekOf(DateTime(2026, 11, 30)), mon + 1);
  });

  test('nomi: formato e parolacce', () {
    expect(Leaderboard.isValidName('Marta_92'), isTrue);
    expect(Leaderboard.isValidName('ab'), isFalse);
    expect(Leaderboard.isValidName('nome con spazi'), isFalse);
    expect(Leaderboard.isBadName('Cazz0'), isTrue);
    expect(Leaderboard.isBadName('computare'), isFalse);
    expect(Leaderboard.isBadName('Marta'), isFalse);
  });

  test('il nome si cambia una volta al mese', () {
    final now = DateTime(2026, 11, 26);
    expect(Leaderboard.renameAvailableFrom(null, now), isNull); // mai cambiato
    expect(Leaderboard.renameAvailableFrom(DateTime(2026, 11, 10), now), DateTime(2026, 12, 10));
    expect(Leaderboard.renameAvailableFrom(DateTime(2026, 10, 27), now), isNull); // passati 30 giorni
    expect(Leaderboard.renameAvailableFrom(DateTime(2026, 11, 10), now, 0), isNull); // il primo cambio è libero
  });

  test('record: vinte, perse e vinte della sfida', () async {
    SharedPreferences.setMockInitialValues({});
    final w = Leaderboard.weekOf(DateTime.now());
    final (g, d) = Leaderboard.challengeFor(w);
    final lb = Leaderboard.instance;
    await lb.record(g, d, ResultKind.win);
    await lb.record(g, d, ResultKind.lose);
    await lb.record(g, Difficulty.values[(d.index + 1) % 3], ResultKind.win);
    expect(lb.wins(g) - 0, greaterThanOrEqualTo(2));
    expect(GameStats.instance.value('wk${w}_ch'), 1); // solo la vittoria nella difficoltà della sfida
    final before = lb.wins(g);
    await lb.record(g, d, ResultKind.win, once: 'x1');
    await lb.record(g, d, ResultKind.win, once: 'x1');
    expect(lb.wins(g), before + 1); // lo stesso `once` conta una volta sola
  });
}
