import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

/// Determina quale calendario di orari applicare per una data e ora specifica.
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

  static String calendarIdForDateTime(DateTime dateTime) {
    final mins = dateTime.hour * 60 + dateTime.minute;
    if (mins >= 1380 || mins < 450) return 'night';
    return calendarIdFor(dayTypeFor(dateTime));
  }

  /// NT2 (Reus–Salou) runs Jul–Aug every night; Sep–Jun Fri+Sat nights only.
  static bool isNightSalouAvailable(DateTime dateTime) {
    if (dateTime.month >= 7 && dateTime.month <= 8) return true;
    final mins = dateTime.hour * 60 + dateTime.minute;
    final nightDate =
        mins < 450 ? dateTime.subtract(const Duration(days: 1)) : dateTime;
    return nightDate.weekday == DateTime.friday ||
        nightDate.weekday == DateTime.saturday;
  }

  /// NT3 (Tarragona–Salou circolare) gira tutto l'anno, solo ven+sab notte.
  static bool isNightNt3Available(DateTime dateTime) {
    final mins = dateTime.hour * 60 + dateTime.minute;
    final nightDate =
        mins < 450 ? dateTime.subtract(const Duration(days: 1)) : dateTime;
    return nightDate.weekday == DateTime.friday ||
        nightDate.weekday == DateTime.saturday;
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
