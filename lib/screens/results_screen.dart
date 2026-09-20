import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import '../models/stop.dart';
import '../services/journey_planner.dart';
import '../widgets/trip_card.dart';
import 'map_screen.dart';

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
    final planner = JourneyPlanner(ScheduleRepository.instance);
    final results = planner.search(
      calendarId: calendarId,
      originId: origin.id,
      destinationId: destination.id,
      mode: mode,
      reference: time,
    );
    final connected = planner.directionFor(calendarId, origin.id, destination.id) != null;
    final dateLabel = DateFormat('EEEE d MMMM', 'it_IT').format(date);

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
                        ? 'Parto dopo le ${time.format(context)}'
                        : 'Arrivo entro le ${time.format(context)}',
                  ),
                  _InfoChip(icon: Icons.event_available_rounded, label: dayTypeLabel),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: !connected
                    ? _EmptyState(
                        icon: Icons.report_gmailerrorred_rounded,
                        title: 'Nessuna corsa diretta',
                        message:
                            'Non esiste una corsa diretta da "${origin.name}" a "${destination.name}" su questa linea. Prova a invertire partenza e arrivo.',
                      )
                    : results.isEmpty
                        ? _EmptyState(
                            icon: Icons.schedule_rounded,
                            title: 'Nessun bus trovato',
                            message: mode == SearchMode.departAfter
                                ? 'Non ci sono più corse dopo questo orario per il calendario "$dayTypeLabel". Prova un altro orario o giorno.'
                                : 'Non ci sono corse che arrivano in tempo. Prova un orario limite più tardo o un altro giorno.',
                          )
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              return TripCard(
                                result: results[index],
                                originName: origin.name,
                                destinationName: destination.name,
                                highlighted: index == 0,
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
                    label: const Text('Vedi il percorso sulla mappa'),
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
            Icon(icon, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
