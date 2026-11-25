// Genera le schermate grezze dell'app per le immagini dello store (iPhone 6,9": 1320x2868).
// Uso (da una cartella con Flutter):  flutter test tools/store_screenshots/shots_test.dart --update-goldens
// Scrive i PNG in /tmp/shots; poi python3 tools/store_screenshots/compose.py li impagina con i titoli in inglese.
// Serve il font Roboto/MaterialIcons dell'SDK (bin/cache/artifacts/material_fonts): variabile FONT_DIR.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/briscola_screen.dart';
import 'package:reus_tarragona_bus/games/race_screen.dart';
import 'package:reus_tarragona_bus/main.dart';
import 'package:reus_tarragona_bus/services/theme_controller.dart';
import 'package:reus_tarragona_bus/services/whats_new.dart';
import 'package:reus_tarragona_bus/services/widget_sync.dart';
import 'package:reus_tarragona_bus/theme/festive_themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _fontDir = Platform.environment['FONT_DIR'] ?? '/tmp/fl/flutter/bin/cache/artifacts/material_fonts';

Future<void> _loadFonts() async {
  Future<ByteData> b(String f) async => ByteData.sublistView(await File('$_fontDir/$f').readAsBytes());
  // Roboto ha solo i pesi 300/400/500/700/900: i pesi 600 e 800 usati dall'app (copie di Bold e Black
  // con il peso cambiato, vedi il README della cartella) altrimenti nei test escono come blocchi.
  final extra = Platform.environment['FONT_EXTRA_DIR'] ?? '/tmp/fonts_extra';
  final r = FontLoader('Roboto');
  for (final f in ['Roboto-Regular.ttf', 'Roboto-Medium.ttf', 'Roboto-Bold.ttf', 'Roboto-Black.ttf', 'Roboto-Light.ttf']) {
    r.addFont(b(f));
  }
  for (final f in ['Roboto-W600.ttf', 'Roboto-W800.ttf']) {
    final file = File('$extra/$f');
    if (file.existsSync()) r.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await r.load();
  final i = FontLoader('MaterialIcons')..addFont(b('MaterialIcons-Regular.otf'));
  await i.load();
}

Future<void> _until(WidgetTester t, Finder f) async {
  for (var i = 0; i < 80; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await t.pump(const Duration(milliseconds: 60));
    if (f.evaluate().isNotEmpty) return;
  }
  fail('Non compare: $f');
}

Future<void> _settle(WidgetTester t, [int ms = 700]) async {
  for (var i = 0; i < ms ~/ 100; i++) {
    await t.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester t, String name) async {
    await _settle(t, 400);
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('/tmp/shots/$name.png'));
  }

  testWidgets('schermate store', (t) async {
    SharedPreferences.setMockInitialValues({
      'location_enabled': false,
      'app_locale': 'en',
      'tutorial_seen': true,
      'whatsnew_seen_version': WhatsNew.version,
      'analytics_choice': false,
    });
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    await t.runAsync(_loadFonts);
    t.view.physicalSize = const Size(1320, 2868);
    t.view.devicePixelRatio = 3;
    t.view.padding = const FakeViewPadding(top: 186, bottom: 102); // 62 / 34 logici
    t.view.viewPadding = const FakeViewPadding(top: 186, bottom: 102);
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      t.view.reset();
    });

    await t.pumpWidget(const BusApp());
    await _until(t, find.text('ErasBus Tarragona'));

    // 1) Home Daylife con partenza e arrivo
    await t.tap(find.textContaining('Where do you want'));
    await _settle(t);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Campus Sescelades (URV)'));
    await _settle(t, 900);
    await shot(t, '01_home_dest');

    // 2) partenza: Pl. de les Oques
    await t.tap(find.text('Change'));
    await _settle(t, 800);
    await t.tap(find.text('Pl. de les Oques (Reus)').first);
    await _settle(t, 900);
    await shot(t, '02_home_ready');

    // 3) risultati
    await t.tap(find.text('Go'));
    await _settle(t, 1200);
    await shot(t, '03_results');

    // 4) dettaglio corsa
    await t.tap(find.text('MONBUS').first, warnIfMissed: false);
    await _settle(t, 1200);
    await shot(t, '04_trip');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    // 5) Nightlife con un locale
    await t.tap(find.byIcon(Icons.nightlight_outlined));
    await _settle(t, 900);
    await t.tap(find.textContaining('Where do you want'));
    await _settle(t, 900);
    await shot(t, '05_night_picker');
    await t.tap(find.text('SoldeNit').first, warnIfMissed: false);
    await _settle(t, 900);
    await shot(t, '06_night_home');
    await t.tap(find.byIcon(Icons.wb_sunny_outlined));
    await _settle(t, 700);

    // 6) giochi
    await t.tap(find.text('Beat the wait'));
    await _settle(t, 1200);
    await shot(t, '07_arcade');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    // 7) Briscola in partita
    WidgetSync.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const BriscolaScreen()));
    await _settle(t, 2500);
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byType(AnimatedPositioned).first, warnIfMissed: false);
    await _settle(t, 3500);
    await shot(t, '08_briscola');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    // 8) Corsa del minibus, giorno e notte
    for (final night in [false, true]) {
      WidgetSync.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => RaceScreen(night: night)));
      await _settle(t, 800);
      await t.tapAt(const Offset(220, 620));
      await _settle(t, 4500);
      await shot(t, night ? '10_race_night' : '09_race_day');
      WidgetSync.navigatorKey.currentState!.pop();
      await _settle(t, 600);
    }

    // 9) tema scuro viola sulla Home e pagina Aspetto
    await ThemeController.instance.setSeedColor(const Color(0xFF7E57C2));
    await ThemeController.instance.setThemeMode(ThemeMode.dark);
    await _settle(t, 1200);
    await shot(t, '11_home_dark');
    await t.tap(find.byIcon(Icons.settings_rounded));
    await _settle(t, 900);
    await t.tap(find.text('Appearance'));
    await _settle(t, 900);
    await shot(t, '12_appearance');
  });
}
