import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/stop.dart';
import '../services/route_service.dart';

/// Fermate sempre evidenziate nella mappa generica (nessun viaggio
/// specifico selezionato) perché sono i punti di riferimento più cercati:
/// la Facoltà di Economia a Reus e la stazione di Tarragona.
const _anchorStopIds = {'fac_econ_urv', 'tarragona_ea'};

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
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final points = widget.stops.map((s) => LatLng(s.lat, s.lng)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    final polylinePoints = _roadPoints ?? points;

    return Scaffold(
      appBar: AppBar(title: Text(l.lineStopsTitle)),
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
                  final isGenericView = widget.highlightOriginId == null && widget.highlightDestinationId == null;
                  final isAnchor = isGenericView && _anchorStopIds.contains(s.id);
                  final color = isOrigin
                      ? Colors.green
                      : isDestination
                          ? Colors.red
                          : isAnchor
                              ? Colors.blue[700]!
                              : scheme.primary;
                  final emphasized = isOrigin || isDestination || isAnchor;

                  final pin = Icon(
                    emphasized ? Icons.location_on : Icons.location_on_outlined,
                    color: color,
                    size: emphasized ? 38 : 30,
                    shadows: const [Shadow(color: Colors.black26, blurRadius: 4)],
                  );

                  return Marker(
                    point: LatLng(s.lat, s.lng),
                    width: isAnchor ? 120 : 40,
                    height: isAnchor ? 58 : 40,
                    alignment: isAnchor ? Alignment.topCenter : Alignment.center,
                    child: GestureDetector(
                      onTap: () => setState(() => _selected = s),
                      child: isAnchor
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                pin,
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                  ),
                                  child: Text(
                                    s.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                                  ),
                                ),
                              ],
                            )
                          : pin,
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
                label: l.calculatingRoute,
                showSpinner: true,
              ),
            )
          else if (_roadPoints == null)
            Positioned(
              top: 12,
              left: 12,
              child: _StatusPill(
                icon: Icons.info_outline_rounded,
                label: l.routeUnavailable,
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
