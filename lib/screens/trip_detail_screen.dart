import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import '../models/poi.dart';
import '../models/stop.dart';
import '../services/favorites_controller.dart';

class TripDetailScreen extends StatefulWidget {
  final Stop origin;
  final Stop destination;
  final Poi? destinationPoi;
  final JourneyResult result;
  final String dayTypeLabel;
  final String calendarId;

  const TripDetailScreen({
    super.key,
    required this.origin,
    required this.destination,
    this.destinationPoi,
    required this.result,
    required this.dayTypeLabel,
    required this.calendarId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late final List<Stop> _servedStops;

  @override
  void initState() {
    super.initState();
    _servedStops = widget.result.servedStops
        .map((s) => ScheduleRepository.instance.stopById(s.stopId))
        .toList();
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _share(AppLocalizations l) {
    final text = l.shareText(
      widget.origin.name,
      widget.destination.name,
      _fmt(widget.result.departureTime),
      _fmt(widget.result.arrivalTime),
      widget.result.travelTime.inMinutes,
      widget.dayTypeLabel,
    );
    Share.share(text);
  }

  void _openMaps() {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/${widget.origin.lat},${widget.origin.lng}/${widget.destination.lat},${widget.destination.lng}',
    );
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openDestinationOnMaps() {
    final Uri uri;
    if (widget.destinationPoi != null) {
      // Navigazione a piedi dalla fermata al POI
      final poi = widget.destinationPoi!;
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${widget.destination.lat},${widget.destination.lng}'
        '&destination=${poi.lat},${poi.lng}'
        '&travelmode=walking',
      );
    } else {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${widget.destination.lat},${widget.destination.lng}',
      );
    }
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final isExpress = _servedStops.length <= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tripDetailsTitle),
        actions: [
          ListenableBuilder(
            listenable: FavoritesController.instance,
            builder: (context, _) {
              final isFav = FavoritesController.instance
                  .isFavorite(widget.origin.id, widget.destination.id);
              return IconButton(
                icon: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded),
                tooltip: isFav ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti',
                onPressed: () => FavoritesController.instance
                    .toggle(widget.origin.id, widget.destination.id),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: l.shareTooltip,
            onPressed: () => _share(l),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.fromLabel, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(widget.origin.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(l.toLabel, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(widget.destination.name,
                                textAlign: TextAlign.end,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fmt(widget.result.departureTime),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text(l.departureLabel, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.directions_bus_filled_rounded, color: Colors.white.withOpacity(0.9)),
                          const SizedBox(height: 2),
                          Text(l.minutesAbbrev(widget.result.travelTime.inMinutes),
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_fmt(widget.result.arrivalTime),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text(l.arrivalLabel, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(icon: Icons.event_available_rounded, label: widget.dayTypeLabel),
                      _Chip(icon: Icons.route_rounded, label: widget.result.directionLabel),
                      _Chip(
                        icon: isExpress ? Icons.bolt_rounded : Icons.alt_route_rounded,
                        label: isExpress ? l.direct : l.stopsCount(_servedStops.length),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Fermata di discesa
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flag_rounded, color: Colors.red, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scendi a:',
                            style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                        Text(widget.destination.name,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.destinationPoi != null
                          ? Icons.directions_walk_rounded
                          : Icons.directions,
                      color: Colors.red,
                    ),
                    tooltip: widget.destinationPoi != null
                        ? 'A piedi a ${widget.destinationPoi!.name}'
                        : 'Naviga alla fermata',
                    onPressed: _openDestinationOnMaps,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_rounded),
                label: const Text('Segui il percorso su Google Maps'),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.stopsOfThisTrip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  for (var i = 0; i < _servedStops.length; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            i == 0
                                ? Icons.trip_origin
                                : i == _servedStops.length - 1
                                    ? Icons.flag_rounded
                                    : Icons.circle,
                            size: i == 0 || i == _servedStops.length - 1 ? 18 : 8,
                            color: i == 0
                                ? Colors.green
                                : i == _servedStops.length - 1
                                    ? Colors.red
                                    : scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_servedStops[i].name,
                                    style: TextStyle(
                                        fontWeight: i == 0 || i == _servedStops.length - 1
                                            ? FontWeight.bold
                                            : FontWeight.normal)),
                                if (i == _servedStops.length - 1)
                                  const Text('Scendi qui',
                                      style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Text(_fmt(widget.result.servedStops[i].time),
                              style: TextStyle(fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
