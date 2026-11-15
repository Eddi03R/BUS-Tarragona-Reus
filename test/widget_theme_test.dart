import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/services/theme_controller.dart';
import 'package:reus_tarragona_bus/services/widget_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('widget: colori dal tema dell app, chiaro e scuro', () async {
    final t = ThemeController.instance;
    await t.setSeedColor(ThemeController.defaultSeed);
    await t.setThemeMode(ThemeMode.system);
    var d = WidgetSync.themeData();
    expect(d['follow'], 'system');
    final light = d['light'] as Map<String, int>, dark = d['dark'] as Map<String, int>;
    expect(light.keys.toSet(), {'bg', 'text', 'muted', 'accent', 'btnBg', 'btnFg'});
    expect(light['bg'], isNot(dark['bg']));
    expect(light['accent'], isNot(dark['accent']));
    jsonDecode(jsonEncode(d)); // si salva come JSON per il widget

    // altro colore: cambia l'accento
    await t.setSeedColor(const Color(0xFF1565C0));
    final blue = WidgetSync.themeData()['light'] as Map<String, int>;
    expect(blue['accent'], isNot(light['accent']));

    // modalità scelta in app
    await t.setThemeMode(ThemeMode.dark);
    expect(WidgetSync.themeData()['follow'], 'dark');
  });

  test('widget: temi speciali hanno modalità fissa', () async {
    final t = ThemeController.instance;
    await t.setSeedColor(ThemeController.halloweenSeed);
    expect(WidgetSync.themeData()['follow'], 'dark');
    await t.setSeedColor(ThemeController.christmasSeed);
    expect(WidgetSync.themeData()['follow'], 'light');
    await t.setSeedColor(ThemeController.defaultSeed);
  });
}
