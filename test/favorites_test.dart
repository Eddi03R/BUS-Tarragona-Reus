import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/models/favorite_route.dart';
import 'package:reus_tarragona_bus/services/favorites_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoriteRoute', () {
    test('encode/decode con notte e luogo', () {
      const f = FavoriteRoute(
          originId: 'a', destinationId: 'b', night: true, poiId: 'tropical_salou');
      final d = FavoriteRoute.decode(f.encode())!;
      expect(d.originId, 'a');
      expect(d.destinationId, 'b');
      expect(d.night, isTrue);
      expect(d.poiId, 'tropical_salou');
    });

    test('vecchio formato (2 parti) = daylife senza luogo', () {
      final d = FavoriteRoute.decode('a::b')!;
      expect(d.night, isFalse);
      expect(d.poiId, isNull);
    });

    test('formato non valido', () {
      expect(FavoriteRoute.decode('solo-uno'), isNull);
    });
  });

  group('FavoritesController', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('liste separate per Daylife e Nightlife', () async {
      final c = FavoritesController.instance;
      await c.load();
      for (final f in List.of(c.items)) {
        await c.remove(f);
      }
      await c.toggle('reus', 'tarragona', night: false);
      await c.toggle('reus', 'pl_europa_salou', night: true, poiId: 'tropical_salou');

      expect(c.itemsFor(night: false).length, 1);
      expect(c.itemsFor(night: true).length, 1);
      expect(c.itemsFor(night: true).single.poiId, 'tropical_salou');
      expect(c.isFavorite('reus', 'tarragona', night: false), isTrue);
      expect(c.isFavorite('reus', 'tarragona', night: true), isFalse);
    });

    test('toggle due volte rimuove; i preferiti sopravvivono al riavvio', () async {
      final c = FavoritesController.instance;
      await c.load();
      for (final f in List.of(c.items)) {
        await c.remove(f);
      }
      await c.toggle('x', 'y', night: true);
      await c.toggle('x', 'y', night: true);
      expect(c.itemsFor(night: true), isEmpty);

      await c.toggle('x', 'y', night: true);
      await c.load(); // rilegge da SharedPreferences
      expect(c.itemsFor(night: true).length, 1);
    });
  });
}
