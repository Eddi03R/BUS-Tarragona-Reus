import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/ads_config.dart';
import '../services/ads/ads_backend.dart';
import '../services/ads_controller.dart';

/// Sezione "Supporta lo sviluppatore" nelle Impostazioni.
/// Android: video con ricompensa + abbonamento senza pubblicità.
/// Web: solo il link di supporto (se configurato).
class SupportSection extends StatelessWidget {
  const SupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = AdsController.instance;
    return ListenableBuilder(
      listenable: ads,
      builder: (context, _) {
        final l = AppLocalizations.of(context)!;
        final scheme = Theme.of(context).colorScheme;

        if (!ads.supported) {
          if (AdsConfig.supportUrl.isEmpty) return const SizedBox.shrink();
          return _Block(
            title: l.supportTitle,
            subtitle: l.supportSubtitle,
            children: [
              FilledButton.icon(
                onPressed: () => launchUrl(Uri.parse(AdsConfig.supportUrl),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.favorite_rounded),
                label: Text(l.supportLinkButton),
              ),
            ],
          );
        }

        if (ads.premium) {
          return _Block(
            title: l.supportTitle,
            subtitle: l.premiumActive,
            children: [
              OutlinedButton.icon(
                onPressed: () => launchUrl(
                    Uri.parse('https://play.google.com/store/account/subscriptions'),
                    mode: LaunchMode.externalApplication),
                icon: const Icon(Icons.manage_accounts_rounded),
                label: Text(l.manageSubscription),
              ),
            ],
          );
        }

        return _Block(
          title: l.supportTitle,
          subtitle: l.supportSubtitle,
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
                  messenger.showSnackBar(SnackBar(content: Text(l.adThanks)));
                }
              },
              icon: const Icon(Icons.favorite_rounded),
              label: Text(l.watchAdButton, textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text(l.removeAdsTitle,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (ads.products.isEmpty)
              Text(l.subscriptionUnavailable,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant))
            else
              Row(
                children: [
                  for (final p in ads.products) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => ads.buy(p),
                        child: Text(
                          p.period == SubPeriod.yearly
                              ? l.removeAdsYearly(p.price)
                              : l.removeAdsMonthly(p.price),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    if (p != ads.products.last) const SizedBox(width: 10),
                  ],
                ],
              ),
            TextButton(
              onPressed: ads.restore,
              child: Text(l.restorePurchases),
            ),
            if (ads.privacyOptionsRequired)
              TextButton(
                onPressed: ads.showPrivacyOptions,
                child: Text(l.adPrivacyOptions),
              ),
          ],
        );
      },
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const _Block({required this.title, required this.subtitle, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}
