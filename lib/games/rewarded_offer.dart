import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import '../services/ads_controller.dart';

/// Aiuti nei giochi in cambio di una pubblicità con ricompensa (volontaria).
/// Gratis per chi ha l'abbonamento "senza pubblicità" e dove le pubblicità non
/// esistono (sito web). Dove la pubblicità serve ma non è pronta, l'aiuto non
/// viene offerto.
class RewardedOffer {
  static AdsController get _ads => AdsController.instance;

  /// L'aiuto è gratuito (abbonato o piattaforma senza pubblicità).
  static bool get free => _ads.premium || !_ads.supported;

  /// Si può offrire l'aiuto adesso.
  static bool get available => free || _ads.rewardedReady;

  /// Icona del pulsante: il simbolo "video" indica che c'è una pubblicità.
  static IconData icon(IconData whenFree) => free ? whenFree : Icons.ondemand_video_rounded;

  /// Chiede conferma e, se serve, mostra la pubblicità. Restituisce true
  /// quando l'aiuto è stato guadagnato.
  static Future<bool> ask(
    BuildContext context, {
    required String game,
    required String action,
    required String title,
    required String message,
  }) async {
    final l = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    if (!available) {
      messenger.showSnackBar(SnackBar(content: Text(l.adNotReady)));
      return false;
    }
    final isFree = free;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(isFree ? l.rewardedFreeNote : message),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l.rewardedNo)),
          FilledButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: Icon(isFree ? Icons.check_rounded : Icons.ondemand_video_rounded),
            label: Text(isFree ? l.rewardedContinue : l.rewardedWatch),
          ),
        ],
      ),
    );
    if (ok != true) return false;
    if (isFree) {
      AnalyticsService.instance.log('game_help_free', {'game': game, 'action': action});
      return true;
    }
    final earned = await _ads.watchRewardedAd();
    if (earned) {
      AnalyticsService.instance.log('game_help_rewarded', {'game': game, 'action': action});
    }
    return earned;
  }
}

/// Pulsante secondario per un aiuto (salta, mostra, recupera…).
class HelpButton extends StatelessWidget {
  final IconData freeIcon;
  final String label;
  final VoidCallback onPressed;
  const HelpButton({
    super.key,
    required this.freeIcon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: scheme.tertiaryContainer,
          foregroundColor: scheme.onTertiaryContainer,
        ),
        onPressed: onPressed,
        icon: Icon(RewardedOffer.icon(freeIcon), size: 20),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
