import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

/// Riquadro ambra: il biglietto a bordo si paga SOLO in contanti
/// (valido per le corse notturne, tutti gli operatori).
class CashOnlyNote extends StatelessWidget {
  const CashOnlyNote({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.18),
        border: Border.all(color: Colors.amber.shade700.withOpacity(0.6)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_rounded, size: 20, color: Colors.amber.shade800),
          const SizedBox(width: 10),
          Expanded(
            child: Text(l.payCashOnly,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: Theme.of(context).colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
