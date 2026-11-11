import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import '../models/poi.dart';
import '../models/stop.dart';
import '../services/favorites_controller.dart';
import '../widgets/cash_note.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/thick_arrow.dart';
import '../widgets/trip_card.dart';

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

  // Servizio notturno dopo mezzanotte: orario del giorno civile successivo.
  bool _isNextDay(TimeOfDay t) => widget.calendarId.startsWith('night') && t.hour < 12;

  String _fmtDay(TimeOfDay t) => _isNextDay(t) ? '${_fmt(t)} +1' : _fmt(t);

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
    final d = widget.destinationPoi?.dropoff;
    final destLat = d?.lat ?? widget.destination.lat;
    final destLng = d?.lng ?? widget.destination.lng;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/${widget.origin.lat},${widget.origin.lng}/$destLat,$destLng',
    );
    launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _openDestinationOnMaps() {
    final Uri uri;
    if (widget.destinationPoi != null) {
      // Navigazione a piedi dalla fermata al POI
      final poi = widget.destinationPoi!;
      final d = poi.dropoff;
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${d?.lat ?? widget.destination.lat},${d?.lng ?? widget.destination.lng}'
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

    // Righe della lista fermate. Se il locale ha una fermata consigliata
    // (non presente nell'orario ufficiale) la inseriamo prima dell'ultima
    // fermata, con l'orario di quest'ultima come riferimento.
    final dropoff = widget.destinationPoi?.dropoff;
    final lastIdx = _servedStops.length - 1;
    final rows = <_StopRow>[
      for (var i = 0; i < _servedStops.length; i++) ...[
        if (i == lastIdx && dropoff != null)
          _StopRow(dropoff.name, widget.result.servedStops[i].time,
              _RowKind.alight, recommended: true, approx: true),
        _StopRow(
          _servedStops[i].name,
          widget.result.servedStops[i].time,
          i == 0
              ? _RowKind.origin
              : i == lastIdx
                  ? (dropoff != null ? _RowKind.middle : _RowKind.alight)
                  : _RowKind.middle,
        ),
      ],
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l.tripDetailsTitle),
        actions: [
          ListenableBuilder(
            listenable: FavoritesController.instance,
            builder: (context, _) {
              final night = widget.calendarId.startsWith('night');
              final poiId = widget.destinationPoi?.id;
              final isFav = FavoritesController.instance.isFavorite(
                  widget.origin.id, widget.destination.id,
                  night: night, poiId: poiId);
              return IconButton(
                icon: Icon(isFav ? Icons.star_rounded : Icons.star_outline_rounded),
                tooltip: isFav ? 'Rimuovi dai preferiti' : 'Aggiungi ai preferiti',
                onPressed: () => FavoritesController.instance.toggle(
                    widget.origin.id, widget.destination.id,
                    night: night, poiId: poiId),
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
      body: ChristmasBackdrop(child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ticket(context, l, scheme, isExpress),
            const SizedBox(height: 14),
            _alightCard(l, scheme),
            const SizedBox(height: 14),
            _infoCard(l, scheme),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_rounded),
                label: const Text('Segui il percorso su Google Maps'),
              ),
            ),
            const SizedBox(height: 22),
            Text(l.stopsOfThisTrip,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            _stopsList(l, scheme, rows),
          ],
        ),
      )),
    );
  }

  /// Biglietto grande: stessa grafica della corsa consigliata nei risultati.
  Widget _ticket(BuildContext context, AppLocalizations l, ColorScheme scheme, bool isExpress) {
    final fg = scheme.onPrimary;
    final soft = fg.withOpacity(0.8);
    String? operator;
    try {
      operator = ScheduleRepository.instance.calendar(widget.calendarId).operator;
    } catch (_) {}

    Widget side(String label, String name, String time, String caption, {required bool end}) {
      final align = end ? CrossAxisAlignment.end : CrossAxisAlignment.start;
      return Expanded(
        child: Column(
          crossAxisAlignment: align,
          children: [
            Text(label,
                style: TextStyle(color: soft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
            Text(name,
                textAlign: end ? TextAlign.end : TextAlign.start,
                style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 15, height: 1.2)),
          ],
        ),
      );
    }

    Widget timeCol(String time, String caption, {required bool end}) => Column(
          crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(time,
                style: TextStyle(
                    color: fg, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text(caption, style: TextStyle(color: soft, fontSize: 12)),
          ],
        );

    return Container(
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: scheme.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    side(l.fromLabel, widget.origin.name, '', '', end: false),
                    const SizedBox(width: 12),
                    side(l.toLabel, widget.destination.name, '', '', end: true),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: timeCol(_fmtDay(widget.result.departureTime), l.departureLabel,
                            end: false)),
                    ThickArrow(size: 26, color: fg),
                    Expanded(
                        child: timeCol(_fmtDay(widget.result.arrivalTime), l.arrivalLabel,
                            end: true)),
                  ],
                ),
              ],
            ),
          ),
          TicketPerforation(
            color: fg.withOpacity(0.35),
            notchColor: Theme.of(context).scaffoldBackgroundColor,
            size: 16,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 16),
            child: Row(
              children: [
                if (operator != null) OperatorBadge(operator: operator, highlighted: true),
                const Spacer(),
                Icon(Icons.directions_bus_filled_rounded, color: fg, size: 18),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${l.minutesAbbrev(widget.result.travelTime.inMinutes)} · '
                    '${isExpress ? l.direct : l.stopsCount(_servedStops.length)}',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// "Scendi a": unisce fermata di discesa e fermata consigliata (stesso nome).
  Widget _alightCard(AppLocalizations l, ColorScheme scheme) {
    final dropoff = widget.destinationPoi?.dropoff;
    final poi = widget.destinationPoi;
    final name = dropoff?.name ?? widget.destination.name;
    final walk = dropoff?.walkMinutes ?? ((poi?.walkMinutes ?? 0) > 0 ? poi!.walkMinutes : null);
    final red = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red.shade700;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.flag_rounded, color: red, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.alightAt.toUpperCase().replaceAll(':', ''),
                    style: TextStyle(
                        fontSize: 11.5, color: red, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                const SizedBox(height: 3),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, height: 1.25)),
                if (walk != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_walk_rounded, size: 14, color: scheme.onSurface),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            dropoff != null
                                ? '${_cap(l.recommendedLabel)} · ${l.walkToPoiBanner(walk)}'
                                : l.walkToPoiBanner(walk),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (dropoff != null) ...[
                  const SizedBox(height: 6),
                  Text(l.recommendedStopNote,
                      style: TextStyle(fontSize: 12, height: 1.35, color: scheme.onSurfaceVariant)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              widget.destinationPoi != null ? Icons.directions_walk_rounded : Icons.directions,
              color: red,
            ),
            tooltip: widget.destinationPoi != null
                ? 'A piedi a ${widget.destinationPoi!.name}'
                : 'Naviga alla fermata',
            onPressed: _openDestinationOnMaps,
          ),
        ],
      ),
    );
  }

  String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  /// Una sola scheda con calendario, percorso completo (a capo, senza "..."),
  /// nota sulle corse notturne e pagamento solo contanti.
  Widget _infoCard(AppLocalizations l, ColorScheme scheme) {
    final night = widget.calendarId.startsWith('night');
    final muted = TextStyle(fontSize: 12.5, height: 1.35, color: scheme.onSurfaceVariant);

    Widget row(IconData icon, Widget child) => Padding(
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
          row(Icons.event_available_rounded,
              Text(widget.dayTypeLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
          row(Icons.route_rounded,
              Text(widget.result.directionLabel,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.35))),
          if (night) row(Icons.nightlight_round, Text(l.nightMapsNote, style: muted)),
          if (night) ...[const SizedBox(height: 12), const CashOnlyNote()],
        ],
      ),
    );
  }

  /// Elenco fermate con linea verticale: partenza verde, discesa rossa.
  Widget _stopsList(AppLocalizations l, ColorScheme scheme, List<_StopRow> rows) {
    final red = Theme.of(context).brightness == Brightness.dark ? Colors.red.shade300 : Colors.red;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 22,
            bottom: 22,
            child: Container(width: 2, color: scheme.outlineVariant),
          ),
          Column(
            children: [
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 18,
                        child: Center(
                          child: r.kind == _RowKind.middle
                              ? Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                      color: scheme.onSurfaceVariant, shape: BoxShape.circle),
                                )
                              : Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: r.kind == _RowKind.alight
                                        ? red
                                        : Theme.of(context).cardColor,
                                    shape: BoxShape.circle,
                                    border: r.kind == _RowKind.origin
                                        ? Border.all(color: Colors.green, width: 3)
                                        : null,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r.name,
                                style: TextStyle(
                                    fontWeight: r.kind == _RowKind.middle
                                        ? FontWeight.normal
                                        : FontWeight.bold)),
                            if (r.kind == _RowKind.alight)
                              Text(
                                  r.recommended
                                      ? '${l.alightHere} · ${l.recommendedLabel}'
                                      : l.alightHere,
                                  style: TextStyle(
                                      fontSize: 11, color: red, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${r.approx ? '~' : ''}${_fmtDay(r.time)}',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _RowKind { origin, middle, alight }

class _StopRow {
  final String name;
  final TimeOfDay time;
  final _RowKind kind;
  final bool recommended;
  final bool approx;
  const _StopRow(this.name, this.time, this.kind,
      {this.recommended = false, this.approx = false});
}
