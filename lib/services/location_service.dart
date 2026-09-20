import 'package:geolocator/geolocator.dart';
import '../models/stop.dart';

/// Trova la fermata più vicina alla posizione dell'utente, se il permesso di
/// geolocalizzazione viene concesso. Fallisce silenziosamente (torna null) se
/// il permesso è negato, il servizio è disattivato o scade il timeout: la
/// selezione manuale della fermata resta sempre disponibile.
class LocationService {
  LocationService._();

  static Future<Stop?> nearestStop(List<Stop> stops) async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );

      Stop? nearest;
      var bestDistance = double.infinity;
      for (final stop in stops) {
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          stop.lat,
          stop.lng,
        );
        if (distance < bestDistance) {
          bestDistance = distance;
          nearest = stop;
        }
      }
      return nearest;
    } catch (_) {
      return null;
    }
  }
}
