/// Puzzle "Connessioni": 16 parole in 4 gruppi da 4. Le parole sono nomi propri
/// uguali in tutte le lingue; cambia solo il titolo del gruppo.
class ConnGroup {
  final Map<String, String> title; // it, en, es, ca, de
  final List<String> words;
  const ConnGroup(this.title, this.words);
  String titleFor(String lang) => title[lang] ?? title['en']!;
}

class ConnPuzzle {
  final List<ConnGroup> groups;
  const ConnPuzzle(this.groups);
}

const List<ConnPuzzle> connPuzzles = [
  ConnPuzzle([
    ConnGroup({
      'it': 'Fiumi catalani', 'en': 'Catalan rivers', 'es': 'Ríos catalanes',
      'ca': 'Rius catalans', 'de': 'Katalanische Flüsse',
    }, ['Ebre', 'Segre', 'Ter', 'Llobregat']),
    ConnGroup({
      'it': 'Bestie di Santa Tecla', 'en': 'Santa Tecla beasts', 'es': 'Bestias de Santa Tecla',
      'ca': 'Bèsties de Santa Tecla', 'de': 'Tiere der Santa Tecla',
    }, ['Àliga', 'Drac', 'Mulassa', 'Lleó']),
    ConnGroup({
      'it': 'Parti di un castell', 'en': 'Parts of a castell', 'es': 'Partes de un castell',
      'ca': 'Parts d\'un castell', 'de': 'Teile eines Castells',
    }, ['Pinya', 'Tronc', 'Enxaneta', 'Folre']),
    ConnGroup({
      'it': 'Artisti catalani', 'en': 'Catalan artists', 'es': 'Artistas catalanes',
      'ca': 'Artistes catalans', 'de': 'Katalanische Künstler',
    }, ['Dalí', 'Miró', 'Tàpies', 'Gaudí']),
  ]),
  ConnPuzzle([
    ConnGroup({
      'it': 'Città catalane', 'en': 'Catalan cities', 'es': 'Ciudades catalanas',
      'ca': 'Ciutats catalanes', 'de': 'Katalanische Städte',
    }, ['Girona', 'Lleida', 'Reus', 'Manresa']),
    ConnGroup({
      'it': 'Città spagnole', 'en': 'Spanish cities', 'es': 'Ciudades españolas',
      'ca': 'Ciutats espanyoles', 'de': 'Spanische Städte',
    }, ['Sevilla', 'Bilbao', 'Valencia', 'Zaragoza']),
    ConnGroup({
      'it': 'Cibi tipici', 'en': 'Typical foods', 'es': 'Comidas típicas',
      'ca': 'Menjars típics', 'de': 'Typische Speisen',
    }, ['Paella', 'Gazpacho', 'Tortilla', 'Pa amb tomàquet']),
    ConnGroup({
      'it': 'Costa Daurada', 'en': 'Costa Daurada', 'es': 'Costa Daurada',
      'ca': 'Costa Daurada', 'de': 'Costa Daurada',
    }, ['Salou', 'Cambrils', 'Altafulla', 'Torredembarra']),
  ]),
  ConnPuzzle([
    ConnGroup({
      'it': 'Monumenti romani di Tarragona', 'en': 'Roman monuments of Tarragona',
      'es': 'Monumentos romanos de Tarragona', 'ca': 'Monuments romans de Tarragona',
      'de': 'Römische Denkmäler in Tarragona',
    }, ['Amfiteatre', 'Circ', 'Pretori', 'Necròpolis']),
    ConnGroup({
      'it': 'Monasteri', 'en': 'Monasteries', 'es': 'Monasterios',
      'ca': 'Monestirs', 'de': 'Klöster',
    }, ['Poblet', 'Montserrat', 'Santes Creus', 'Ripoll']),
    ConnGroup({
      'it': 'Montagne', 'en': 'Mountains', 'es': 'Montañas',
      'ca': 'Muntanyes', 'de': 'Berge',
    }, ['Teide', 'Aneto', 'Mulhacén', 'Montseny']),
    ConnGroup({
      'it': 'Feste', 'en': 'Festivals', 'es': 'Fiestas',
      'ca': 'Festes', 'de': 'Feste',
    }, ['Santa Tecla', 'Sant Jordi', 'La Mercè', 'Sant Joan']),
  ]),
  ConnPuzzle([
    ConnGroup({
      'it': 'Isole', 'en': 'Islands', 'es': 'Islas', 'ca': 'Illes', 'de': 'Inseln',
    }, ['Mallorca', 'Menorca', 'Eivissa', 'Formentera']),
    ConnGroup({
      'it': 'Pittori spagnoli', 'en': 'Spanish painters', 'es': 'Pintores españoles',
      'ca': 'Pintors espanyols', 'de': 'Spanische Maler',
    }, ['Picasso', 'Goya', 'Velázquez', 'Sorolla']),
    ConnGroup({
      'it': 'Fiumi spagnoli', 'en': 'Spanish rivers', 'es': 'Ríos españoles',
      'ca': 'Rius espanyols', 'de': 'Spanische Flüsse',
    }, ['Tajo', 'Duero', 'Guadalquivir', 'Guadiana']),
    ConnGroup({
      'it': 'Dolci tipici', 'en': 'Typical sweets', 'es': 'Dulces típicos',
      'ca': 'Dolços típics', 'de': 'Typische Süßspeisen',
    }, ['Crema catalana', 'Turrón', 'Churros', 'Ensaïmada']),
  ]),
];
