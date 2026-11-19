import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/games/race_screen.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final night in [false, true]) {
    testWidgets('corsa ${night ? 'notte' : 'giorno'}: parte, scorre e finisce senza errori', (t) async {
      SharedPreferences.setMockInitialValues({});
      t.view.physicalSize = const Size(800, 1500);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(
        locale: const Locale('it'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: RaceScreen(difficulty: Difficulty.hard, night: night),
      ));
      await t.tapAt(const Offset(200, 600)); // il primo tocco avvia la corsa
      // 3 vite: senza sterzare, prima o poi ci si scontra e la partita finisce
      for (var i = 0; i < 4000 && find.textContaining('Fine').evaluate().isEmpty; i++) {
        await t.pump(const Duration(milliseconds: 30));
      }
      await t.pump(const Duration(seconds: 1));
      final ex = t.takeException();
      expect(ex, isNull);
    });
  }
}

