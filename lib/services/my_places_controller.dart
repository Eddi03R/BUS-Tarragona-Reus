import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// "I miei posti": fermata di Casa e fermata abituale (di solito vicino
/// all'università). Alimentano i pulsanti "Torna a casa" e "Alla fermata abituale".
class MyPlacesController extends ChangeNotifier {
  MyPlacesController._();
  static final MyPlacesController instance = MyPlacesController._();

  static const _homeKey = 'my_home_stop';
  static const _usualKey = 'my_usual_stop';

  String? _homeStopId;
  String? _usualStopId;

  String? get homeStopId => _homeStopId;
  String? get usualStopId => _usualStopId;

  /// Entrambi impostati e diversi: solo allora i pulsanti hanno senso.
  bool get configured =>
      _homeStopId != null && _usualStopId != null && _homeStopId != _usualStopId;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _homeStopId = prefs.getString(_homeKey);
      _usualStopId = prefs.getString(_usualKey);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setHome(String? stopId) async {
    _homeStopId = stopId;
    notifyListeners();
    await _save(_homeKey, stopId);
  }

  Future<void> setUsual(String? stopId) async {
    _usualStopId = stopId;
    notifyListeners();
    await _save(_usualKey, stopId);
  }

  Future<void> _save(String key, String? value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value == null) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, value);
      }
    } catch (_) {}
  }
}
