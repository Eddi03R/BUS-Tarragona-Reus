/// Configurazione pubblicità e abbonamento (solo Android).
///
/// ID reali di AdMob. Per provare l'app senza rischiare l'account, aggiungi il
/// telefono come dispositivo di test in AdMob (Impostazioni → Dispositivi di test).
class AdsConfig {
  AdsConfig._();

  // --- AdMob (ID reali) ---
  static const String bannerUnitId = 'ca-app-pub-3708488192021794/7723824102';
  static const String rewardedUnitId = 'ca-app-pub-3708488192021794/9003302094';

  // --- Abbonamento "senza pubblicità" (Play Console → Monetizza → Abbonamenti) ---
  static const String removeAdsProductId = 'remove_ads';

  // --- Link di supporto per il sito (Ko-fi / Buy Me a Coffee ...). Vuoto = nascosto ---
  static const String supportUrl = '';
}
