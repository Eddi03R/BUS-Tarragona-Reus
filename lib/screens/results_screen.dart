import '../widgets/christmas_decorations.dart';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/poi.dart';
import '../models/stop.dart';
import '../services/analytics_service.dart';
import '../services/journey_planner.dart';
import '../widgets/cash_note.dart';
import '../widgets/thick_arrow.dart';
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

    final fg = Theme.of(context).appBarTheme.foregroundColor ??
        Theme.of(context).colorScheme.onSurface;
    final destName = destinationPoi?.name ?? destination.name;
    final hasTrips = connected && results.isNotEmpty;

    Widget infoCard() => _TripInfoCard(
          dateLabel: dateLabel,
          dayTypeLabel: dayTypeLabel,
          poi: destinationPoi,
          stopName: destination.name,
          showNightNote: hasTrips && calendarId.startsWith('night'),
          // Il biglietto a bordo solo in contanti vale per le corse notturne (tutti gli operatori).
          showCash: hasTrips && calendarId.startsWith('night'),
        );

    Widget tripItem(int index) {
      final isLast = index == results.length - 1;
      final gapMin = index > 0
          ? _gapMinutes(results[index - 1].departureTime, results[index].departureTime)
          : 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (gapMin > 60) _GapSeparator(gapMinutes: gapMin),
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () {
              AnalyticsService.instance.log('trip_open', {
                'origin': origin.id,
                'destination': destination.id,
              });
              Navigator.of(context).push(
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
              );
            },
            child: TripCard(
              result: results[index],
              originName: origin.name,
              destinationName: destName,
              highlighted: index == 0,
              isLast: isLast,
              calendarId: calendarId,
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Nomi interi su più righe (niente "..."), carattere un po' più piccolo.
        title: Row(
          children: [
            Flexible(
              child: Text(origin.name, maxLines: 2, style: const TextStyle(fontSize: 16, height: 1.15)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: ThickArrow(size: 20, color: fg),
            ),
            Flexible(
              child: Text(destName, maxLines: 2, style: const TextStyle(fontSize: 16, height: 1.15)),
            ),
          ],
        ),
      ),
      body: ChristmasBackdrop(child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: !connected
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                      children: [
                        infoCard(),
                        const SizedBox(height: 24),
                        _EmptyState(
                          icon: Icons.report_gmailerrorred_rounded,
                          title: l.noDirectTrip,
                          message: l.noDirectTripMessage(origin.name, destination.name),
                        ),
                      ],
                    )
                  : results.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          children: [
                            infoCard(),
                            const SizedBox(height: 24),
                            _EmptyState(
                              icon: Icons.schedule_rounded,
                              title: l.noBusFound,
                              message: mode == SearchMode.departAfter
                                  ? l.noBusFoundDepartMessage(dayTypeLabel)
                                  : l.noBusFoundArriveMessage,
                            ),
                          ],
                        )
                      // Info in cima (scorre insieme alle corse), poi i biglietti.
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                          itemCount: results.length + 1,
                          itemBuilder: (context, i) => i == 0
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: infoCard(),
                                )
                              : tripItem(i - 1),
                        ),
            ),
            if (hasTrips)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Se c'è una fermata consigliata, il bus scende lì.
                    final destLat = destinationPoi?.dropoff?.lat ?? destination.lat;
                    final destLng = destinationPoi?.dropoff?.lng ?? destination.lng;
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
      )),
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

/// Tutte le informazioni sul viaggio in un unico riquadro in alto: data e
/// calendario, fermata consigliata (con minuti a piedi), nota sulle corse
/// notturne e pagamento del biglietto a bordo.
class _TripInfoCard extends StatelessWidget {
  final String dateLabel;
  final String dayTypeLabel;
  final Poi? poi;
  final String stopName;
  final bool showNightNote;
  final bool showCash;
  const _TripInfoCard({
    required this.dateLabel,
    required this.dayTypeLabel,
    required this.poi,
    required this.stopName,
    required this.showNightNote,
    required this.showCash,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context)!;
    final dropoff = poi?.dropoff;
    final muted = TextStyle(fontSize: 12, height: 1.35, color: scheme.onSurfaceVariant);

    Widget row(IconData icon, Widget child, {Widget? trailing}) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 18, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(child: child),
              if (trailing != null) trailing,
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: scheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 17, color: scheme.primary),
              const SizedBox(width: 6),
              Text(l.tripInfoTitle.toUpperCase(),
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: scheme.primary)),
            ],
          ),
          row(
            Icons.calendar_month_rounded,
            Text('$dateLabel · $dayTypeLabel',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
          if (dropoff != null)
            row(
              Icons.pin_drop_rounded,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.recommendedStopTitle(dropoff.name),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(l.walkToPoiBanner(dropoff.walkMinutes),
                      style: muted.copyWith(fontWeight: FontWeight.w700)),
                  Text(l.recommendedStopNote, style: muted),
                ],
              ),
              trailing: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => launchUrl(
                  Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${dropoff.lat},${dropoff.lng}'),
                  mode: LaunchMode.externalApplication,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.map_rounded, color: scheme.primary),
                ),
              ),
            )
          else if (poi != null && poi!.walkMinutes > 0)
            row(
              Icons.directions_walk_rounded,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.walkToPoiBanner(poi!.walkMinutes),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  Text(l.walkFromStop(stopName), style: muted),
                ],
              ),
            ),
          if (showNightNote)
            row(Icons.nightlight_round, Text(l.nightMapsNote, style: muted)),
          if (showCash) ...[
            const SizedBox(height: 12),
            const CashOnlyNote(),
          ],
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
