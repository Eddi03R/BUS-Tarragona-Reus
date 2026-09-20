import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Colore del tema scelto dall'utente, persistito localmente.
class ThemeController extends ChangeNotifier {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  static const Color defaultSeed = Color(0xFF0F6E5C);
  static const _prefKey = 'app_seed_color';

  Color _seedColor = defaultSeed;
  Color get seedColor => _seedColor;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getInt(_prefKey);
      if (value != null) _seedColor = Color(value);
    } catch (_) {
      // Storage non disponibile: si resta sul colore di default.
    }
    notifyListeners();
  }

  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, color.value);
    } catch (_) {
      // Persistenza best-effort.
    }
  }
}
