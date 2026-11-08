import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_route.dart';

/// Tratte preferite (partenza+arrivo) salvate dall'utente, persistite localmente.
class FavoritesController extends ChangeNotifier {
  FavoritesController._();
  static final FavoritesController instance = FavoritesController._();

  static const _prefKey = 'favorite_routes';

  List<FavoriteRoute> _items = [];
  List<FavoriteRoute> get items => List.unmodifiable(_items);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_prefKey) ?? [];
      _items = raw.map(FavoriteRoute.decode).whereType<FavoriteRoute>().toList();
    } catch (_) {
      // Storage non disponibile: si resta senza preferiti.
    }
    notifyListeners();
  }

  /// Preferiti di Daylife (night = false) o di Nightlife (night = true).
  List<FavoriteRoute> itemsFor({required bool night}) =>
      _items.where((f) => f.night == night).toList();

  bool isFavorite(String originId, String destinationId,
          {required bool night, String? poiId}) =>
      _items.any((f) => f.matches(originId, destinationId, night, poiId));

  Future<void> toggle(String originId, String destinationId,
      {required bool night, String? poiId}) async {
    if (isFavorite(originId, destinationId, night: night, poiId: poiId)) {
      _items.removeWhere((f) => f.matches(originId, destinationId, night, poiId));
    } else {
      _items.add(FavoriteRoute(
          originId: originId, destinationId: destinationId, night: night, poiId: poiId));
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(FavoriteRoute route) async {
    _items.removeWhere(route.same);
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefKey, _items.map((f) => f.encode()).toList());
    } catch (_) {
      // Persistenza best-effort.
    }
  }
}
