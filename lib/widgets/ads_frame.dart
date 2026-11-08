import 'package:flutter/material.dart';
import '../services/ads_controller.dart';

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
        return Column(
          children: [
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeBottom: show, // il banner occupa già la zona sotto
                child: child,
              ),
            ),
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
        );
      },
    );
  }
}
