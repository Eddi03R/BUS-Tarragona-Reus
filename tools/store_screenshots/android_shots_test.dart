// Genera le schermate grezze dell'app per il video "Finally on Android" (telefono Android: 1080x2400, 411x914 dp).
// Uso (da una cartella con Flutter):  flutter test tools/store_screenshots/android_shots_test.dart --update-goldens
// Scrive i PNG in /tmp/shots-android; poi vanno convertiti in tools/brag-video-android/assets/shots (vedi il README della cartella).
// Serve il font Roboto/MaterialIcons dell'SDK (bin/cache/artifacts/material_fonts): variabile FONT_DIR.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/briscola_screen.dart';
import 'package:reus_tarragona_bus/games/race_screen.dart';
import 'package:reus_tarragona_bus/games/watersort_screen.dart';
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
    await expectLater(find.byType(MaterialApp), matchesGoldenFile('/tmp/shots-android/$name.png'));
  }

  testWidgets('schermate android', (t) async {
    SharedPreferences.setMockInitialValues({
      'location_enabled': false,
      'app_locale': 'en',
      'tutorial_seen': true,
      'whatsnew_seen_version': WhatsNew.token,
      'analytics_choice': false,
    });
    // fuchsia = nessuna pubblicità né plugin nativi nei test; font Roboto come su Android
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
    await t.runAsync(_loadFonts);
    t.view.physicalSize = const Size(1080, 2400);
    t.view.devicePixelRatio = 2.625;
    t.view.padding = const FakeViewPadding(top: 66, bottom: 40); // barra di stato e gesto "home" (~25 / 15 dp)
    t.view.viewPadding = const FakeViewPadding(top: 66, bottom: 40);
    addTearDown(() {
      debugDefaultTargetPlatformOverride = null;
      t.view.reset();
    });

    await t.pumpWidget(const BusApp());
    await _until(t, find.text('ErasBus Tarragona'));

    // 1) Home Daylife: destinazione, partenza, risultati, dettaglio corsa
    await t.tap(find.textContaining('Where do you want'));
    await _settle(t);
    await t.pump(const Duration(milliseconds: 400));
    await t.tap(find.text('Campus Sescelades (URV)'));
    await _settle(t, 900);
    await t.tap(find.text('Change'));
    await _settle(t, 800);
    await t.tap(find.text('Pl. de les Oques (Reus)').first);
    await _settle(t, 900);
    await shot(t, '01_home_ready');
    await t.tap(find.text('Go'));
    await _settle(t, 1200);
    await shot(t, '02_results');
    await t.tap(find.text('MONBUS').first, warnIfMissed: false);
    await _settle(t, 1200);
    await shot(t, '03_trip');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    // 2) Nightlife: scelta del locale
    await t.tap(find.byIcon(Icons.nightlight_outlined));
    await _settle(t, 900);
    await t.tap(find.textContaining('Where do you want'));
    await _settle(t, 900);
    await shot(t, '04_night_picker');
    await t.tap(find.text('SoldeNit').first, warnIfMissed: false);
    await _settle(t, 900);
    await shot(t, '05_night_home');
    await t.tap(find.byIcon(Icons.wb_sunny_outlined));
    await _settle(t, 700);

    // 3) giochi: elenco, Briscola, Corsa del minibus (notte), Travasa i colori
    await t.tap(find.text('Beat the wait'));
    await _settle(t, 1200);
    await shot(t, '06_arcade');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    WidgetSync.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const BriscolaScreen()));
    await _settle(t, 2500);
    await t.pump();
    await t.pump(const Duration(milliseconds: 600));
    await t.tap(find.byType(AnimatedPositioned).first, warnIfMissed: false);
    await _settle(t, 3500);
    await shot(t, '07_briscola');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    WidgetSync.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const RaceScreen(night: true)));
    await _settle(t, 800);
    await t.tapAt(const Offset(220, 620));
    await _settle(t, 4500);
    await shot(t, '08_race_night');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    WidgetSync.navigatorKey.currentState!.push(MaterialPageRoute(builder: (_) => const WaterSortScreen()));
    await _settle(t, 1500);
    await shot(t, '09_watersort');
    WidgetSync.navigatorKey.currentState!.pop();
    await _settle(t, 600);

    // 4) temi: scuro viola, poi i temi speciali (Halloween, Natale, GTA 6)
    for (final (name, color, mode) in [
      ('10_theme_dark', const Color(0xFF7E57C2), ThemeMode.dark),
      ('11_theme_halloween', ThemeController.halloweenSeed, ThemeMode.dark),
      ('12_theme_christmas', ThemeController.christmasSeed, ThemeMode.light),
      ('13_theme_gta6', FestiveThemes.gta6Seed, ThemeMode.dark),
    ]) {
      await ThemeController.instance.setSeedColor(color);
      await ThemeController.instance.setThemeMode(mode);
      await _settle(t, 1500);
      await shot(t, name);
    }
    debugDefaultTargetPlatformOverride = null; // va rimesso a posto prima della fine del test
  });
}
