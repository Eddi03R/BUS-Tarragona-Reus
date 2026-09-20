import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Calcola il tracciato stradale reale tra una sequenza di fermate usando
/// OSRM (Open Source Routing Machine, https://project-osrm.org), il
/// servizio demo pubblico e gratuito basato su OpenStreetMap: nessuna API
/// key richiesta. In caso di errore di rete restituisce null e la mappa
/// userà come riserva le linee rette tra le fermate.
class RouteService {
  RouteService._();

  static final Map<String, List<LatLng>> _cache = {};

  static Future<List<LatLng>?> roadRoute(List<LatLng> waypoints) async {
    if (waypoints.length < 2) return null;

    final key = waypoints.map((p) => '${p.latitude},${p.longitude}').join(';');
    if (_cache.containsKey(key)) return _cache[key];

    final coords = waypoints.map((p) => '${p.longitude},${p.latitude}').join(';');
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/$coords'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['code'] != 'Ok') return null;

      final routes = body['routes'] as List;
      if (routes.isEmpty) return null;

      final geometry = routes.first['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;
      final points = coordinates.map((c) {
        final pair = c as List;
        return LatLng((pair[1] as num).toDouble(), (pair[0] as num).toDouble());
      }).toList();

      _cache[key] = points;
      return points;
    } catch (_) {
      return null;
    }
  }
}
