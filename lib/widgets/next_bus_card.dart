import 'dart:async';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../data/schedule_repository.dart';
import '../models/stop.dart';
import '../services/calendar_resolver.dart';
import '../services/journey_planner.dart';
import '../screens/results_screen.dart';

/// Card compatta mostrata in home per la prima tratta preferita: calcola al
/// volo i prossimi bus da adesso (con countdown), senza dover aprire la
/// ricerca. Si aggiorna da sola ogni 30 secondi.
class NextBusCard extends StatefulWidget {
  final Stop origin;
  final Stop destination;

  const NextBusCard({super.key, required this.origin, required this.destination});

  @override
  State<NextBusCard> createState() => _NextBusCardState();
}

class _NextBusCardState extends State<NextBusCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _countdown(AppLocalizations l, int minutes) {
    if (minutes <= 0) return l.nextBusArriving;
    if (minutes < 60) return l.nextBusInMinutes(minutes);
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? l.nextBusInHours(h) : l.nextBusInHoursMinutes(h, m);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final nowTime = TimeOfDay.now();
    final dayType = CalendarResolver.dayTypeFor(now);
    final calendarId = CalendarResolver.calendarIdFor(dayType);
    final planner = JourneyPlanner(ScheduleRepository.instance);
    final results = planner.search(
      calendarId: calendarId,
      originId: widget.origin.id,
      destinationId: widget.destination.id,
      mode: SearchMode.departAfter,
      reference: nowTime,
    );
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResultsScreen(
          origin: widget.origin,
          destination: widget.destination,
          date: now,
          time: nowTime,
          mode: SearchMode.departAfter,
          calendarId: calendarId,
          dayTypeLabel: CalendarResolver.labelFor(l, dayType),
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
                    '${widget.origin.name} → ${widget.destination.name}',
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
              Text(l.noOtherBusToday,
                  style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13))
            else
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${_countdown(l, results.first.departureMinutes - nowMinutes)} · ',
                      style: TextStyle(
                          color: scheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: _fmt(results.first.departureTime),
                      style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (results.length > 1)
                      TextSpan(
                        text: '   ·   ${l.thenAt(_fmt(results[1].departureTime))}',
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
