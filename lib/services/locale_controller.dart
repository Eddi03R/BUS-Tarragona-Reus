import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lingua dell'app scelta dall'utente (o null = segui il dispositivo),
/// persistita localmente.
class LocaleController extends ChangeNotifier {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  static const supportedLocales = [
    Locale('it'),
    Locale('ca'),
    Locale('es'),
    Locale('en'),
    Locale('de'),
  ];

  static const _prefKey = 'app_locale';

  Locale? _locale; // null = automatica (segue il dispositivo)
  Locale? get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && code.isNotEmpty) _locale = Locale(code);
    } catch (_) {
      // Storage non disponibile: si resta sulla lingua automatica.
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale? locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.remove(_prefKey);
      } else {
        await prefs.setString(_prefKey, locale.languageCode);
      }
    } catch (_) {
      // Persistenza best-effort.
    }
  }
}
