import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/schedule_repository.dart';
import '../models/journey_result.dart';
import '../models/stop.dart';
import '../services/route_service.dart';
import 'map_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final Stop origin;
  final Stop destination;
  final JourneyResult result;
  final String dayTypeLabel;
  final String calendarId;

  const TripDetailScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.result,
    required this.dayTypeLabel,
    required this.calendarId,
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  List<LatLng>? _roadPoints;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Future<void> _loadRoute() async {
    final points = [
      LatLng(widget.origin.lat, widget.origin.lng),
      LatLng(widget.destination.lat, widget.destination.lng),
    ];
    final road = await RouteService.roadRoute(points);
    if (!mounted) return;
    setState(() => _roadPoints = road);
  }

  String _fmt(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = [
      LatLng(widget.origin.lat, widget.origin.lng),
      LatLng(widget.destination.lat, widget.destination.lng),
    ];
    final bounds = LatLngBounds.fromPoints(points);
    final polylinePoints = _roadPoints ?? points;

    return Scaffold(
      appBar: AppBar(title: const Text('Dettagli viaggio')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DA', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(widget.origin.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('A', style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.bold)),
                            Text(widget.destination.name,
                                textAlign: TextAlign.end,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_fmt(widget.result.departureTime),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Partenza', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.directions_bus_filled_rounded, color: Colors.white.withOpacity(0.9)),
                          const SizedBox(height: 2),
                          Text('${widget.result.travelTime.inMinutes} min',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w600)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_fmt(widget.result.arrivalTime),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                          Text('Arrivo', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Chip(icon: Icons.event_available_rounded, label: widget.dayTypeLabel),
                      _Chip(icon: Icons.route_rounded, label: widget.result.directionLabel),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Percorso sulla mappa',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    FlutterMap(
                      options: MapOptions(
                        initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(48)),
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.reus_tarragona_bus',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(points: polylinePoints, strokeWidth: 4, color: scheme.primary.withOpacity(0.8)),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: points[0],
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.green, size: 38,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)]),
                            ),
                            Marker(
                              point: points[1],
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 38,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: FloatingActionButton.small(
                        heroTag: 'expand_map',
                        onPressed: () {
                          final stops = ScheduleRepository.instance.stopsForCalendar(widget.calendarId);
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => MapScreen(
                              stops: stops,
                              highlightOriginId: widget.origin.id,
                              highlightDestinationId: widget.destination.id,
                            ),
                          ));
                        },
                        child: const Icon(Icons.open_in_full_rounded, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
