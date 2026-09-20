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

  bool isFavorite(String originId, String destinationId) =>
      _items.any((f) => f.matches(originId, destinationId));

  Future<void> toggle(String originId, String destinationId) async {
    if (isFavorite(originId, destinationId)) {
      _items.removeWhere((f) => f.matches(originId, destinationId));
    } else {
      _items.add(FavoriteRoute(originId: originId, destinationId: destinationId));
    }
    notifyListeners();
    await _persist();
  }

  Future<void> remove(FavoriteRoute route) async {
    _items.removeWhere((f) => f.matches(route.originId, route.destinationId));
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
