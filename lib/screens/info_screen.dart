import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/christmas_decorations.dart';

/// Info utili: link ai canali ufficiali (università, trasporti, città).
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    Widget section(String title, List<_Link> links) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
              child: Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < links.length; i++) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: scheme.primaryContainer,
                        child: Icon(links[i].icon, color: scheme.onPrimaryContainer, size: 22),
                      ),
                      title: Text(links[i].title,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: links[i].subtitle == null ? null : Text(links[i].subtitle!),
                      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                      onTap: () => launchUrl(Uri.parse(links[i].url),
                          mode: LaunchMode.externalApplication),
                    ),
                    if (i < links.length - 1)
                      Divider(height: 1, indent: 72, color: scheme.outlineVariant.withOpacity(0.5)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.usefulInfoTitle)),
      body: ChristmasBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            section(l.infoSecUniversity, [
              _Link(Icons.school_rounded, l.linkUrv, l.linkUrvSub, 'https://www.urv.cat/international'),
            ]),
            section(l.infoSecTransport, [
              _Link(Icons.directions_bus_rounded, l.linkMonbus, l.linkMonbusSub, 'https://www.monbus.es/es'),
            ]),
            section(l.infoSecCities, [
              _Link(Icons.location_city_rounded, l.linkTarragona, null, 'https://www.tarragona.cat'),
              _Link(Icons.location_city_rounded, l.linkReus, null, 'https://www.reus.cat'),
              _Link(Icons.beach_access_rounded, l.linkSalou, null, 'https://www.salou.cat'),
              _Link(Icons.photo_camera_rounded, l.linkTurisme, null, 'https://www.tarragonaturisme.cat'),
            ]),
            Text(l.infoDisclaimer,
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _Link {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String url;
  const _Link(this.icon, this.title, this.subtitle, this.url);
}
