import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/ads_config.dart';
import '../services/ads/ads_backend.dart';
import '../services/ads_controller.dart';
import '../services/analytics_service.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/themed_banner.dart';

/// Pagina "Supporta lo sviluppatore".
/// Android: video con ricompensa (NON toglie la pubblicità) + abbonamento
/// mensile/annuale che la toglie. Web: solo il link di supporto.
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  /// La voce nel menu compare solo se c'è qualcosa da mostrare.
  static bool get available =>
      AdsController.instance.supported || AdsConfig.supportUrl.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final ads = AdsController.instance;
    return Scaffold(
      appBar: AppBar(title: Text(l.supportTitle)),
      body: ChristmasBackdrop(
        child: ListenableBuilder(
          listenable: ads,
          builder: (context, _) {
            final scheme = Theme.of(context).colorScheme;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                ThemedBanner(
                  child: Row(
                    children: [
                      const Icon(Icons.favorite_rounded, size: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.supportTitle,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(l.supportSubtitle, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (!ads.supported) ...[
                  FilledButton.icon(
                    onPressed: () => launchUrl(Uri.parse(AdsConfig.supportUrl),
                        mode: LaunchMode.externalApplication),
                    icon: const Icon(Icons.favorite_rounded),
                    label: Text(l.supportLinkButton),
                  ),
                ] else ...[
                  _Block(
                    title: l.watchAdTitle,
                    note: l.supportVideoNote,
                    children: [
                      FilledButton.icon(
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          if (!ads.rewardedReady) {
                            messenger.showSnackBar(SnackBar(content: Text(l.adNotReady)));
                            return;
                          }
                          final earned = await ads.watchRewardedAd();
                          if (earned) {
                            AnalyticsService.instance.log('rewarded_ad_watched');
                            messenger.showSnackBar(SnackBar(content: Text(l.adThanks)));
                          }
                        },
                        icon: const Icon(Icons.play_circle_rounded),
                        label: Text(l.watchAdButton, textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _Block(
                    title: l.removeAdsTitle,
                    note: ads.premium ? l.premiumActive : l.supportAdFreeNote,
                    children: [
                      if (ads.premium)
                        OutlinedButton.icon(
                          onPressed: () => launchUrl(
                              Uri.parse('https://play.google.com/store/account/subscriptions'),
                              mode: LaunchMode.externalApplication),
                          icon: const Icon(Icons.manage_accounts_rounded),
                          label: Text(l.manageSubscription),
                        )
                      else ...[
                        if (ads.products.isEmpty)
                          Text(l.subscriptionUnavailable,
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant))
                        else
                          for (final p in ads.products) ...[
                            _PlanTile(
                              label: p.period == SubPeriod.yearly
                                  ? l.removeAdsYearly(p.price)
                                  : l.removeAdsMonthly(p.price),
                              badge: p.period == SubPeriod.yearly ? l.bestValue : null,
                              onTap: () {
                                AnalyticsService.instance
                                    .log('purchase_start', {'period': p.period.name});
                                ads.buy(p);
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        Text(l.subscriptionTerms,
                            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
                        TextButton(onPressed: ads.restore, child: Text(l.restorePurchases)),
                        if (ads.privacyOptionsRequired)
                          TextButton(
                              onPressed: ads.showPrivacyOptions,
                              child: Text(l.adPrivacyOptions)),
                      ],
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String note;
  final List<Widget> children;
  const _Block({required this.title, required this.note, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(note, style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _PlanTile extends StatelessWidget {
  final String label;
  final String? badge;
  final VoidCallback onTap;
  const _PlanTile({required this.label, required this.onTap, this.badge});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(badge!,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scheme.onPrimaryContainer)),
            ),
        ],
      ),
    );
  }
}
