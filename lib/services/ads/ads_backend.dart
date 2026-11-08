import 'package:flutter/widgets.dart';
import 'ads_backend_stub.dart' if (dart.library.io) 'ads_backend_mobile.dart'
    as impl;

enum SubPeriod { monthly, yearly }

/// Un'offerta di abbonamento mostrabile all'utente.
class SubProduct {
  final SubPeriod period;
  final String price; // già formattato dallo store, es. "0,99 €"
  final Object raw; // dettagli specifici della piattaforma
  const SubProduct({required this.period, required this.price, required this.raw});
}

/// Cosa il backend può comunicare al controller.
abstract class AdsHost {
  void setCanRequestAds(bool value);
  void setPremium(bool value);
  void setProducts(List<SubProduct> products);
  void setPrivacyOptionsRequired(bool value);
  void notifyChanged();
  void setDiagnostic(String key, String value);
}

/// Implementazione specifica di piattaforma (Android: AdMob + Play Billing;
/// web/altro: nessuna funzione). Il file stub evita di compilare i plugin
/// mobili nella build web.
abstract class AdsBackend {
  static AdsBackend create() => impl.createBackend();

  bool get supported;
  Future<void> init(AdsHost host);
  Widget banner();
  bool get rewardedReady;

  /// true se l'utente ha guardato il video fino alla ricompensa.
  Future<bool> showRewarded();

  /// Avvia l'acquisto; l'esito arriva poi via [AdsHost.setPremium].
  Future<void> buy(SubProduct product);
  Future<void> restore();
  Future<void> showPrivacyOptions();
}
