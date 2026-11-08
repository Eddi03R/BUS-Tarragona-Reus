import 'package:flutter/widgets.dart';
import 'ads_backend.dart';

AdsBackend createBackend() => _StubBackend();

/// Web e piattaforme senza pubblicità: tutto disattivato.
class _StubBackend implements AdsBackend {
  @override
  bool get supported => false;
  @override
  Future<void> init(AdsHost host) async {}
  @override
  Widget banner() => const SizedBox.shrink();
  @override
  bool get rewardedReady => false;
  @override
  Future<bool> showRewarded() async => false;
  @override
  Future<void> buy(SubProduct product) async {}
  @override
  Future<void> restore() async {}
  @override
  Future<void> showPrivacyOptions() async {}
}
