import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../../config/ads_config.dart';
import 'ads_backend.dart';

AdsBackend createBackend() => _MobileBackend();

class _MobileBackend implements AdsBackend {
  AdsHost? _host;
  RewardedAd? _rewarded;
  bool _loadingRewarded = false;
  bool _canRequestAds = false;
  bool _sawActiveSubscription = false;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  // Gli annunci sono configurati solo per Android (App ID nel manifest).
  @override
  bool get supported => defaultTargetPlatform == TargetPlatform.android;

  @override
  bool get rewardedReady => _rewarded != null;

  @override
  Future<void> init(AdsHost host) async {
    _host = host;
    // Acquisti e consenso partono in parallelo: gli abbonati non devono
    // dipendere dal consenso pubblicitario.
    unawaited(_initPurchases());
    await _initConsentAndAds();
  }

  // ---------------------------------------------------------------- consenso
  Future<void> _initConsentAndAds() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () {
        ConsentForm.loadAndShowConsentFormIfRequired((_) {
          if (!done.isCompleted) done.complete();
        });
      },
      (_) {
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;

    try {
      final status =
          await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
      _host?.setPrivacyOptionsRequired(
          status == PrivacyOptionsRequirementStatus.required);
      _canRequestAds = await ConsentInformation.instance.canRequestAds();
    } catch (_) {
      _canRequestAds = false;
    }
    if (_canRequestAds) {
      await MobileAds.instance.initialize();
      _host?.setCanRequestAds(true);
      _loadRewarded();
    }
  }

  @override
  Future<void> showPrivacyOptions() async {
    await ConsentForm.showPrivacyOptionsForm((_) {});
  }

  // ------------------------------------------------------------------ banner
  @override
  Widget banner() => const _BannerSlot();

  // ---------------------------------------------------------------- rewarded
  void _loadRewarded() {
    if (!_canRequestAds || _loadingRewarded || _rewarded != null) return;
    _loadingRewarded = true;
    RewardedAd.load(
      adUnitId: AdsConfig.rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _loadingRewarded = false;
          _host?.notifyChanged();
        },
        onAdFailedToLoad: (_) {
          _loadingRewarded = false;
          _host?.notifyChanged();
        },
      ),
    );
  }

  @override
  Future<bool> showRewarded() async {
    final ad = _rewarded;
    if (ad == null) return false;
    _rewarded = null;
    _host?.notifyChanged();
    final result = Completer<bool>();
    var earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) result.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _loadRewarded();
        if (!result.isCompleted) result.complete(false);
      },
    );
    await ad.show(onUserEarnedReward: (_, __) => earned = true);
    return result.future;
  }

  // ---------------------------------------------------------------- acquisti
  Future<void> _initPurchases() async {
    final iap = InAppPurchase.instance;
    final available = await iap.isAvailable();
    if (!available) return;

    _purchaseSub = iap.purchaseStream.listen(_onPurchases, onError: (_) {});

    final response = await iap.queryProductDetails({AdsConfig.removeAdsProductId});
    final products = <SubProduct>[];
    for (final d in response.productDetails) {
      if (d is! GooglePlayProductDetails) continue;
      final idx = d.subscriptionIndex;
      final offers = d.productDetails.subscriptionOfferDetails;
      if (idx == null || offers == null || idx >= offers.length) continue;
      final offer = offers[idx];
      // Solo i piani base (senza offerte promozionali), riconosciuti dal periodo.
      if (offer.offerId != null || offer.pricingPhases.isEmpty) continue;
      final period = offer.pricingPhases.last.billingPeriod; // ISO 8601: P1M / P1Y
      products.add(SubProduct(
        period: period == 'P1Y' ? SubPeriod.yearly : SubPeriod.monthly,
        price: d.price,
        raw: d,
      ));
    }
    products.sort((a, b) => a.period.index.compareTo(b.period.index));
    _host?.setProducts(products);

    // Ripristina gli abbonamenti attivi; se dopo qualche secondo lo store non
    // ne ha segnalati, l'abbonamento è scaduto o annullato.
    await iap.restorePurchases();
    Future<void>.delayed(const Duration(seconds: 10), () {
      if (!_sawActiveSubscription) _host?.setPremium(false);
    });
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      if (p.productID != AdsConfig.removeAdsProductId) continue;
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _sawActiveSubscription = true;
        _host?.setPremium(true);
      }
      if (p.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(p);
      }
    }
  }

  @override
  Future<void> buy(SubProduct product) async {
    final d = product.raw as GooglePlayProductDetails;
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: GooglePlayPurchaseParam(
        productDetails: d,
        offerToken: d.offerToken,
      ),
    );
  }

  @override
  Future<void> restore() => InAppPurchase.instance.restorePurchases();
}

/// Banner 320x50 a fondo schermata.
class _BannerSlot extends StatefulWidget {
  const _BannerSlot();
  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _ad = BannerAd(
      adUnitId: AdsConfig.bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    )..load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _ad == null) return const SizedBox(height: 50);
    return SizedBox(
      width: AdSize.banner.width.toDouble(),
      height: AdSize.banner.height.toDouble(),
      child: AdWidget(ad: _ad!),
    );
  }
}
