import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/subscription_controller.dart';

/// Piccolo promemoria in home su quando scade l'abbonamento registrato
/// dall'utente in Impostazioni. Non mostra nulla se non è stato impostato.
class SubscriptionBanner extends StatelessWidget {
  const SubscriptionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return AnimatedBuilder(
      animation: SubscriptionController.instance,
      builder: (context, _) {
        final sub = SubscriptionController.instance;
        if (!sub.hasSubscription) return const SizedBox.shrink();

        final days = sub.daysRemaining!;
        final expired = days < 0;
        final soon = !expired && days <= 7;
        final color = expired ? Colors.red[700]! : (soon ? Colors.orange[700]! : Colors.green[700]!);
        final text = expired
            ? l.subscriptionExpiredDays(-days)
            : days == 0
                ? l.subscriptionExpiresToday
                : l.subscriptionExpiresInDays(days);

        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.confirmation_number_rounded, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ],
          ),
        );
      },
    );
  }
}
