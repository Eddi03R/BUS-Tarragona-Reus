import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationController extends ChangeNotifier {
  static final instance = LocationController._();
  LocationController._();

  static const _key = 'location_enabled';
  bool _enabled = true;

  bool get isEnabled => _enabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<bool> setEnabled(bool value) async {
    if (value) {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return false;
      }
    }
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
    notifyListeners();
    return true;
  }
}
