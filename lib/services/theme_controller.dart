import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Colore e modalità (chiaro/scuro/sistema) del tema, persistiti localmente.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const Color defaultSeed = Color(0xFF0F6E5C);
  static const _colorPrefKey = 'app_seed_color';
  static const _modePrefKey = 'app_theme_mode';

  Color _seedColor = defaultSeed;
  Color get seedColor => _seedColor;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorValue = prefs.getInt(_colorPrefKey);
      if (colorValue != null) _seedColor = Color(colorValue);
      final modeValue = prefs.getString(_modePrefKey);
      if (modeValue != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == modeValue,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {
      // Storage non disponibile: si resta sui valori di default.
    }
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_colorPrefKey, color.value);
    } catch (_) {
      // Persistenza best-effort.
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_modePrefKey, mode.name);
    } catch (_) {
      // Persistenza best-effort.
    }
  }
}
