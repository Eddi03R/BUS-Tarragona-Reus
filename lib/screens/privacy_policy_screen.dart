import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _onlineUrl =
      'https://eddi03r.github.io/BUS-Tarragona-Reus/privacy.html';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final bodyStyle = TextStyle(fontSize: 14, height: 1.65, color: scheme.onSurface);

    return Scaffold(
      appBar: AppBar(title: Text(l.privacyPolicyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.privacy_tip_rounded, color: scheme.onPrimary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.privacyPolicyTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ErasBus Tarragona · Lume Labs App',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _Section(
            icon: Icons.shield_outlined,
            title: l.privacySection1Title,
            body: l.privacyPolicyP1,
            bodyStyle: bodyStyle,
            scheme: scheme,
          ),
          _Section(
            icon: Icons.my_location_rounded,
            title: l.privacySection2Title,
            body: l.privacyPolicyP2loc,
            bodyStyle: bodyStyle,
            scheme: scheme,
          ),
          _Section(
            icon: Icons.bar_chart_rounded,
            title: l.privacySection3Title,
            body: l.privacyPolicyP3,
            bodyStyle: bodyStyle,
            scheme: scheme,
          ),
          _Section(
            icon: Icons.public_rounded,
            title: l.privacySection4Title,
            body: l.privacyPolicyP4osm,
            bodyStyle: bodyStyle,
            scheme: scheme,
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(_onlineUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(l.privacyViewOnline),
          ),
          const SizedBox(height: 20),
          Text(
            l.privacyPolicyContact,
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            l.copyright,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final TextStyle bodyStyle;
  final ColorScheme scheme;

  const _Section({
    required this.icon,
    required this.title,
    required this.body,
    required this.bodyStyle,
    required this.scheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(top: 2, right: 14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(body, style: bodyStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
