import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/games/game_common.dart';
import 'package:reus_tarragona_bus/services/game_sound.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Il plugin audio non esiste nei test: lo si simula (risponde sempre "ok").
  for (final ch in const ['xyz.luan/audioplayers', 'xyz.luan/audioplayers.global']) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(MethodChannel(ch), (call) async => null);
  }

  test('ogni effetto ha il suo file WAV non vuoto', () {
    for (final s in Sfx.values) {
      final f = File('assets/sounds/${s.file}.wav');
      expect(f.existsSync(), isTrue, reason: s.file);
      expect(f.lengthSync(), greaterThan(1000), reason: s.file);
    }
  });

  test('i suoni sono spenti di base, si accendono e si ricordano', () async {
    SharedPreferences.setMockInitialValues({});
    final g = GameSound.instance;
    await g.load();
    expect(g.enabled, isFalse);
    g.play(Sfx.win); // spento: non fa nulla
    await g.setEnabled(true); // senza audio nei test: l'errore viene ignorato
    expect(g.enabled, isTrue);
    expect((await SharedPreferences.getInstance()).getBool('game_sounds_on'), isTrue);
    g.play(Sfx.explosion, delay: const Duration(milliseconds: 10));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await g.toggle();
    expect(g.enabled, isFalse);
  });

  testWidgets('il banner di esito compare anche con i suoni accesi', (tester) async {
    SharedPreferences.setMockInitialValues({'game_sounds_on': true});
    await GameSound.instance.load();
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: ResultBanner(text: 'Hai vinto', kind: ResultKind.win)),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hai vinto'), findsOneWidget);
    await GameSound.instance.setEnabled(false);
  });
}
