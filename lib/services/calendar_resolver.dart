/// Determina quale calendario di orari applicare per una data specifica.
///
/// Nota: non gestisce automaticamente i giorni festivi infrasettimanali
/// (che in Catalogna seguono il calendario festivo locale). L'utente puo'
/// forzare manualmente il calendario "Domenica e festivi" dall'app. Il
/// servizio notturno è indipendente dal giorno e va attivato manualmente.
enum DayType { weekday, weekdayAugust, saturday, sunday }

class CalendarResolver {
  static DayType dayTypeFor(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday:
        return DayType.saturday;
      case DateTime.sunday:
        return DayType.sunday;
      default:
        return date.month == 8 ? DayType.weekdayAugust : DayType.weekday;
    }
  }

  static String calendarIdFor(DayType type) {
    switch (type) {
      case DayType.weekday:
        return 'weekday';
      case DayType.weekdayAugust:
        return 'weekday_august';
      case DayType.saturday:
        return 'saturday';
      case DayType.sunday:
        return 'sunday';
    }
  }

  static String labelFor(DayType type) {
    switch (type) {
      case DayType.weekday:
        return 'Feriale (Lun-Ven)';
      case DayType.weekdayAugust:
        return 'Feriale (agosto)';
      case DayType.saturday:
        return 'Sabato';
      case DayType.sunday:
        return 'Domenica / festivo';
    }
  }
}
