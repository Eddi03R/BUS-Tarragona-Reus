import 'package:flutter_test/flutter_test.dart';
import 'package:reus_tarragona_bus/services/remote_notice.dart';

void main() {
  test('avviso: lingua, ripiego e valori vuoti', () {
    const raw = '{"id":"a","title":{"it":"Sciopero","en":"Strike"},"text":"Domani"}';
    final it = RemoteNotice.parse(raw, 'it')!;
    expect((it.id, it.title, it.text), ('a', 'Sciopero', 'Domani'));
    expect(RemoteNotice.parse(raw, 'de')!.title, 'Strike'); // ripiego su en
    expect(RemoteNotice.parse('', 'it'), isNull);
    expect(RemoteNotice.parse('non json', 'it'), isNull);
    expect(RemoteNotice.parse('{"title":"","text":""}', 'it'), isNull);
  });
}
