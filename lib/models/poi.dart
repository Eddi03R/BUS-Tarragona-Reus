/// Fermata consigliata dove scendere per raggiungere il POI, quando il bus
/// ferma in un punto che non compare nell'orario ufficiale.
class PoiDropoff {
  final String name;
  final double lat;
  final double lng;
  final int walkMinutes;
  const PoiDropoff({
    required this.name,
    required this.lat,
    required this.lng,
    required this.walkMinutes,
  });

  factory PoiDropoff.fromJson(Map<String, dynamic> json) => PoiDropoff(
        name: json['name'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        walkMinutes: json['walkMinutes'] as int,
      );
}

class Poi {
  final String id;
  final String name;
  final String category;
  final String nearestStopId;
  final String? returnStopId;
  final int walkMinutes;
  final double lat;
  final double lng;
  final PoiDropoff? dropoff;

  const Poi({
    required this.id,
    required this.name,
    required this.category,
    required this.nearestStopId,
    this.returnStopId,
    required this.walkMinutes,
    required this.lat,
    required this.lng,
    this.dropoff,
  });

  factory Poi.fromJson(Map<String, dynamic> json) {
    return Poi(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      nearestStopId: json['nearestStopId'] as String,
      returnStopId: json['returnStopId'] as String?,
      walkMinutes: json['walkMinutes'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      dropoff: json['dropoff'] == null
          ? null
          : PoiDropoff.fromJson(json['dropoff'] as Map<String, dynamic>),
    );
  }

  bool get isNightlife => category == 'nightlife';
  bool get isUniversity => category == 'university';
}
