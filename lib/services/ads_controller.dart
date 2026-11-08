import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/ads_config.dart';
import 'ads/ads_backend.dart';
import 'analytics_service.dart';

/// Stato di pubblicità e abbonamento "senza pubblicità".
/// Su web e piattaforme non supportate resta tutto spento.
class AdsController extends ChangeNotifier implements AdsHost {
  AdsController._();
  static final AdsController instance = AdsController._();

  static const _premiumKey = 'ads_premium';
  static const _testModeKey = 'ads_test_mode';

  final AdsBackend _backend = AdsBackend.create();

  bool _premium = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  List<SubProduct> _products = const [];
  final Map<String, String> _diagnostics = {};

  bool get supported => _backend.supported;
  bool get premium => _premium;
  List<SubProduct> get products => _products;
  bool get privacyOptionsRequired => _privacyOptionsRequired;
  Map<String, String> get diagnostics => Map.unmodifiable(_diagnostics);
  bool get rewardedReady => _backend.rewardedReady;

  /// Banner visibile solo se: piattaforma supportata, non abbonato, consenso ok.
  bool get showAds => supported && !_premium && _canRequestAds;

  Widget banner() => _backend.banner();

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _premium = prefs.getBool(_premiumKey) ?? false;
      AdsConfig.testMode = prefs.getBool(_testModeKey) ?? false;
    } catch (_) {}
    notifyListeners();
    if (!supported) return;
    try {
      await _backend.init(this);
    } catch (e) {
      debugPrint('Ads init failed: $e');
    }
  }

  /// Attiva/disattiva la modalità test (ID di prova Google). Serve il riavvio.
  Future<bool> toggleTestMode() async {
    final value = !AdsConfig.testMode;
    AdsConfig.testMode = value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_testModeKey, value);
    } catch (_) {}
    notifyListeners();
    return value;
  }

  Future<bool> watchRewardedAd() => _backend.showRewarded();
  Future<void> buy(SubProduct p) => _backend.buy(p);
  Future<void> restore() => _backend.restore();
  Future<void> showPrivacyOptions() => _backend.showPrivacyOptions();

  // ---- AdsHost ----
  @override
  void setCanRequestAds(bool value) {
    _canRequestAds = value;
    if (value) AnalyticsService.instance.onAndroidConsent();
    notifyListeners();
  }

  @override
  void setPremium(bool value) {
    if (_premium == value) return;
    _premium = value;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_premiumKey, value))
        .catchError((_) => false);
  }

  @override
  void setProducts(List<SubProduct> products) {
    _products = products;
    notifyListeners();
  }

  @override
  void setPrivacyOptionsRequired(bool value) {
    _privacyOptionsRequired = value;
    notifyListeners();
  }

  @override
  void notifyChanged() => notifyListeners();

  @override
  void setDiagnostic(String key, String value) {
    _diagnostics[key] = value;
    notifyListeners();
  }
}
