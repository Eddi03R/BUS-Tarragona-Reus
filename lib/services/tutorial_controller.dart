import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tutorial iniziale: si vede solo la prima volta; da Impostazioni si può
/// rivedere (la Home ascolta [requests] e lo riapre).
class TutorialController extends ChangeNotifier {
  TutorialController._();
  static final TutorialController instance = TutorialController._();

  static const _seenKey = 'tutorial_seen';

  /// Cresce a ogni richiesta di rivedere il tutorial.
  int requests = 0;

  /// True se non è mai stato mostrato su questo dispositivo.
  Future<bool> isFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !(prefs.getBool(_seenKey) ?? false);
    } catch (_) {
      return false; // storage non disponibile: meglio non ripeterlo a ogni avvio
    }
  }

  Future<void> markSeen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenKey, true);
    } catch (_) {}
  }

  /// Chiede alla Home di (ri)mostrare il tutorial.
  void requestShow() {
    requests++;
    notifyListeners();
  }
}
