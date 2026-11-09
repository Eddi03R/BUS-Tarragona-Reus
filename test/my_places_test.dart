import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/services/my_places_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('I miei posti: configurato solo con Casa e abituale diverse', () async {
    SharedPreferences.setMockInitialValues({});
    final c = MyPlacesController.instance;
    await c.load();
    await c.setHome(null);
    await c.setUsual(null);
    expect(c.configured, isFalse);

    await c.setHome('reus_centre');
    expect(c.configured, isFalse);

    await c.setUsual('reus_centre');
    expect(c.configured, isFalse, reason: 'stessa fermata: non ha senso');

    await c.setUsual('campus_sescelades');
    expect(c.configured, isTrue);
  });

  test('I miei posti: salvati e riletti al riavvio, rimovibili', () async {
    SharedPreferences.setMockInitialValues({});
    final c = MyPlacesController.instance;
    await c.setHome('reus_centre');
    await c.setUsual('campus_sescelades');

    await c.load();
    expect(c.homeStopId, 'reus_centre');
    expect(c.usualStopId, 'campus_sescelades');

    await c.setHome(null);
    await c.load();
    expect(c.homeStopId, isNull);
    expect(c.configured, isFalse);
  });
}
