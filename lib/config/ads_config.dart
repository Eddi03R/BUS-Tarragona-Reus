/// Configurazione pubblicità e abbonamento (solo Android).
///
/// ID reali di AdMob. Per provare l'app senza rischiare l'account, aggiungi il
/// telefono come dispositivo di test in AdMob (Impostazioni → Dispositivi di test).
class AdsConfig {
  AdsConfig._();

  // --- AdMob (ID reali) ---
  static const String _bannerReal = 'ca-app-pub-3708488192021794/7723824102';
  static const String _rewardedReal = 'ca-app-pub-3708488192021794/9003302094';
  // ID di prova ufficiali di Google: annunci finti, sempre disponibili.
  static const String _bannerTest = 'ca-app-pub-3940256099942544/6300978111';
  static const String _rewardedTest = 'ca-app-pub-3940256099942544/5224354917';

  /// Modalità test: si attiva toccando 7 volte la versione in Impostazioni
  /// (serve a provare banner e video senza aspettare che AdMob serva annunci reali).
  static bool testMode = false;

  static String get bannerUnitId => testMode ? _bannerTest : _bannerReal;
  static String get rewardedUnitId => testMode ? _rewardedTest : _rewardedReal;

  // --- Abbonamento "senza pubblicità" (Play Console → Monetizza → Abbonamenti) ---
  static const String removeAdsProductId = 'remove_ads';

  // --- Link di supporto per il sito (Ko-fi / Buy Me a Coffee ...). Vuoto = nascosto ---
  static const String supportUrl = '';
}
