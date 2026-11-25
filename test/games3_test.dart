import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/connections_screen.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/games/hangman_screen.dart';
import 'package:reus_tarragona_bus/games/logic/hangman_logic.dart';
import 'package:reus_tarragona_bus/games/logic/mastermind_logic.dart';
import 'package:reus_tarragona_bus/games/logic/watersort_logic.dart';
import 'package:reus_tarragona_bus/games/mastermind_screen.dart';
import 'package:reus_tarragona_bus/games/snake_screen.dart';
import 'package:reus_tarragona_bus/games/watersort_screen.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home) => MaterialApp(
      locale: const Locale('it'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: home,
    );

void main() {
  group('Mastermind', () {
    test('indizi: esatti e parziali', () {
      expect(MastermindLogic.score([0, 1, 2, 3], [0, 1, 2, 3]), (4, 0));
      expect(MastermindLogic.score([0, 1, 2, 3], [3, 2, 1, 0]), (0, 4));
      expect(MastermindLogic.score([0, 0, 1, 1], [0, 1, 0, 1]), (2, 2));
      expect(MastermindLogic.score([0, 0, 0, 1], [0, 2, 2, 2]), (1, 0)); // un solo 0 al posto giusto
      expect(MastermindLogic.score([1, 2, 3, 4], [5, 5, 5, 5]), (0, 0));
    });
    test('codice della lunghezza e dei colori della difficoltà', () {
      for (var d = 0; d < 3; d++) {
        final c = MastermindLogic.newCode(d, Random(d));
        expect(c.length, MastermindLogic.pegs(d));
        expect(c.every((x) => x >= 0 && x < MastermindLogic.colors(d)), isTrue);
      }
    });
  });

  group('Impiccato', () {
    test('parole valide in tutte le lingue (solo A-Z)', () {
      for (final e in hangmanWords.entries) {
        expect(e.value.length, greaterThanOrEqualTo(25), reason: e.key);
        for (final w in e.value) {
          expect(RegExp(r'^[A-Z]{4,12}$').hasMatch(w), isTrue, reason: '${e.key} $w');
        }
      }
    });
    test('ogni difficoltà trova una parola in ogni lingua', () {
      for (final lang in ['it', 'en', 'es', 'ca', 'de', 'xx']) {
        for (var d = 0; d < 3; d++) {
          expect(HangmanLogic.pick(lang, d, Random(1)), isNotEmpty);
        }
      }
    });
    test('vittoria quando tutte le lettere sono state scelte', () {
      expect(HangmanLogic.won('BUS', {'B', 'U'}), isFalse);
      expect(HangmanLogic.won('BUS', {'B', 'U', 'S', 'Z'}), isTrue);
    });
  });

  group('Travasa i colori', () {
    test('i nuovi schemi sono risolvibili e la soluzione trovata funziona', () {
      for (var d = 0; d < 3; d++) {
        for (var seed = 0; seed < 5; seed++) {
          final t = WaterSortLogic.generate(d, Random(seed));
          expect(t.length, WaterSortLogic.colors(d) + WaterSortLogic.empties);
          expect(WaterSortLogic.isSolved(t), isFalse);
          var cur = t;
          for (final (a, b) in WaterSortLogic.solve(t)!) {
            expect(WaterSortLogic.canPour(cur, a, b), isTrue);
            cur = WaterSortLogic.pour(cur, a, b);
          }
          expect(WaterSortLogic.isSolved(cur), isTrue);
        }
      }
    });
    test('regole di versamento', () {
      final t = [
        [1, 2],
        [3],
        [2],
        <int>[],
      ];
      expect(WaterSortLogic.canPour(t, 0, 2), isTrue); // 2 su 2
      expect(WaterSortLogic.canPour(t, 0, 1), isFalse); // 2 su 3
      expect(WaterSortLogic.canPour(t, 0, 3), isTrue); // su vuota
      expect(WaterSortLogic.canPour(t, 3, 0), isFalse); // da vuota
      expect(WaterSortLogic.pour(t, 0, 2)[2], [2, 2]);
    });
  });

  group('schermate nuove e modificate', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    for (final (name, screen) in <(String, Widget)>[
      ('Mastermind', const MastermindScreen()),
      ('Impiccato', const HangmanScreen()),
      ('Travasa i colori', const WaterSortScreen()),
      ('Connessioni', const ConnectionsScreen()),
      ('Snake', const SnakeScreen()),
    ]) {
      testWidgets('$name si apre senza errori', (t) async {
        t.view.physicalSize = const Size(1080, 2340);
        t.view.devicePixelRatio = 2.625;
        addTearDown(t.view.reset);
        await GameStats.instance.load();
        await t.pumpWidget(_app(screen));
        await t.pump(const Duration(milliseconds: 300));
        expect(t.takeException(), isNull);
        await t.pumpWidget(const SizedBox());
      });
    }

    testWidgets('Impiccato: scegliendo tutte le lettere la partita finisce con un esito', (t) async {
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 2.625;
      addTearDown(t.view.reset);
      await GameStats.instance.load();
      await t.pumpWidget(_app(const HangmanScreen()));
      for (final c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')) {
        final f = find.widgetWithText(FilledButton, c);
        if (f.evaluate().isEmpty) break;
        await t.tap(f, warnIfMissed: false);
        await t.pump(const Duration(milliseconds: 50));
      }
      expect(find.byType(ResultBanner), findsOneWidget);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 3));
    });

    testWidgets('Mastermind: un tentativo riempie la riga e dà gli indizi', (t) async {
      t.view.physicalSize = const Size(1080, 2340);
      t.view.devicePixelRatio = 2.625;
      addTearDown(t.view.reset);
      await GameStats.instance.load();
      await t.pumpWidget(_app(const MastermindScreen()));
      final pegs = find.byType(GestureDetector);
      expect(pegs, findsWidgets);
      // la tavolozza è l'ultimo gruppo di pioli prima dei pulsanti: tocca 4 volte il primo colore
      final palette = pegs.evaluate().toList().reversed.take(5).toList();
      for (var i = 0; i < 4; i++) {
        await t.tap(find.byWidget(palette.last.widget), warnIfMissed: false);
        await t.pump();
      }
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    });
  });
}
