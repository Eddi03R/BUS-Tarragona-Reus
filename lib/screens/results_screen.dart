import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import '../models/stop.dart';
import '../services/journey_planner.dart';
import '../widgets/trip_card.dart';
import 'map_screen.dart';
import 'trip_detail_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Stop origin;
  final Stop destination;
  final DateTime date;
  final TimeOfDay time;
  final SearchMode mode;
  final String calendarId;
  final String dayTypeLabel;

  const ResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
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
    final connected = planner.directionFor(calendarId, origin.id, destination.id) != null;
    final localeName = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat('EEEE d MMMM', localeName).format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text('${origin.name} → ${destination.name}', overflow: TextOverflow.ellipsis),
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
                  _InfoChip(icon: Icons.calendar_month_rounded, label: dateLabel),
                  _InfoChip(
                    icon: mode == SearchMode.departAfter ? Icons.north_east_rounded : Icons.south_west_rounded,
                    label: mode == SearchMode.departAfter
                        ? '${l.departAfter} ${time.format(context)}'
                        : '${l.arriveBy} ${time.format(context)}',
                  ),
                  _InfoChip(icon: Icons.event_available_rounded, label: dayTypeLabel),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !connected
                    ? _EmptyState(
                        icon: Icons.report_gmailerrorred_rounded,
                        title: l.noDirectTrip,
                        message: l.noDirectTripMessage(origin.name, destination.name),
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
                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => TripDetailScreen(
                                    origin: origin,
                                    destination: destination,
                                    result: results[index],
                                    dayTypeLabel: dayTypeLabel,
                                    calendarId: calendarId,
                                  ),
                                )),
                                child: TripCard(
                                  result: results[index],
                                  originName: origin.name,
                                  destinationName: destination.name,
                                  highlighted: index == 0,
                                ),
                              );
                            },
                          ),
              ),
              if (connected && results.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final stops = ScheduleRepository.instance.stopsForCalendar(calendarId);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => MapScreen(
                          stops: stops,
                          highlightOriginId: origin.id,
                          highlightDestinationId: destination.id,
                        ),
                      ));
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
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
