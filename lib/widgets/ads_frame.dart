import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/ads_controller.dart';
import '../services/analytics_service.dart';

/// Mette un banner a fondo schermata sotto tutte le schermate (solo Android,
/// solo se l'utente non è abbonato). La struttura dell'albero non cambia mai,
/// così la navigazione non si resetta quando il banner appare o sparisce.
class AdsFrame extends StatelessWidget {
  final Widget child;
  const AdsFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdsController.instance,
      builder: (context, _) {
        final show = AdsController.instance.showAds;
        // Sfondo sotto la navigazione: evita gli angoli neri durante le
        // animazioni di ritorno (gesto "indietro" di Android).
        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: show, // il banner occupa già la zona sotto
                child: child,
              ),
            ),
            const _AnalyticsConsentBar(),
            if (show)
              Container(
                color: Theme.of(context).colorScheme.surface,
                child: SafeArea(
                  top: false,
                  child: Center(
                    heightFactor: 1,
                    child: AdsController.instance.banner(),
                  ),
                ),
              ),
          ],
          ),
        );
      },
    );
  }
}

/// Banner di consenso per le statistiche: solo sul web, finché non si sceglie.
class _AnalyticsConsentBar extends StatelessWidget {
  const _AnalyticsConsentBar();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnalyticsService.instance,
      builder: (context, _) {
        if (!AnalyticsService.instance.needsWebPrompt) {
          return const SizedBox.shrink();
        }
        final l = AppLocalizations.of(context);
        if (l == null) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        return Material(
          color: scheme.surfaceContainerHighest,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(l.analyticsConsentText,
                        style: const TextStyle(fontSize: 13)),
                  ),
                  TextButton(
                    onPressed: () => AnalyticsService.instance.setChoice(false),
                    child: Text(l.analyticsReject),
                  ),
                  FilledButton(
                    onPressed: () => AnalyticsService.instance.setChoice(true),
                    child: Text(l.analyticsAccept),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
