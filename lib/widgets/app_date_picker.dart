import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Selettore data personalizzato: settimana che parte da lunedì e con
/// sabato/domenica leggermente evidenziati (il DatePicker di Material non
/// permette di colorare i singoli giorni della settimana).
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showModalBottomSheet<DateTime>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => _CalendarSheet(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _CalendarSheet extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  const _CalendarSheet({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_CalendarSheet> createState() => _CalendarSheetState();
}

class _CalendarSheetState extends State<_CalendarSheet> {
  late DateTime _visibleMonth;
  late DateTime _selected;

  @override
  void initState() {
    super.initState();
    _selected = _dateOnly(widget.initialDate);
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelectable(DateTime day) {
    final firstOk = !day.isBefore(_dateOnly(widget.firstDate));
    final lastOk = !day.isAfter(_dateOnly(widget.lastDate));
    return firstOk && lastOk;
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekendColor = isDark ? Colors.orange[300]! : Colors.orange[800]!;
    final today = _dateOnly(DateTime.now());
    final localeName = Localizations.localeOf(context).languageCode;
    // Lunedì 1..7 domenica -> etichette brevi localizzate (2024-01-01 era lunedì).
    final weekdayLabels = [
      for (var i = 0; i < 7; i++)
        DateFormat.E(localeName).format(DateTime(2024, 1, 1 + i)).substring(0, 2),
    ];

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    // weekday: lunedì=1 ... domenica=7 -> colonna 0-based da lunedì
    final leadingBlanks = firstOfMonth.weekday - 1;
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;

    final canGoPrev = DateTime(_visibleMonth.year, _visibleMonth.month - 1)
        .isAfter(DateTime(widget.firstDate.year, widget.firstDate.month - 1));
    final canGoNext = DateTime(_visibleMonth.year, _visibleMonth.month + 1)
        .isBefore(DateTime(widget.lastDate.year, widget.lastDate.month + 1));

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: canGoPrev ? () => _changeMonth(-1) : null,
              ),
              Text(
                _capitalize(DateFormat('MMMM yyyy', localeName).format(_visibleMonth)),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: canGoNext ? () => _changeMonth(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < 7; i++)
                Expanded(
                  child: Center(
                    child: Text(
                      weekdayLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: i >= 5 ? weekendColor : scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();

              final dayNum = index - leadingBlanks + 1;
              final date = DateTime(_visibleMonth.year, _visibleMonth.month, dayNum);
              final weekday = date.weekday; // 1=lun ... 7=dom
              final isWeekend = weekday == DateTime.saturday || weekday == DateTime.sunday;
              final selectable = _isSelectable(date);
              final isSelected = _isSameDay(date, _selected);
              final isToday = _isSameDay(date, today);

              return Padding(
                padding: const EdgeInsets.all(2),
                child: Material(
                  color: isSelected
                      ? scheme.primary
                      : isWeekend
                          ? Colors.orange.withOpacity(0.08)
                          : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: (isToday && !isSelected)
                        ? BorderSide(color: scheme.primary, width: 1.2)
                        : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: selectable ? () => Navigator.of(context).pop(date) : null,
                    child: Center(
                      child: Text(
                        '$dayNum',
                        style: TextStyle(
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                          color: !selectable
                              ? scheme.onSurface.withOpacity(0.3)
                              : isSelected
                                  ? scheme.onPrimary
                                  : isWeekend
                                      ? weekendColor
                                      : scheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
