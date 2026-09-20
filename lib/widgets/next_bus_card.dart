import 'package:flutter/material.dart';
import '../data/schedule_repository.dart';
import '../models/stop.dart';
import '../services/calendar_resolver.dart';
import '../services/journey_planner.dart';
import '../screens/results_screen.dart';

/// Card compatta mostrata in home per la prima tratta preferita: calcola al
/// volo i prossimi bus da adesso, senza dover aprire la ricerca.
class NextBusCard extends StatelessWidget {
  final Stop origin;
  final Stop destination;

  const NextBusCard({super.key, required this.origin, required this.destination});

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final dayType = CalendarResolver.dayTypeFor(now);
    final calendarId = CalendarResolver.calendarIdFor(dayType);
    final planner = JourneyPlanner(ScheduleRepository.instance);
    final results = planner.search(
      calendarId: calendarId,
      originId: origin.id,
      destinationId: destination.id,
      mode: SearchMode.departAfter,
      reference: TimeOfDay.now(),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultsScreen(
          origin: origin,
          destination: destination,
          date: now,
          time: TimeOfDay.now(),
          mode: SearchMode.departAfter,
          calendarId: calendarId,
          dayTypeLabel: CalendarResolver.labelFor(dayType),
        ),
      )),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star_rounded, size: 16, color: scheme.onPrimaryContainer),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${origin.name} → ${destination.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: scheme.onPrimaryContainer, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (results.isEmpty)
              Text('Nessun altro bus oggi per questa tratta',
                  style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13))
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Prossimo bus ',
                      style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13),
                    ),
                    TextSpan(
                      text: _fmt(results.first.departureTime),
                      style: TextStyle(
                          color: scheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (results.length > 1)
                      TextSpan(
                        text: '   ·   poi ${_fmt(results[1].departureTime)}',
                        style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13),
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
