import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../data/poi_repository.dart';
import '../data/schedule_repository.dart';
import '../models/favorite_route.dart';
import '../models/poi.dart';
import '../models/stop.dart';
import '../models/stop_or_poi.dart';
import '../services/calendar_resolver.dart';
import '../services/favorites_controller.dart';
import '../services/journey_planner.dart';
import '../services/location_service.dart';
import '../services/theme_controller.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/stop_selector.dart';
import '../widgets/subscription_banner.dart';
import '../widgets/next_bus_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'results_screen.dart';
import 'settings_screen.dart';

enum _HomeTab { daylife, nightlife }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = ScheduleRepository.instance;
  final _favorites = FavoritesController.instance;

  _HomeTab _tab = _HomeTab.daylife;
  int _nightDateIndex = 0;
  StopOrPoi? _destination;
  Stop? _nearestStop;
  bool _gpsLoading = false;
  bool _gpsSucceeded = false;
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  SearchMode _mode = SearchMode.departAfter;

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_onFavoritesChanged);
    _tryAutoSelectNearestStop();
    PoiRepository.instance.load();
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
    setState(() => _gpsLoading = true);
    final nearest = await LocationService.nearestStop(_repo.stops);
    if (mounted) {
      setState(() {
        _nearestStop = nearest;
        _gpsSucceeded = nearest != null;
        _gpsLoading = false;
      });
    }
  }

  List<DateTime> get _availableNightDates {
    final now = DateTime.now();
    final dates = <DateTime>[];
    for (var i = 0; i <= 7; i++) {
      final d = now.add(Duration(days: i));
      if (d.weekday == DateTime.friday || d.weekday == DateTime.saturday) {
        dates.add(d);
        if (dates.length == 2) break;
      }
    }
    return dates;
  }

  DateTime get _nextNightDate =>
      _availableNightDates[_nightDateIndex.clamp(0, _availableNightDates.length - 1)];

  DateTime get _searchDate => _tab == _HomeTab.nightlife ? _nextNightDate : _date;
  TimeOfDay get _searchTime =>
      _tab == _HomeTab.nightlife ? const TimeOfDay(hour: 23, minute: 30) : _time;

  String get _baseCalendarId {
    final dt = DateTime(_searchDate.year, _searchDate.month, _searchDate.day,
        _searchTime.hour, _searchTime.minute);
    return CalendarResolver.calendarIdForDateTime(dt);
  }

  DateTime get _dateTime => DateTime(_searchDate.year, _searchDate.month,
      _searchDate.day, _searchTime.hour, _searchTime.minute);

  String get _calendarId {
    final base = _baseCalendarId;
    if (base == 'night' && _destination != null) {
      final destId = _destination!.stop.id;
      final originId = _originStop?.id;
      final salouIds = _repo.stopsForCalendar('night_salou').map((s) => s.id).toSet();
      final nt3Ids = _repo.stopsForCalendar('night_nt3').map((s) => s.id).toSet();
      final nightIds = _repo.stopsForCalendar('night').map((s) => s.id).toSet();

      if (originId != null) {
        if (nt3Ids.contains(destId) && nt3Ids.contains(originId) &&
            (!nightIds.contains(destId) || !nightIds.contains(originId)) &&
            CalendarResolver.isNightNt3Available(_dateTime)) {
          return 'night_nt3';
        }
        if (salouIds.contains(destId) && salouIds.contains(originId) &&
            CalendarResolver.isNightSalouAvailable(_dateTime)) {
          return 'night_salou';
        }
      } else {
        if (salouIds.contains(destId) && CalendarResolver.isNightSalouAvailable(_dateTime)) {
          return 'night_salou';
        }
        if (nt3Ids.contains(destId) && !nightIds.contains(destId) &&
            CalendarResolver.isNightNt3Available(_dateTime)) {
          return 'night_nt3';
        }
      }
    }
    return base;
  }

  List<Stop> get _destinationCandidates {
    final base = _baseCalendarId;
    if (base == 'night') {
      final seen = <String>{};
      final candidates = [..._repo.stopsForCalendar('night')];
      if (CalendarResolver.isNightSalouAvailable(_dateTime)) {
        candidates.addAll(_repo.stopsForCalendar('night_salou'));
      }
      if (CalendarResolver.isNightNt3Available(_dateTime)) {
        candidates.addAll(_repo.stopsForCalendar('night_nt3'));
      }
      return candidates.where((s) => seen.add(s.id)).toList();
    }
    return _repo.stopsForCalendar(base);
  }

  Stop? get _originStop => _nearestStop;

  String _calendarLabel(AppLocalizations l) {
    final id = _calendarId;
    if (id == 'night_salou') return l.calNightSalou;
    if (id == 'night_nt3') return l.calNightNt3;
    if (id == 'night') return l.calNight;
    final dt = DateTime(_date.year, _date.month, _date.day);
    return CalendarResolver.labelFor(l, CalendarResolver.dayTypeFor(dt));
  }

  List<Poi> get _allPois {
    final validIds = {
      ..._destinationCandidates.map((s) => s.id),
      ..._repo.stopsForCalendar('night').map((s) => s.id),
      ..._repo.stopsForCalendar('night_salou').map((s) => s.id),
      ..._repo.stopsForCalendar('night_nt3').map((s) => s.id),
    };
    final pois = PoiRepository.instance.pois
        .where((p) => validIds.contains(p.nearestStopId))
        .toList();
    return _tab == _HomeTab.nightlife
        ? pois.where((p) => p.category == 'nightlife').toList()
        : pois;
  }

  Future<void> _pickDate() async {
    final picked = await showAppDatePicker(
      context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _date = picked;
        _clearDestinationIfInvalid();
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) {
      setState(() {
        _time = picked;
        _clearDestinationIfInvalid();
      });
    }
  }

  void _clearDestinationIfInvalid() {
    if (_destination == null) return;
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    final base = CalendarResolver.calendarIdForDateTime(dt);
    final Set<String> validIds;
    if (base == 'night') {
      validIds = {
        ..._repo.stopsForCalendar('night').map((s) => s.id),
        ..._repo.stopsForCalendar('night_salou').map((s) => s.id),
        ..._repo.stopsForCalendar('night_nt3').map((s) => s.id),
      };
    } else {
      validIds = _repo.stopsForCalendar(base).map((s) => s.id).toSet();
    }
    if (!validIds.contains(_destination!.stop.id)) {
      _destination = null;
    }
  }

  Future<void> _openDestinationPicker({String? categoryFilter}) async {
    final l = AppLocalizations.of(context)!;
    final pois = categoryFilter != null
        ? _allPois.where((p) => p.category == categoryFilter).toList()
        : _allPois;
    final selected = await showStopPicker(
      context,
      title: l.whereDoYouWantToGo,
      stops: _destinationCandidates,
      pois: pois,
    );
    if (selected != null && mounted) {
      setState(() => _destination = selected);
    }
  }

  void _switchTab(_HomeTab tab) {
    if (_tab == tab) return;
    setState(() {
      _tab = tab;
      _destination = null;
    });
  }

  void _swap() {
    if (_originStop == null || _destination == null) return;
    setState(() {
      final prevOrigin = _nearestStop;
      final returnId = _destination!.poi?.returnStopId;
      final swapStop = returnId != null
          ? (_repo.stops.where((s) => s.id == returnId).firstOrNull ?? _destination!.stop)
          : _destination!.stop;
      _nearestStop = swapStop;
      _destination = StopOrPoi.fromStop(prevOrigin!);
      _gpsSucceeded = false;
    });
  }

  Future<void> _openOriginPicker() async {
    final l = AppLocalizations.of(context)!;
    final selected = await showStopPicker(
      context,
      title: l.departureLabel,
      stops: _destinationCandidates,
      pois: const [],
    );
    if (selected != null && mounted) {
      setState(() => _nearestStop = selected.stop);
    }
  }

  void _search() {
    if (_destination == null) return;
    final l = AppLocalizations.of(context)!;
    final origin = _originStop;
    if (origin == null) {
      _openOriginPicker();
      return;
    }
    if (origin.id == _destination!.stop.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l.chooseDifferentStops)),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(
        origin: origin,
        destination: _destination!.stop,
        destinationPoi: _destination!.poi,
        date: _searchDate,
        time: _searchTime,
        mode: _mode,
        calendarId: _calendarId,
        dayTypeLabel: _calendarLabel(l),
      ),
    ));
  }

  void _selectFavorite(FavoriteRoute f) {
    setState(() {
      _nearestStop = _repo.stopById(f.originId);
      _destination = StopOrPoi.fromStop(_repo.stopById(f.destinationId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final localeName = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat('EEE d MMM', localeName).format(_date);
    final favorites = _favorites.items;
    final seed = ThemeController.instance.seedColor;
    final onSeed = seed.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;
    final isNight = _tab == _HomeTab.nightlife;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildTabStrip(context, seed, onSeed, scheme),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, l, scheme, seed, onSeed, isNight),
                    isNight
                        ? _buildNightBody(context, l, scheme, localeName)
                        : _buildDayBody(context, l, scheme, dateLabel, favorites),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabStrip(BuildContext context, Color seed, Color onSeed, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTab(
                context, _HomeTab.daylife, Icons.wb_sunny_outlined, 'Daylife',
                activeBg: seed,
                activeFg: onSeed,
                inactiveFg: scheme.onSurfaceVariant,
              ),
            ),
            Expanded(
              child: _buildTab(
                context, _HomeTab.nightlife, Icons.nightlight_outlined, 'Nightlife',
                activeBg: scheme.primaryContainer,
                activeFg: scheme.onPrimaryContainer,
                inactiveFg: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    _HomeTab tab,
    IconData icon,
    String label, {
    required Color activeBg,
    required Color activeFg,
    required Color inactiveFg,
  }) {
    final isActive = _tab == tab;
    return GestureDetector(
      onTap: () => _switchTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isActive
              ? [BoxShadow(
                  color: activeBg.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: isActive ? activeFg : inactiveFg),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? activeFg : inactiveFg,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, ColorScheme scheme,
      Color seed, Color onSeed, bool isNight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nightBg = isDark ? scheme.primary : scheme.primaryContainer;
    final nightFg = isDark ? scheme.onPrimary : scheme.onPrimaryContainer;
    final headerFg = isNight ? nightFg : onSeed;
    return Container(
      decoration: BoxDecoration(
        color: isNight ? nightBg : null,
        gradient: isNight
            ? null
            : LinearGradient(
                colors: [seed, Color.lerp(seed, Colors.black, 0.28)!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ErasBus Tarragona',
                  style: TextStyle(
                    color: headerFg.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    if (_destination != null)
                      IconButton(
                        icon: Icon(Icons.map_rounded, color: headerFg),
                        tooltip: l.mapTooltip,
                        onPressed: () {
                          final stop = _destination!.stop;
                          final uri = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${stop.lat},${stop.lng}',
                          );
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.settings_rounded, color: headerFg),
                      tooltip: l.settingsTooltip,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Text(
              isNight ? l.titleNightlife : l.titleDaylife,
              style: TextStyle(
                color: headerFg,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: _gpsLoading ? null : _tryAutoSelectNearestStop,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: scheme.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: _gpsLoading
                                  ? Padding(
                                      padding: const EdgeInsets.all(9),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: scheme.onPrimaryContainer,
                                      ),
                                    )
                                  : Icon(
                                      _gpsSucceeded
                                          ? Icons.gps_fixed_rounded
                                          : Icons.gps_not_fixed_rounded,
                                      color: scheme.onPrimaryContainer,
                                      size: 18,
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: _openOriginPicker,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l.departureLabel,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: scheme.onSurfaceVariant),
                                    ),
                                    if (_gpsLoading)
                                      Text(
                                        l.gpsDetecting,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: scheme.onSurfaceVariant),
                                      )
                                    else if (_originStop != null)
                                      Text(
                                        _originStop!.name,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else
                                      Text(
                                        l.departureLabel,
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: scheme.onSurfaceVariant),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: _openOriginPicker,
                            child: Text(
                              l.change,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.primary,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                            child: Divider(height: 1, indent: 60)),
                        if (_originStop != null && _destination != null)
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: _swap,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: scheme.primaryContainer,
                                child: Icon(Icons.swap_vert_rounded,
                                    size: 16,
                                    color: scheme.onPrimaryContainer),
                              ),
                            ),
                          ),
                      ],
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openDestinationPicker(
                          categoryFilter: isNight ? 'nightlife' : null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _destination != null
                                    ? scheme.primaryContainer
                                    : scheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isNight
                                    ? Icons.nightlife_rounded
                                    : Icons.flag_rounded,
                                color: _destination != null
                                    ? scheme.onPrimaryContainer
                                    : scheme.onSurfaceVariant,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l.arrivalLabel,
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: scheme.onSurfaceVariant),
                                  ),
                                  if (_destination != null) ...[
                                    Text(
                                      _destination!.displayName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (_destination!.isPoi)
                                      Text(
                                        _destination!.displaySubtitle,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: scheme.onSurfaceVariant),
                                      ),
                                  ] else
                                    Text(
                                      l.whereDoYouWantToGo,
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: scheme.onSurfaceVariant),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBody(BuildContext context, AppLocalizations l, ColorScheme scheme,
      String dateLabel, List<FavoriteRoute> favorites) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_destination?.poi?.isNightlife == true) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Icon(Icons.nightlife_rounded, size: 18, color: Colors.deepPurple[600]),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Per le corse notturne seleziona venerdì o sabato e orario dopo le 23:00',
                      style: TextStyle(fontSize: 12, color: Colors.deepPurple[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              _calendarLabel(l),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<SearchMode>(
            style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
            segments: [
              ButtonSegment(
                value: SearchMode.departAfter,
                label: Text(l.departAfter, style: const TextStyle(fontSize: 12)),
                icon: const Icon(Icons.north_east_rounded, size: 14),
              ),
              ButtonSegment(
                value: SearchMode.arriveBy,
                label: Text(l.arriveBy, style: const TextStyle(fontSize: 12)),
                icon: const Icon(Icons.south_west_rounded, size: 14),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SubscriptionBanner(),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 16),
            NextBusCard(
              origin: _repo.stopById(favorites.first.originId),
              destination: _repo.stopById(favorites.first.destinationId),
            ),
            const SizedBox(height: 8),
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
                    label: Text('${o.city} → ${d.city}',
                        style: const TextStyle(fontSize: 12)),
                    onPressed: () => _selectFavorite(f),
                    onDeleted: () => _favorites.remove(f),
                    deleteIconColor: scheme.onSurfaceVariant,
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            l.whereDoYouWantToGo,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _CategoryCard(
                  icon: Icons.school_rounded,
                  label: l.categoryUniversity,
                  color: scheme.primaryContainer,
                  iconColor: scheme.onPrimaryContainer,
                  onTap: () => _openDestinationPicker(categoryFilter: 'university'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CategoryCard(
                  icon: Icons.nightlife_rounded,
                  label: l.categoryNightlife,
                  color: scheme.tertiaryContainer,
                  iconColor: scheme.onTertiaryContainer,
                  onTap: () => _openDestinationPicker(categoryFilter: 'nightlife'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CategoryCard(
            icon: Icons.directions_bus_rounded,
            label: l.categoryAllStops,
            subtitle: 'Tarragona · Reus · Salou',
            color: scheme.surfaceContainerHighest,
            iconColor: scheme.onSurfaceVariant,
            fullWidth: true,
            onTap: () => _openDestinationPicker(),
          ),
          if (_destination != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: Icon(_originStop == null
                    ? Icons.my_location_rounded
                    : Icons.search_rounded),
                label: Text(_originStop == null ? l.departureLabel : l.findBus),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNightBody(BuildContext context, AppLocalizations l,
      ColorScheme scheme, String localeName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final nightSurface = isDark ? scheme.secondary : scheme.secondaryContainer;
    final nightOnSurface = isDark ? scheme.onSecondary : scheme.onSecondaryContainer;
    final dates = _availableNightDates;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: List.generate(dates.length, (i) {
              final isSelected = i == _nightDateIndex;
              final label = DateFormat('EEE d MMM', localeName).format(dates[i]);
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() { _nightDateIndex = i; _destination = null; }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < dates.length - 1 ? 8 : 0, bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? nightSurface : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.nightlight_rounded, size: 14,
                            color: isSelected ? nightOnSurface : scheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(label, style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? nightOnSurface : scheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          _CategoryCard(
            icon: Icons.nightlife_rounded,
            label: l.categoryNightlife,
            subtitle: 'Tropical Club · La Fàbrica · Selvático...',
            color: nightSurface,
            iconColor: nightOnSurface,
            fullWidth: true,
            onTap: () => _openDestinationPicker(categoryFilter: 'nightlife'),
          ),
          if (_destination != null) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _search,
                icon: Icon(_originStop == null
                    ? Icons.my_location_rounded
                    : Icons.search_rounded),
                label: Text(_originStop == null ? l.departureLabel : l.findBus),
              ),
            ),
          ],
        ],
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
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16)),
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

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final Color iconColor;
  final bool fullWidth;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.iconColor,
    required this.onTap,
    this.subtitle,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(fullWidth ? 12 : 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: fullWidth
            ? Row(
                children: [
                  Icon(icon, color: iconColor, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: iconColor)),
                        if (subtitle != null)
                          Text(subtitle!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: iconColor.withValues(alpha: 0.7))),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: iconColor.withValues(alpha: 0.6)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(height: 10),
                  Text(label,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: iconColor)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: TextStyle(
                            fontSize: 11,
                            color: iconColor.withValues(alpha: 0.7))),
                ],
              ),
      ),
    );
  }
}
