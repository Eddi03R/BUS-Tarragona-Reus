import 'package:flutter/material.dart';
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
    final scheme = Theme.of(context).colorScheme;
    final minutes = result.travelTime.inMinutes;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlighted ? scheme.primary : Colors.white,
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
                  const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 4),
                  Text('Bus consigliato',
                      style: TextStyle(color: Colors.white.withOpacity(0.95), fontWeight: FontWeight.w700, fontSize: 13)),
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
                            color: highlighted ? Colors.white : scheme.onSurface)),
                    Text(originName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: highlighted ? Colors.white.withOpacity(0.85) : Colors.grey[600])),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(Icons.directions_bus_filled_rounded,
                      color: highlighted ? Colors.white : scheme.primary, size: 20),
                  const SizedBox(height: 2),
                  Text('$minutes min',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: highlighted ? Colors.white : Colors.grey[700])),
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
                            color: highlighted ? Colors.white : scheme.onSurface)),
                    Text(destinationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontSize: 12,
                            color: highlighted ? Colors.white.withOpacity(0.85) : Colors.grey[600])),
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
