import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {int tries = 80}) async {
  for (var i = 0; i < tries; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Non compare: $finder');
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void iosTest(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.75;
      addTearDown(tester.view.reset);
      try {
        await body(tester);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  }

  iosTest('prima apertura: compare, 4 pagine, si può saltare e non si ripete', (tester) async {
    SharedPreferences.setMockInitialValues({'location_enabled': false, 'app_locale': 'en'});
    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text('Find your ride'), tries: 120);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    for (final n in [2, 3, 4]) {
      await tester.tap(find.text('Next'));
      await pumpUntilFound(tester, find.text('$n/4'));
    }
    expect(find.text('Write to us'), findsOneWidget);
    // ultima pagina: niente "Salta", c'è "Done"
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('Skip'), findsNothing);
    await tester.tap(find.text('Done'));
    await settle(tester);
    expect((await SharedPreferences.getInstance()).getBool('tutorial_seen'), isTrue);
    expect(find.text('Write to us'), findsNothing);
  });

  iosTest('Salta chiude subito; già visto: non riparte; da Impostazioni si rivede', (tester) async {
    SharedPreferences.setMockInitialValues({'location_enabled': false, 'app_locale': 'en'});
    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text('Find your ride'), tries: 120);
    await tester.tap(find.text('Skip'));
    await settle(tester);
    expect(find.text('Find your ride'), findsNothing);

    // Impostazioni → "Replay the tutorial" (sotto "Game sounds")
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await pumpUntilFound(tester, find.text('Appearance'));
    await settle(tester);
    expect(find.text('Game sounds'), findsOneWidget);
    expect(find.text('Replay the tutorial'), findsOneWidget);
    await tester.tap(find.text('Replay the tutorial'));
    await pumpUntilFound(tester, find.text('Find your ride'), tries: 120);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Game sounds'), findsNothing, reason: 'torna alla Home');
    await tester.tap(find.text('Skip'));
    await settle(tester);
  });
}
