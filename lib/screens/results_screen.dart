import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/poi.dart';
import '../models/stop.dart';
import '../services/journey_planner.dart';
import '../widgets/trip_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trip_detail_screen.dart';

int _gapMinutes(TimeOfDay from, TimeOfDay to) {
  final a = from.hour * 60 + from.minute;
  final b = to.hour * 60 + to.minute;
  return b >= a ? b - a : b + 1440 - a;
}

String _fmtGap(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '${m}min';
  return m == 0 ? '${h}h' : '${h}h ${m}min';
}

class ResultsScreen extends StatelessWidget {
  final Stop origin;
  final Stop destination;
  final Poi? destinationPoi;
  final DateTime date;
  final TimeOfDay time;
  final SearchMode mode;
  final String calendarId;
  final String dayTypeLabel;

  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    this.destinationPoi,
    required this.date,
    required this.time,
    required this.mode,
    required this.calendarId,
    required this.dayTypeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final planner = JourneyPlanner(ScheduleRepository.instance);
    final results = planner.search(
      calendarId: calendarId,
      originId: origin.id,
      destinationId: destination.id,
      mode: mode,
      reference: time,
    );
    final connected =
        planner.directionFor(calendarId, origin.id, destination.id) != null;
    final localeName = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat('EEEE d MMMM', localeName).format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          destinationPoi != null
              ? '${origin.name} → ${destinationPoi!.name}'
              : '${origin.name} → ${destination.name}',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                      icon: Icons.calendar_month_rounded, label: dateLabel),
                  _InfoChip(
                    icon: mode == SearchMode.departAfter
                        ? Icons.north_east_rounded
                        : Icons.south_west_rounded,
                    label: mode == SearchMode.departAfter
                        ? '${l.departAfter} ${time.format(context)}'
                        : '${l.arriveBy} ${time.format(context)}',
                  ),
                  _InfoChip(
                      icon: Icons.event_available_rounded,
                      label: dayTypeLabel),
                ],
              ),
              if (destinationPoi != null && destinationPoi!.walkMinutes > 0) ...[
                const SizedBox(height: 12),
                _WalkBanner(
                    poi: destinationPoi!, stopName: destination.name),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: !connected
                    ? _EmptyState(
                        icon: Icons.report_gmailerrorred_rounded,
                        title: l.noDirectTrip,
                        message: l.noDirectTripMessage(
                            origin.name, destination.name),
                      )
                    : results.isEmpty
                        ? _EmptyState(
                            icon: Icons.schedule_rounded,
                            title: l.noBusFound,
                            message: mode == SearchMode.departAfter
                                ? l.noBusFoundDepartMessage(dayTypeLabel)
                                : l.noBusFoundArriveMessage,
                          )
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final isLast = index == results.length - 1;
                              final gapMin = index > 0
                                  ? _gapMinutes(results[index - 1].departureTime,
                                      results[index].departureTime)
                                  : 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (gapMin > 60)
                                    _GapSeparator(gapMinutes: gapMin),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => TripDetailScreen(
                                          origin: origin,
                                          destination: destination,
                                          destinationPoi: destinationPoi,
                                          result: results[index],
                                          dayTypeLabel: dayTypeLabel,
                                          calendarId: calendarId,
                                        ),
                                      ),
                                    ),
                                    child: TripCard(
                                      result: results[index],
                                      originName: origin.name,
                                      destinationName:
                                          destinationPoi?.name ?? destination.name,
                                      highlighted: index == 0,
                                      isLast: isLast,
                                      calendarId: calendarId,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
              ),
              if (connected && results.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final destLat = destinationPoi?.lat ?? destination.lat;
                      final destLng = destinationPoi?.lng ?? destination.lng;
                      final uri = Uri.parse(
                        'https://www.google.com/maps/dir/${origin.lat},${origin.lng}/$destLat,$destLng',
                      );
                      launchUrl(uri, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.map_rounded),
                    label: Text(l.viewRouteOnMap),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GapSeparator extends StatelessWidget {
  final int gapMinutes;
  const _GapSeparator({required this.gapMinutes});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              size: 15, color: scheme.error.withOpacity(0.8)),
          const SizedBox(width: 6),
          Text(
            'Buco: ${_fmtGap(gapMinutes)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.error.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkBanner extends StatelessWidget {
  final Poi poi;
  final String stopName;
  const _WalkBanner({required this.poi, required this.stopName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_walk_rounded,
              color: scheme.onTertiaryContainer, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.walkToPoiBanner(poi.walkMinutes),
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: scheme.onTertiaryContainer),
                ),
                Text(
                  l.walkFromStop(stopName),
                  style: TextStyle(
                      fontSize: 12,
                      color: scheme.onTertiaryContainer.withOpacity(0.8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState(
      {required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 56,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color:
                        Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
