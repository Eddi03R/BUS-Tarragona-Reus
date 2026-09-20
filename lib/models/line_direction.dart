/// Un servizio orario per una singola direzione (es. Reus -> Tarragona)
/// in un determinato calendario (feriale / sabato / domenica).
class LineDirection {
  final String code; // "RT" oppure "TR"
  final String label;
  final List<String> stopIds; // ordine di percorrenza delle fermate
  final List<List<String>> trips; // ogni riga: orario per fermata, "-" se non ferma

  const LineDirection({
    required this.code,
    required this.label,
    required this.stopIds,
    required this.trips,
  });

  factory LineDirection.fromJson(String code, Map<String, dynamic> json) {
    return LineDirection(
      code: code,
      label: json['label'] as String,
      stopIds: (json['stops'] as List).cast<String>(),
      trips: (json['trips'] as List)
          .map((row) => (row as List).cast<String>())
          .toList(),
    );
  }

  int indexOfStop(String stopId) => stopIds.indexOf(stopId);
}

class Calendar {
  final String id;
  final String label;
  final Map<String, LineDirection> directions; // "RT" / "TR"

  const Calendar({
    required this.id,
    required this.label,
    required this.directions,
  });

  factory Calendar.fromJson(Map<String, dynamic> json) {
    final dirsJson = json['directions'] as Map<String, dynamic>;
    return Calendar(
      id: json['calendarId'] as String,
      label: json['label'] as String,
      directions: dirsJson.map(
        (code, value) => MapEntry(
          code,
          LineDirection.fromJson(code, value as Map<String, dynamic>),
        ),
      ),
    );
  }
}
