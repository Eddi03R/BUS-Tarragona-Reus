import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../models/journey_result.dart';

class TripCard extends StatelessWidget {
  final JourneyResult result;
  final bool highlighted;
  final String originName;
  final String destinationName;

  const TripCard({
    super.key,
    required this.result,
    required this.originName,
    required this.destinationName,
    this.highlighted = false,
  });

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final minutes = result.travelTime.inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primary : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: highlighted
            ? [BoxShadow(color: scheme.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (highlighted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(Icons.bolt_rounded, color: scheme.onPrimary, size: 18),
                  const SizedBox(width: 4),
                  Text(l.recommendedBus,
                      style: TextStyle(color: scheme.onPrimary.withOpacity(0.95), fontWeight: FontWeight.w700, fontSize: 13)),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_fmt(result.departureTime),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: highlighted ? scheme.onPrimary : scheme.onSurface)),
                    Text(originName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: highlighted ? scheme.onPrimary.withOpacity(0.85) : scheme.onSurfaceVariant)),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.directions_bus_filled_rounded,
                      color: highlighted ? scheme.onPrimary : scheme.primary, size: 20),
                  const SizedBox(height: 2),
                  Text(l.minutesAbbrev(minutes),
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: highlighted ? scheme.onPrimary : scheme.onSurfaceVariant)),
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(_fmt(result.arrivalTime),
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: highlighted ? scheme.onPrimary : scheme.onSurface)),
                    Text(destinationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 12,
                            color: highlighted ? scheme.onPrimary.withOpacity(0.85) : scheme.onSurfaceVariant)),
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
