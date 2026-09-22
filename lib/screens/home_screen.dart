import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../data/schedule_repository.dart';
import '../models/favorite_route.dart';
import '../models/stop.dart';
import '../services/calendar_resolver.dart';
import '../services/favorites_controller.dart';
import '../services/journey_planner.dart';
import '../services/location_service.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/subscription_banner.dart';
import '../widgets/next_bus_card.dart';
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
  final _favorites = FavoritesController.instance;

  late Stop _origin;
  late Stop _destination;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  SearchMode _mode = SearchMode.departAfter;
  bool _forceHoliday = false;
  bool _forceNight = false;

  @override
  void initState() {
    super.initState();
    _origin = _repo.stopById('reus_ea');
    _destination = _repo.stopById('tarragona_ea');
    _favorites.addListener(_onFavoritesChanged);
    _tryAutoSelectNearestStop();
  }

  @override
  void dispose() {
    _favorites.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _tryAutoSelectNearestStop() async {
    final nearest = await LocationService.nearestStop(_repo.stops);
    if (nearest != null && mounted) {
      setState(() => _origin = nearest);
    }
  }

  DayType get _dayType =>
      _forceHoliday ? DayType.sunday : CalendarResolver.dayTypeFor(_date);

  String get _calendarId => _forceNight ? 'night' : CalendarResolver.calendarIdFor(_dayType);

  String _calendarLabel(AppLocalizations l) =>
      _forceNight ? l.calNight : CalendarResolver.labelFor(l, _dayType);

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
    final l = AppLocalizations.of(context)!;
    if (_origin.id == _destination.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.chooseDifferentStops)),
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
        dayTypeLabel: _calendarLabel(l),
      ),
    ));
  }

  void _selectFavorite(FavoriteRoute f) {
    setState(() {
      _origin = _repo.stopById(f.originId);
      _destination = _repo.stopById(f.destinationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final stops = _repo.stopsForCalendar(_calendarId);
    final localeName = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat('EEEE d MMMM', localeName).format(_date);
    final isFav = _favorites.isFavorite(_origin.id, _destination.id);
    final favorites = _favorites.items;

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
                      Text(l.lineSubtitle, style: TextStyle(color: scheme.onSurfaceVariant)),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.map_rounded),
                        tooltip: l.mapTooltip,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => MapScreen(stops: stops)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.settings_rounded),
                        tooltip: l.settingsTooltip,
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SubscriptionBanner(),
              if (favorites.isNotEmpty) ...[
                const SizedBox(height: 20),
                NextBusCard(
                  origin: _repo.stopById(favorites.first.originId),
                  destination: _repo.stopById(favorites.first.destinationId),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = favorites[index];
                      final o = _repo.stopById(f.originId);
                      final d = _repo.stopById(f.destinationId);
                      return InputChip(
                        avatar: const Icon(Icons.star_rounded, size: 16),
                        label: Text('${o.city} → ${d.city}', style: const TextStyle(fontSize: 12)),
                        onPressed: () => _selectFavorite(f),
                        onDeleted: () => _favorites.remove(f),
                        deleteIconColor: scheme.onSurfaceVariant,
                      );
                    },
                  ),
                ),
              ],
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
                      label: l.departureLabel,
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
                            color: Theme.of(context).cardColor,
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
                      label: l.arrivalLabel,
                      icon: Icons.flag_rounded,
                      value: _destination,
                      options: stops,
                      onChanged: (s) => setState(() => _destination = s),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _origin.id == _destination.id
                      ? null
                      : () => _favorites.toggle(_origin.id, _destination.id),
                  icon: Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded,
                      color: isFav ? Colors.amber[700] : scheme.onSurfaceVariant),
                  label: Text(isFav ? l.inFavorites : l.saveAsFavorite,
                      style: TextStyle(color: isFav ? Colors.amber[700] : scheme.onSurfaceVariant)),
                ),
              ),
              Text(l.whenTravel,
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
                segments: [
                  ButtonSegment(
                    value: SearchMode.departAfter,
                    label: Text(l.departAfter),
                    icon: const Icon(Icons.north_east_rounded),
                  ),
                  ButtonSegment(
                    value: SearchMode.arriveBy,
                    label: Text(l.arriveBy),
                    icon: const Icon(Icons.south_west_rounded),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => setState(() => _mode = s.first),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _forceHoliday,
                onChanged: _forceNight ? null : (v) => setState(() => _forceHoliday = v),
                title: Text(l.holidaySwitch),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _forceNight,
                onChanged: (v) => setState(() => _forceNight = v),
                title: Text(l.nightServiceSwitch),
                subtitle: Text(l.calendarApplied(_calendarLabel(l)),
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _search,
                  icon: const Icon(Icons.search_rounded),
                  label: Text(l.findBus),
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
        decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
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
