/// Configurazione pubblicità e abbonamento (solo Android).
///
/// Gli ID qui sotto sono gli ID di PROVA ufficiali di Google: mostrano annunci
/// finti e non fanno guadagnare. Prima del rilascio vanno sostituiti con quelli
/// reali di AdMob (e l'App ID in android/app/src/main/AndroidManifest.xml).
class AdsConfig {
  AdsConfig._();

  // --- AdMob (ID di prova Google) ---
  static const String bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';

  // --- Abbonamento "senza pubblicità" (Play Console → Monetizza → Abbonamenti) ---
  static const String removeAdsProductId = 'remove_ads';

  // --- Link di supporto per il sito (Ko-fi / Buy Me a Coffee ...). Vuoto = nascosto ---
  static const String supportUrl = '';
}
