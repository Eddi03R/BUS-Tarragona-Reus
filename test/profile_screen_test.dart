import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:reus_tarragona_bus/screens/player_profile_screen.dart';
import 'package:reus_tarragona_bus/services/leaderboard.dart';
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
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('profilo senza nome: scelta del nome', (t) async {
    Leaderboard.instance.name = null;
    await t.pumpWidget(_app(const PlayerProfileScreen()));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Scegli un nome utente'), findsOneWidget);
    expect(t.takeException(), isNull);
  });

  testWidgets('profilo con nome: intestazione, numeri e barre senza errori di layout', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 900)); // telefono stretto
    Leaderboard.instance.name = 'Marta_92';
    await GameStats.instance.setValue('plays_ticTacToe', 5);
    await GameStats.instance.setValue('wins_ticTacToe', 3);
    await GameStats.instance.setValue('losses_ticTacToe', 2);
    await t.pumpWidget(_app(const PlayerProfileScreen()));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Marta_92'), findsOneWidget);
    expect(find.text('Livello 1'), findsNothing); // il livello ha la stella davanti
    expect(find.textContaining('Livello'), findsOneWidget);
    expect(find.text('3 · 2'), findsOneWidget); // vinte · perse del Tris
    // le barre verde/rossa si vedono davvero (alte 10, larghe in proporzione 3:2)
    final won = t.getSize(find.byKey(const ValueKey('bar-won')));
    final lost = t.getSize(find.byKey(const ValueKey('bar-lost')));
    expect(won.height, 10);
    expect(won.width / lost.width, closeTo(1.5, 0.01));
    expect(find.byTooltip('Cambia nome'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.binding.setSurfaceSize(null);
    Leaderboard.instance.name = null;
  });

  testWidgets('classifica della settimana: elenco con avatar e podio della sfida', (t) async {
    await t.binding.setSurfaceSize(const Size(360, 1800));
    Leaderboard.instance.name = 'Marta_92';
    final (game, _) = Leaderboard.challengeFor(Leaderboard.weekOf(DateTime.now()));
    final rows = [
      WeekRow('a', 'pietro_06', 3, 8, {'busJam': 39, 'mastermind': 1}),
      WeekRow('b', 'veraaha', 1, 5, {'waterSort': 1}),
      WeekRow('c', 'Luca_T', 2, 3, const {}),
    ];
    await t.pumpWidget(_app(PlayerProfileScreen(boards: Future.value((rows, null)))));
    await t.pump(const Duration(milliseconds: 300));
    expect(find.text('Più giochi diversi'), findsOneWidget);
    expect(find.text('39'), findsOneWidget); // vittorie a Bus e minibus
    expect(find.text('pietro_06'), findsWidgets);
    expect(find.text('veraaha'), findsWidgets);
    expect(find.textContaining('Sfida'), findsWidgets);
    expect(game, isNotNull);
    expect(t.takeException(), isNull);
    await t.binding.setSurfaceSize(null);
    Leaderboard.instance.name = null;
  });
}
