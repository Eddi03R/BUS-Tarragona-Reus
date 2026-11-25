import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/main.dart';
import 'package:reus_tarragona_bus/services/whats_new.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> pumpUntilFound(WidgetTester tester, Finder finder, {int tries = 80}) async {
  for (var i = 0; i < tries; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Non compare: $finder');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la versione si legge da kAppVersion senza il numero di build', () {
    expect(WhatsNew.version, matches(RegExp(r'^\d+\.\d+\.\d+$')));
  });

  test('ogni voce ha le 5 lingue e gli stessi punti in tutte', () {
    for (final e in WhatsNew.entries.entries) {
      expect(e.value.keys.toSet(), {'it', 'en', 'es', 'ca', 'de'}, reason: e.key);
      final n = e.value['it']!.length;
      for (final l in e.value.values) {
        expect(l.length, n, reason: e.key);
        expect(l.every((s) => s.trim().isNotEmpty), isTrue);
      }
    }
  });

  test('versione senza voce: nessun testo; lingua sconosciuta: inglese', () {
    expect(WhatsNew.linesFor('0.0.1', 'it'), isNull);
    final v = WhatsNew.entries.keys.first;
    expect(WhatsNew.linesFor(v, 'xx'), WhatsNew.entries[v]!['en']);
  });

  void iosTest(String name, Future<void> Function(WidgetTester tester) body) {
    testWidgets(name, (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
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

  // La voce della versione corrente: se manca (versione senza novità) i test sull'avviso non servono.
  final lines = WhatsNew.linesFor(WhatsNew.version, 'en');

  iosTest('utente che aggiorna: vede le novità una volta sola', (tester) async {
    if (lines == null) return;
    SharedPreferences.setMockInitialValues({'location_enabled': false, 'app_locale': 'en', 'tutorial_seen': true});
    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text("What's new in version ${WhatsNew.version}"), tries: 120);
    expect(find.text(lines.first), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 400));
    expect((await SharedPreferences.getInstance()).getString('whatsnew_seen_version'), WhatsNew.version);
    // riapertura: non si ripete
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(const BusApp());
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text("What's new in version ${WhatsNew.version}"), findsNothing);
  });

  iosTest('nuova installazione: niente novità (c\'è il tutorial) e la versione si ricorda', (tester) async {
    SharedPreferences.setMockInitialValues({'location_enabled': false, 'app_locale': 'en'});
    await tester.pumpWidget(const BusApp());
    await pumpUntilFound(tester, find.text('Find your ride'), tries: 120);
    expect(find.text("What's new in version ${WhatsNew.version}"), findsNothing);
    expect((await SharedPreferences.getInstance()).getString('whatsnew_seen_version'), WhatsNew.version);
  });

  iosTest('già visto per questa versione: non compare', (tester) async {
    SharedPreferences.setMockInitialValues({
      'location_enabled': false,
      'app_locale': 'en',
      'tutorial_seen': true,
      'whatsnew_seen_version': WhatsNew.version,
    });
    await tester.pumpWidget(const BusApp());
    for (var i = 0; i < 40; i++) {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.text("What's new in version ${WhatsNew.version}"), findsNothing);
  });
}
