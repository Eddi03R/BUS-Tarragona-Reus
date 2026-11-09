import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/main.dart';
import 'package:reus_tarragona_bus/services/theme_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pompa i frame finché il testo compare (gli asset si caricano in modo asincrono).
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 60; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Non compare: $finder');
}

/// Lascia finire le animazioni di navigazione.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // iOS: pubblicità/acquisti restano spenti (sono solo Android).
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    SharedPreferences.setMockInitialValues({'location_enabled': false, 'app_locale': 'en'});
  });
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  testWidgets('avvio: home, Nightlife, Impostazioni e pagina Aspetto', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text('ErasBus Tarragona'));
    expect(find.text('Daylife'), findsWidgets);

    // Nightlife
    await tester.tap(find.byIcon(Icons.nightlight_outlined));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Nightlife'), findsWidgets);

    // Impostazioni: menu corto con le sezioni
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await pumpUntilFound(tester, find.text('Appearance'));
    await settle(tester);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);

    // Pagina Aspetto
    await tester.tap(find.text('Appearance'));
    await pumpUntilFound(tester, find.text('Light'));
    await settle(tester);
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
  });

  testWidgets('tema Natale: modalità bloccata su Chiaro', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'location_enabled': false,
      'app_locale': 'en',
      'app_seed_color': ThemeController.christmasSeed.toARGB32(),
    });

    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text('ErasBus Tarragona'));
    expect(ThemeController.instance.isChristmas, isTrue);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await pumpUntilFound(tester, find.text('Appearance'));
    await settle(tester);
    await tester.tap(find.text('Appearance'));
    await pumpUntilFound(tester, find.text('Light'));
    await settle(tester);
    final seg = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>));
    expect(seg.selected, {ThemeMode.light});
    expect(seg.onSelectionChanged, isNull, reason: 'nessuna altra modalità scegliibile');
  });
}
