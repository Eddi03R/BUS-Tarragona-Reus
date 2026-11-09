import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

/// Determina quale calendario di orari applicare per una data e ora specifica.
enum DayType { weekday, weekdayAugust, saturday, sunday }

class CalendarResolver {
  /// Domenica di Pasqua (calendario gregoriano, algoritmo di Meeus/Jones/Butcher).
  static DateTime easterSunday(int year) {
    final a = year % 19;
    final b = year ~/ 100;
    final c = year % 100;
    final d = b ~/ 4;
    final e = b % 4;
    final f = (b + 8) ~/ 25;
    final g = (b - f + 1) ~/ 3;
    final h = (19 * a + b - d - g + 15) % 30;
    final i = c ~/ 4;
    final k = c % 4;
    final l = (32 + 2 * e + 2 * i - h - k) % 7;
    final m = (a + 11 * h + 22 * l) ~/ 451;
    final month = (h + l - 7 * m + 114) ~/ 31;
    final day = ((h + l - 7 * m + 114) % 31) + 1;
    return DateTime(year, month, day);
  }

  /// Festivi di tutta la Catalogna (si applica l'orario "Diumenges i festius").
  /// Non include le feste locali di Reus, Tarragona o Salou.
  static bool isHoliday(DateTime date) {
    final md = date.month * 100 + date.day;
    const fixed = {
      101, // Cap d'Any
      106, // Reis
      501, // Festa del Treball
      624, // Sant Joan
      815, // L'Assumpció
      911, // Diada de Catalunya
      1012, // Festa Nacional
      1101, // Tots Sants
      1206, // Constitució
      1208, // Immaculada
      1225, // Nadal
      1226, // Sant Esteve
    };
    if (fixed.contains(md)) return true;
    final easter = easterSunday(date.year);
    final day = DateTime(date.year, date.month, date.day);
    return day == easter.subtract(const Duration(days: 2)) || // Divendres Sant
        day == easter.add(const Duration(days: 1)); // Dilluns de Pasqua
  }

  static DayType dayTypeFor(DateTime date) {
    if (isHoliday(date)) return DayType.sunday;
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
