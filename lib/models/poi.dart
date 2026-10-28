class Poi {
  final String id;
  final String name;
  final String category;
  final String nearestStopId;
  final String? returnStopId;
  final int walkMinutes;
  final double lat;
  final double lng;

  const Poi({
    required this.id,
    required this.name,
    required this.category,
    required this.nearestStopId,
    this.returnStopId,
    required this.walkMinutes,
    required this.lat,
    required this.lng,
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
    );
  }

  bool get isNightlife => category == 'nightlife';
  bool get isUniversity => category == 'university';
}
