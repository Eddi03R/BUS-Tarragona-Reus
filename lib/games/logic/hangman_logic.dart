import 'dart:math';

/// Impiccato: parole (senza accenti, solo A-Z) nelle cinque lingue dell'app.
const Map<String, List<String>> hangmanWords = {
  'it': ['AUTOBUS', 'FERMATA', 'BIGLIETTO', 'STAZIONE', 'ORARIO', 'VIAGGIO', 'SPIAGGIA', 'UNIVERSITA', 'STUDENTE', 'ERASMUS', 'PIAZZA', 'VALIGIA', 'ZAINO', 'FESTA', 'MUSEO', 'ANFITEATRO', 'CATALOGNA', 'SPAGNA', 'PAELLA', 'SEMAFORO', 'BICICLETTA', 'PASSEGGERO', 'AUTISTA', 'CAPOLINEA', 'LIBRERIA', 'AEROPORTO', 'PASSAPORTO', 'TRAMONTO', 'CASTELLO', 'AMICIZIA'],
  'en': ['STATION', 'TICKET', 'TIMETABLE', 'JOURNEY', 'BEACH', 'STUDENT', 'EXCHANGE', 'SUITCASE', 'BACKPACK', 'MUSEUM', 'AMPHITHEATRE', 'SPAIN', 'CATALONIA', 'DRIVER', 'PASSENGER', 'AIRPORT', 'PASSPORT', 'UNIVERSITY', 'CAMPUS', 'LIBRARY', 'FESTIVAL', 'SUNSHINE', 'HOLIDAY', 'TRAVELLER', 'BICYCLE', 'STREET', 'SQUARE', 'HARBOUR', 'TOURIST', 'FRIENDSHIP'],
  'es': ['AUTOBUS', 'PARADA', 'BILLETE', 'ESTACION', 'HORARIO', 'VIAJE', 'PLAYA', 'ESTUDIANTE', 'ERASMUS', 'CIUDAD', 'MALETA', 'MOCHILA', 'MUSEO', 'ANFITEATRO', 'CONDUCTOR', 'PASAJERO', 'AEROPUERTO', 'PASAPORTE', 'UNIVERSIDAD', 'BIBLIOTECA', 'FIESTA', 'VERANO', 'BICICLETA', 'CALLE', 'PLAZA', 'PUERTO', 'TURISTA', 'AMISTAD', 'SEMAFORO', 'PAELLA'],
  'ca': ['AUTOBUS', 'PARADA', 'BITLLET', 'ESTACIO', 'HORARI', 'VIATGE', 'PLATJA', 'ESTUDIANT', 'ERASMUS', 'CIUTAT', 'MALETA', 'MOTXILLA', 'MUSEU', 'ANFITEATRE', 'CATALUNYA', 'CONDUCTOR', 'PASSATGER', 'AEROPORT', 'PASSAPORT', 'UNIVERSITAT', 'BIBLIOTECA', 'FESTA', 'ESTIU', 'BICICLETA', 'CARRER', 'PLACA', 'TURISTA', 'AMISTAT', 'SEMAFOR', 'CASTELL'],
  'de': ['HALTESTELLE', 'FAHRKARTE', 'BAHNHOF', 'FAHRPLAN', 'REISE', 'STRAND', 'STUDENT', 'AUSTAUSCH', 'KOFFER', 'RUCKSACK', 'MUSEUM', 'SPANIEN', 'KATALONIEN', 'FAHRER', 'PASSAGIER', 'FLUGHAFEN', 'REISEPASS', 'BIBLIOTHEK', 'FEST', 'SOMMER', 'FAHRRAD', 'STRASSE', 'PLATZ', 'HAFEN', 'TOURIST', 'FREUNDSCHAFT', 'AMPHITHEATER', 'SONNE', 'FRUEHLING', 'CAMPUS'],
};

class HangmanLogic {
  /// Errori consentiti per difficoltà (0 facile … 2 difficile).
  static int maxWrong(int d) => const [8, 7, 6][d];

  /// Una parola per la lingua [lang] (se manca, inglese): facile = corte,
  /// medio = qualunque, difficile = lunghe.
  static String pick(String lang, int d, Random r) {
    final all = hangmanWords[lang] ?? hangmanWords['en']!;
    final fit = all.where((w) => switch (d) { 0 => w.length <= 7, 1 => w.length >= 6 && w.length <= 9, _ => w.length >= 8 }).toList();
    final list = fit.isEmpty ? all : fit;
    return list[r.nextInt(list.length)];
  }

  /// Tasti sbagliati già cancellati all'inizio: facile circa la metà delle lettere
  /// che non sono nella parola, medio circa un quarto, difficile nessuna.
  static Set<String> eliminated(String word, int d, Random r) {
    final wrong = [for (var i = 0; i < 26; i++) String.fromCharCode(65 + i)].where((c) => !word.contains(c)).toList()..shuffle(r);
    return wrong.take((wrong.length * const [0.5, 0.25, 0.0][d]).floor()).toSet();
  }

  static bool won(String word, Set<String> guessed) => word.split('').every(guessed.contains);
}
