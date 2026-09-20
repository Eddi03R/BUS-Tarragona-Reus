import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/stop.dart';
import '../services/route_service.dart';

class MapScreen extends StatefulWidget {
  final List<Stop> stops;
  final String? highlightOriginId;
  final String? highlightDestinationId;

  const MapScreen({
    super.key,
    required this.stops,
    this.highlightOriginId,
    this.highlightDestinationId,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _mapController = MapController();
  Stop? _selected;
  List<LatLng>? _roadPoints;
  bool _loadingRoute = true;

  @override
  void initState() {
    super.initState();
    _loadRoadRoute();
  }

  Future<void> _loadRoadRoute() async {
    final waypoints = widget.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    final road = await RouteService.roadRoute(waypoints);
    if (!mounted) return;
    setState(() {
      _roadPoints = road;
      _loadingRoute = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final points = widget.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    final polylinePoints = _roadPoints ?? points;

    return Scaffold(
      appBar: AppBar(title: const Text('Fermate della linea')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(48),
              ),
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.reus_tarragona_bus',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylinePoints,
                    strokeWidth: 4,
                    color: scheme.primary.withOpacity(_roadPoints != null ? 0.75 : 0.4),
                  ),
                ],
              ),
              MarkerLayer(
                markers: widget.stops.map((s) {
                  final isOrigin = s.id == widget.highlightOriginId;
                  final isDestination = s.id == widget.highlightDestinationId;
                  final color = isOrigin
                      ? Colors.green
                      : isDestination
                          ? Colors.red
                          : scheme.primary;
                  return Marker(
                    point: LatLng(s.lat, s.lng),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = s),
                      child: Icon(
                        (isOrigin || isDestination) ? Icons.location_on : Icons.location_on_outlined,
                        color: color,
                        size: (isOrigin || isDestination) ? 38 : 30,
                        shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          if (_loadingRoute)
            Positioned(
              top: 12,
              left: 12,
              child: _StatusPill(
                icon: Icons.route_rounded,
                label: 'Calcolo percorso su strada…',
                showSpinner: true,
              ),
            )
          else if (_roadPoints == null)
            Positioned(
              top: 12,
              left: 12,
              child: _StatusPill(
                icon: Icons.info_outline_rounded,
                label: 'Percorso su strada non disponibile, mostro linee dirette',
              ),
            ),
          if (_selected != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.directions_bus_filled_rounded, color: scheme.primary),
                  title: Text(_selected!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(_selected!.city),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selected = null),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool showSpinner;
  const _StatusPill({required this.icon, required this.label, this.showSpinner = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSpinner)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
