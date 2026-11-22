import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/briscola_screen.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reus_tarragona_bus/games/logic/briscola_logic.dart';

void main() {
  test('forza e punti', () {
    expect(const BCard(0, 1).points, 11);
    expect(const BCard(0, 3).points, 10);
    expect(const BCard(0, 3).strength > const BCard(0, 10).strength, isTrue);
    expect(const BCard(0, 2).points + const BCard(0, 7).points, 0);
  });

  test('chi prende la mano', () {
    const trump = 1;
    expect(BriscolaGame.followerWins(const BCard(0, 7), const BCard(0, 10), trump), isTrue); // stesso seme, più alta
    expect(BriscolaGame.followerWins(const BCard(0, 1), const BCard(0, 3), trump), isFalse); // asso batte tre
    expect(BriscolaGame.followerWins(const BCard(0, 1), const BCard(1, 2), trump), isTrue); // briscola
    expect(BriscolaGame.followerWins(const BCard(0, 1), const BCard(2, 1), trump), isFalse); // altro seme
    expect(BriscolaGame.followerWins(const BCard(1, 2), const BCard(1, 4), trump), isTrue); // entrambe briscola
  });

  test('partite complete a ogni livello: 120 punti, mani vuote, nessun errore', () {
    for (var level = 0; level < 3; level++) {
      for (var seed = 0; seed < 20; seed++) {
        final rnd = Random(seed);
        final g = BriscolaGame.deal(rnd, leader: seed % 2);
        expect(g.hands[0].length, 3);
        var tricks = 0;
        while (!g.isOver) {
          for (var k = 0; k < 2; k++) {
            final p = g.turn;
            g.play(p, BriscolaAi.choose(g, p, level, rnd));
          }
          g.resolveTrick();
          tricks++;
        }
        expect(tricks, 20);
        expect(g.score[0] + g.score[1], 120);
      }
    }
  });

  test('il telefono prende un carico con la briscola e non spreca asso di briscola su uno 0', () {
    final g = BriscolaGame.deal(Random(1), leader: 0);
    final trump = g.trump;
    final other = (trump + 1) % 4;
    g.hands[1]
      ..clear()
      ..addAll([BCard(trump, 2), BCard(other, 2), BCard(trump, 1)]);
    g.hands[0]
      ..clear()
      ..add(BCard(other, 1));
    g.table[0] = g.hands[0].removeAt(0); // tu giochi l'asso (11)
    final i = BriscolaAi.choose(g, 1, 2, Random(0));
    expect(g.hands[1][i].suit, trump);
    expect(g.hands[1][i].rank, 2); // la briscola più bassa
  });

  testWidgets('schermata: una partita intera con le animazioni arriva al risultato', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      locale: Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BriscolaScreen(),
    ));
    for (var i = 0; i < 800 && find.byType(ResultBanner).evaluate().isEmpty; i++) {
      await t.pump(const Duration(milliseconds: 150));
      final hand = find.byType(AnimatedPositioned);
      if (hand.evaluate().isNotEmpty) await t.tap(hand.first, warnIfMissed: false);
    }
    expect(find.byType(ResultBanner), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
  });

  testWidgets('schermata: se lanci per primo, la tua carta non si muove quando arriva quella del telefono', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.physicalSize = const Size(1080, 2340);
    t.view.devicePixelRatio = 2.625;
    addTearDown(t.view.reset);
    await t.pumpWidget(const MaterialApp(
      locale: Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: BriscolaScreen(),
    ));
    final human = find.byKey(const ValueKey('table-human'));
    final ai = find.byKey(const ValueKey('table-ai'));
    var checked = false;
    for (var game = 0; game < 30 && !checked; game++) {
      await t.pump(const Duration(milliseconds: 1500)); // pescata e, se tocca a lui, giocata del telefono
      if (ai.evaluate().isNotEmpty) {
        // ha iniziato il telefono: nuova partita finché non inizi tu
        await t.tap(find.byIcon(Icons.refresh_rounded), warnIfMissed: false);
        continue;
      }
      await t.tap(find.byType(AnimatedPositioned).first, warnIfMissed: false);
      await t.pump(const Duration(milliseconds: 700)); // la carta è arrivata sul tavolo
      final before = t.getTopLeft(human);
      for (var i = 0; i < 40 && ai.evaluate().isEmpty; i++) {
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(ai, findsOneWidget);
      for (final ms in [16, 50, 120]) {
        await t.pump(Duration(milliseconds: ms));
        expect(t.getTopLeft(human), before, reason: 'la carta lanciata deve restare ferma');
      }
      checked = true;
    }
    expect(checked, isTrue);
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 3));
  });
}
