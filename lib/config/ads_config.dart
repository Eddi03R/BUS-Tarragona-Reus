import 'package:flutter/foundation.dart';

/// Configurazione pubblicità e abbonamento (Android e iOS).
///
/// ID reali di AdMob. Per provare l'app senza rischiare l'account, aggiungi il
/// telefono come dispositivo di test in AdMob (Impostazioni → Dispositivi di test).
class AdsConfig {
  AdsConfig._();

  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  // --- AdMob Android (ID reali) ---
  static const String _androidBanner = 'ca-app-pub-3708488192021794/7723824102';
  static const String _androidRewarded = 'ca-app-pub-3708488192021794/9003302094';

  // --- AdMob iOS: app ca-app-pub-3708488192021794~5959288041 ---
  static const String _iosBanner = 'ca-app-pub-3708488192021794/7050822523';
  static const String _iosRewarded = 'ca-app-pub-3708488192021794/9780927644';

  static String get bannerUnitId => _ios ? _iosBanner : _androidBanner;
  static String get rewardedUnitId => _ios ? _iosRewarded : _androidRewarded;

  // --- Abbonamento "senza pubblicità" ---
  // Android (Play Console): un solo prodotto con due piani base.
  static const String removeAdsProductId = 'remove_ads';
  // iOS (App Store Connect): due prodotti nello stesso gruppo di abbonamenti.
  static const String removeAdsMonthlyIos = 'remove_ads_monthly';
  static const String removeAdsYearlyIos = 'remove_ads_yearly';

  /// ID dei prodotti da interrogare sullo store della piattaforma corrente.
  static Set<String> get subscriptionIds => _ios
      ? {removeAdsMonthlyIos, removeAdsYearlyIos}
      : {removeAdsProductId};

  // --- Link di supporto per il sito (Ko-fi / Buy Me a Coffee ...). Vuoto = nascosto ---
  static const String supportUrl = '';
}
