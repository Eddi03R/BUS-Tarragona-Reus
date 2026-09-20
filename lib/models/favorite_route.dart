class FavoriteRoute {
  final String originId;
  final String destinationId;

  const FavoriteRoute({required this.originId, required this.destinationId});

  String encode() => '$originId::$destinationId';

  static FavoriteRoute? decode(String raw) {
    final parts = raw.split('::');
    if (parts.length != 2) return null;
    return FavoriteRoute(originId: parts[0], destinationId: parts[1]);
  }

  bool matches(String originId, String destinationId) =>
      this.originId == originId && this.destinationId == destinationId;
}
