class Stop {
  final String id;
  final String name;
  final String city;
  final double lat;
  final double lng;

  const Stop({
    required this.id,
    required this.name,
    required this.city,
    required this.lat,
    required this.lng,
  });

  factory Stop.fromJson(Map<String, dynamic> json) {
    return Stop(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
}
