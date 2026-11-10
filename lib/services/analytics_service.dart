import 'dart:ui' show PlatformDispatcher;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';

/// Firebase: Crashlytics (solo Android) e Analytics (Android + web).
///
/// Analytics parte SOLO con il consenso:
///  - Android: dopo il consenso privacy (UMP) già richiesto per la pubblicità,
///    a meno che l'utente non l'abbia disattivato in Impostazioni;
///  - web: solo se l'utente accetta il banner o attiva l'interruttore.
/// Finché non c'è consenso su web non viene nemmeno inizializzato Analytics.
class AnalyticsService extends ChangeNotifier {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const _choiceKey = 'analytics_choice';

  bool _ready = false; // Firebase inizializzato
  bool? _choice; // scelta esplicita dell'utente (null = non ancora decisa)
  bool _androidConsent = false; // consenso UMP ricevuto
  bool _enabled = false;

  bool get ready => _ready;
  bool get enabled => _enabled;

  /// Il banner di consenso serve solo sul web e finché l'utente non sceglie.
  bool get needsWebPrompt => _ready && kIsWeb && _choice == null;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Solo per prove locali senza rete: `--dart-define=SKIP_FIREBASE=true`.
  static const _skipFirebase = bool.fromEnvironment('SKIP_FIREBASE');

  Future<void> init() async {
    if (_skipFirebase) return;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _ready = true;
    } catch (e) {
      debugPrint('Firebase init failed: $e');
      return;
    }
    if (_isAndroid) {
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      _choice = prefs.getBool(_choiceKey);
    } catch (_) {}
    await _apply();
  }

  /// Chiamato quando il consenso privacy (UMP) permette di procedere (Android).
  void onAndroidConsent() {
    _androidConsent = true;
    _apply();
  }

  Future<void> setChoice(bool value) async {
    _choice = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_choiceKey, value);
    } catch (_) {}
    await _apply();
  }

  Future<void> _apply() async {
    final shouldEnable = _ready && (_choice ?? (_isAndroid && _androidConsent));
    if (shouldEnable != _enabled) {
      _enabled = shouldEnable;
      // Su web non si tocca Analytics prima del consenso (si inizializza lazy).
      if (shouldEnable || !kIsWeb) {
        try {
          await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(shouldEnable);
        } catch (e) {
          debugPrint('Analytics toggle failed: $e');
        }
      }
    }
    notifyListeners();
  }

  /// Registra un evento, solo se Analytics è attivo.
  void log(String name, [Map<String, Object>? params]) {
    if (!_enabled) return;
    FirebaseAnalytics.instance
        .logEvent(name: name, parameters: params)
        .catchError((_) {});
  }
}
