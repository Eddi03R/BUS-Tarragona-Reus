/// Tratta preferita. Daylife e Nightlife hanno liste separate ([night]); per i
/// locali si ricorda anche il luogo ([poiId]) per mostrare la fermata consigliata.
class FavoriteRoute {
  final String originId;
  final String destinationId;
  final bool night;
  final String? poiId;

  const FavoriteRoute({
    required this.originId,
    required this.destinationId,
    this.night = false,
    this.poiId,
  });

  // Formato: origin::destination::d|n::poiId  (i vecchi salvataggi hanno solo 2 parti = daylife)
  String encode() => '$originId::$destinationId::${night ? 'n' : 'd'}::${poiId ?? ''}';

  static FavoriteRoute? decode(String raw) {
    final parts = raw.split('::');
    if (parts.length < 2) return null;
    final poi = parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null;
    return FavoriteRoute(
      originId: parts[0],
      destinationId: parts[1],
      night: parts.length > 2 && parts[2] == 'n',
      poiId: poi,
    );
  }

  bool matches(String originId, String destinationId, bool night, String? poiId) =>
      this.originId == originId &&
      this.destinationId == destinationId &&
      this.night == night &&
      this.poiId == poiId;

  bool same(FavoriteRoute o) =>
      matches(o.originId, o.destinationId, o.night, o.poiId);
}
