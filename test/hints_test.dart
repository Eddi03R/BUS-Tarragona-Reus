import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/battleship_screen.dart';
import 'package:reus_tarragona_bus/games/briscola_screen.dart';
import 'package:reus_tarragona_bus/games/game2048_screen.dart';
import 'package:reus_tarragona_bus/games/checkers_screen.dart';
import 'package:reus_tarragona_bus/games/connections_screen.dart';
import 'package:reus_tarragona_bus/games/flow_screen.dart';
import 'package:reus_tarragona_bus/games/hangman_screen.dart';
import 'package:reus_tarragona_bus/games/mastermind_screen.dart';
import 'package:reus_tarragona_bus/games/minesweeper_screen.dart';
import 'package:reus_tarragona_bus/games/quiz_screen.dart';
import 'package:reus_tarragona_bus/games/rewarded_offer.dart';
import 'package:reus_tarragona_bus/games/slide_screen.dart';
import 'package:reus_tarragona_bus/games/sudoku_screen.dart';
import 'package:reus_tarragona_bus/games/tictactoe_screen.dart';
import 'package:reus_tarragona_bus/games/watersort_screen.dart';
import 'package:reus_tarragona_bus/games/wordle_screen.dart';
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

/// Aiuti con pubblicità dei giochi: dove il pulsante c'è subito, toccarlo e
/// confermare non deve dare errori (nei test non ci sono pubblicità: è gratis).
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // su Linux non ci sono pubblicità: l'aiuto è gratis e il pulsante c'è sempre
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  });
  final screens = <String, Widget Function()>{
    'tris': () => const TicTacToeScreen(),
    'dama': () => const CheckersScreen(),
    'briscola': () => const BriscolaScreen(),
    'connessioni': () => const ConnectionsScreen(),
    'collega i punti': () => const FlowScreen(),
    'impiccato': () => const HangmanScreen(),
    'mastermind': () => const MastermindScreen(),
    'campo minato': () => const MinesweeperScreen(),
    'quiz': () => const QuizScreen(),
    'slide': () => const SlideScreen(),
    'sudoku': () => const SudokuScreen(),
    'travasa': () => const WaterSortScreen(),
    'parola del giorno': () => const WordleScreen(daily: false),
  };
  for (final e in screens.entries) {
    testWidgets('aiuto: ${e.key}', (t) async {
      await t.binding.setSurfaceSize(const Size(420, 1400));
      await t.pumpWidget(_app(e.value()));
      // la Briscola può partire con la mossa del telefono (circa 1 secondo)
      for (var i = 0; i < 4; i++) {
        await t.pump(const Duration(milliseconds: 500));
      }
      final btn = find.byType(HelpButton);
      expect(btn, findsOneWidget, reason: 'il pulsante di aiuto deve esserci');
      await t.ensureVisible(btn);
      await t.tap(btn);
      await t.pump();
      await t.pump(const Duration(milliseconds: 300));
      await t.tap(find.text('Continua')); // conferma (gratis, senza pubblicità)
      await t.pump();
      await t.pump(const Duration(milliseconds: 400));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox()); // ferma timer e animazioni
      await t.binding.setSurfaceSize(null);
      debugDefaultTargetPlatformOverride = null; // va rimesso a posto prima della fine del test
    });
  }

  testWidgets('aiuto: battaglia navale (dopo aver piazzato le navi)', (t) async {
    await t.binding.setSurfaceSize(const Size(420, 1600));
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await t.pumpWidget(_app(const BattleshipScreen()));
    await t.tap(find.text('Casuale'));
    await t.pump();
    await t.ensureVisible(find.text('Inizia'));
    await t.tap(find.text('Inizia'));
    await t.pump(const Duration(milliseconds: 400));
    final btn = find.byType(HelpButton);
    expect(btn, findsOneWidget);
    await t.ensureVisible(btn);
    await t.tap(btn);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Continua'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byIcon(Icons.lightbulb_rounded), findsOneWidget); // la nave nemica evidenziata
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.binding.setSurfaceSize(null);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('aiuto: 2048 annulla l\'ultima mossa', (t) async {
    await t.binding.setSurfaceSize(const Size(420, 1400));
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    await t.pumpWidget(_app(const Game2048Screen()));
    await t.pump(const Duration(milliseconds: 400));
    final board = find.byType(GestureDetector).first;
    for (final d in const [Offset(-120, 0), Offset(120, 0), Offset(0, -120), Offset(0, 120)]) {
      if (find.byType(HelpButton).evaluate().isNotEmpty) break;
      await t.drag(board, d);
      await t.pump(const Duration(milliseconds: 500));
    }
    final btn = find.byType(HelpButton);
    expect(btn, findsOneWidget, reason: 'dopo una mossa si può annullare');
    await t.ensureVisible(btn);
    await t.tap(btn);
    await t.pump(const Duration(milliseconds: 300));
    await t.tap(find.text('Continua'));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.byType(HelpButton), findsNothing); // un solo annulla
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
    await t.binding.setSurfaceSize(null);
    debugDefaultTargetPlatformOverride = null;
  });
}
