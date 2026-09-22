import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

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

  static String labelFor(AppLocalizations l, DayType type) {
    switch (type) {
      case DayType.weekday:
        return l.calWeekday;
      case DayType.weekdayAugust:
        return l.calWeekdayAugust;
      case DayType.saturday:
        return l.calSaturday;
      case DayType.sunday:
        return l.calSundayHoliday;
    }
  }
}
