import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/stop.dart';
import '../services/calendar_resolver.dart';
import '../services/journey_planner.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/stop_selector.dart';
import 'map_screen.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = ScheduleRepository.instance;

  late Stop _origin;
  late Stop _destination;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  SearchMode _mode = SearchMode.departAfter;
  bool _forceHoliday = false;

  @override
  void initState() {
    super.initState();
    _origin = _repo.stopById('reus_ea');
    _destination = _repo.stopById('tarragona_ea');
  }

  DayType get _dayType =>
      _forceHoliday ? DayType.sunday : CalendarResolver.dayTypeFor(_date);

  String get _calendarId => CalendarResolver.calendarIdFor(_dayType);

  void _swap() {
    setState(() {
      final tmp = _origin;
      _origin = _destination;
      _destination = tmp;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  void _search() {
    if (_origin.id == _destination.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scegli due fermate diverse.')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(
        origin: _origin,
        destination: _destination,
        date: _date,
        time: _time,
        mode: _mode,
        calendarId: _calendarId,
        dayTypeLabel: CalendarResolver.labelFor(_dayType),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stops = _repo.stopsForCalendar(_calendarId);
    final dateLabel = DateFormat('EEEE d MMMM', 'it_IT').format(_date);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Reus',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Icon(Icons.sync_alt_rounded, size: 20, color: scheme.primary),
                          const SizedBox(width: 6),
                          Text('Tarragona',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('Linea e4 · Monbus', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.map_rounded),
                        tooltip: 'Mappa fermate',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MapScreen(stops: stops)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: 'Impostazioni',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.primary.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    StopSelectorField(
                      label: 'Partenza',
                      icon: Icons.trip_origin,
                      value: _origin,
                      options: stops,
                      onChanged: (s) => setState(() => _origin = s),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 32,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Divider(),
                          Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 1,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: _swap,
                              child: Padding(
                                padding: const EdgeInsets.all(6),
                                child: Icon(Icons.swap_vert_rounded, color: scheme.primary, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    StopSelectorField(
                      label: 'Arrivo',
                      icon: Icons.flag_rounded,
                      value: _destination,
                      options: stops,
                      onChanged: (s) => setState(() => _destination = s),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('Quando vuoi viaggiare?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ChipButton(
                      icon: Icons.calendar_month_rounded,
                      label: dateLabel,
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ChipButton(
                      icon: Icons.access_time_rounded,
                      label: _time.format(context),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SegmentedButton<SearchMode>(
                segments: const [
                  ButtonSegment(
                    value: SearchMode.departAfter,
                    label: Text('Parto dopo le'),
                    icon: Icon(Icons.north_east_rounded),
                  ),
                  ButtonSegment(
                    value: SearchMode.arriveBy,
                    label: Text('Arrivo entro le'),
                    icon: Icon(Icons.south_west_rounded),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _forceHoliday,
                onChanged: (v) => setState(() => _forceHoliday = v),
                title: const Text('Festivo (usa orario domenicale)'),
                subtitle: Text('Calendario applicato: ${CalendarResolver.labelFor(_dayType)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Trova il bus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChipButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
