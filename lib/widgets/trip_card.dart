import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import 'thick_arrow.dart';

/// Corsa a forma di biglietto: orari e fermate in alto, taglio tratteggiato con
/// le due tacche laterali, poi operatore, durata ed eventuale "ultimo bus".
/// [highlighted] = corsa consigliata (grande, a tinta piena); le altre sono
/// più compatte, con la stessa grafica e caratteri un po' più piccoli.
class TripCard extends StatelessWidget {
  final JourneyResult result;
  final bool highlighted;
  final bool isLast;
  final String originName;
  final String destinationName;
  final String? calendarId;

  const TripCard({
    super.key,
    required this.result,
    required this.originName,
    required this.destinationName,
    this.highlighted = false,
    this.isLast = false,
    this.calendarId,
  });

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  // Servizio notturno dopo mezzanotte: l'orario appartiene al giorno
  // civile successivo rispetto a quello di ricerca (es. "ven" 00:30 è
  // in realtà sabato mattina).
  bool _isNextDay(TimeOfDay t) =>
      (calendarId?.startsWith('night') ?? false) && t.hour < 12;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final minutes = result.travelTime.inMinutes;
    final big = highlighted;

    final fg = big ? scheme.onPrimary : scheme.onSurface;
    final fgSoft = big ? scheme.onPrimary.withOpacity(0.85) : scheme.onSurfaceVariant;
    final bg = big ? scheme.primary : Theme.of(context).cardColor;
    final timeSize = big ? 30.0 : 22.0;
    final nameSize = big ? 12.0 : 11.0;

    String? operator;
    if (calendarId != null) {
      try {
        operator = ScheduleRepository.instance.calendar(calendarId!).operator;
      } catch (_) {}
    }

    Widget time(TimeOfDay t, {required bool end}) => Column(
          crossAxisAlignment: end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text.rich(TextSpan(
              text: _fmt(t),
              style: TextStyle(
                  fontSize: timeSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: fg),
              children: _isNextDay(t)
                  ? [
                      TextSpan(
                          text: ' +1',
                          style: TextStyle(
                              fontSize: big ? 13 : 11,
                              fontWeight: FontWeight.w600,
                              color: fgSoft))
                    ]
                  : null,
            )),
            Text(end ? destinationName : originName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: end ? TextAlign.end : TextAlign.start,
                style: TextStyle(fontSize: nameSize, color: fgSoft)),
          ],
        );

    final pad = big ? 16.0 : 12.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(big ? 22 : 18),
        boxShadow: big
            ? [
                BoxShadow(
                    color: scheme.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6))
              ]
            : null,
      ),
      // Le tacche del biglietto escono dal bordo: il Container le ritaglia.
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, big ? 6 : 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (big)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: fg, size: 18),
                        const SizedBox(width: 4),
                        Text(l.recommendedBus,
                            style: TextStyle(
                                color: fg.withOpacity(0.95),
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
                      ],
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: time(result.departureTime, end: false)),
                    Padding(
                      padding: EdgeInsets.only(top: big ? 8 : 5),
                      child: ThickArrow(size: big ? 24 : 18, color: fg),
                    ),
                    Expanded(child: time(result.arrivalTime, end: true)),
                  ],
                ),
              ],
            ),
          ),
          TicketPerforation(
            color: fg.withOpacity(0.35),
            notchColor: Theme.of(context).scaffoldBackgroundColor,
            size: big ? 16 : 12,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(pad, 2, pad, pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (operator != null)
                      OperatorBadge(operator: operator, highlighted: big),
                    const Spacer(),
                    Icon(Icons.directions_bus_filled_rounded,
                        color: big ? scheme.onPrimary : scheme.primary,
                        size: big ? 18 : 16),
                    const SizedBox(width: 5),
                    Text(l.minutesAbbrev(minutes),
                        style: TextStyle(
                            fontSize: big ? 13 : 12,
                            fontWeight: FontWeight.w700,
                            color: big ? scheme.onPrimary : scheme.onSurfaceVariant)),
                  ],
                ),
                if (isLast) ...[
                  const SizedBox(height: 6),
                  _LastBusBadge(highlighted: big),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Taglio del biglietto: linea tratteggiata con mezzo cerchio ai due lati.
class TicketPerforation extends StatelessWidget {
  final Color color;
  final Color notchColor;
  final double size;
  const TicketPerforation({required this.color, required this.notchColor, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -size / 2,
            top: 0,
            child: _dot(),
          ),
          Positioned(
            right: -size / 2,
            top: 0,
            child: _dot(),
          ),
          Positioned.fill(
            left: size,
            right: size,
            child: CustomPaint(painter: _DashPainter(color)),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: notchColor, shape: BoxShape.circle),
      );
}

class _DashPainter extends CustomPainter {
  final Color color;
  _DashPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    final y = s.height / 2;
    for (double x = 0; x < s.width; x += 9) {
      canvas.drawLine(Offset(x, y), Offset((x + 4.5).clamp(0, s.width), y), p);
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) => old.color != color;
}

class _LastBusBadge extends StatelessWidget {
  final bool highlighted;
  const _LastBusBadge({required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = highlighted
        ? Colors.white
        : (dark ? Colors.red.shade300 : Colors.red.shade700);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(Icons.warning_amber_rounded, size: 14, color: baseColor.withOpacity(0.9)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            l.lastBusBadge,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: baseColor.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }
}

class OperatorBadge extends StatelessWidget {
  final String operator;
  final bool highlighted;
  const OperatorBadge({required this.operator, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isPlana = operator == 'plana';
    final label = isPlana ? 'PLANA' : 'MONBUS';
    final bgColor = isPlana
        ? (highlighted ? Colors.white.withOpacity(0.2) : Colors.orange.shade50)
        : (highlighted
            ? Colors.white.withOpacity(0.2)
            : scheme.primaryContainer);
    final textColor = isPlana
        ? (highlighted ? Colors.white : Colors.orange.shade800)
        : (highlighted ? Colors.white : scheme.onPrimaryContainer);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.5)),
    );
  }
}
