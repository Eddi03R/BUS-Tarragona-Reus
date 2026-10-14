import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(fontSize: 14, height: 1.6, color: scheme.onSurface);
    final subtitleColor = scheme.onSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l.privacyPolicyP1, style: bodyStyle),
          const SizedBox(height: 12),
          Text(l.privacyPolicyP2, style: bodyStyle),
          const SizedBox(height: 12),
          Text(l.privacyPolicyP3, style: bodyStyle),
          const SizedBox(height: 12),
          Text(l.privacyPolicyP4, style: bodyStyle),
          const SizedBox(height: 32),
          Text(
            l.privacyPolicyContact,
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
          const SizedBox(height: 24),
          Text(
            l.copyright,
            style: TextStyle(fontSize: 12, color: subtitleColor),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
