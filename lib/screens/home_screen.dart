import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
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
import '../services/analytics_service.dart';
import '../services/location_service.dart';
import '../services/my_places_controller.dart';
import '../services/review_prompt.dart';
import 'arcade_screen.dart';
import 'info_screen.dart';
import '../services/theme_controller.dart';
import '../theme/festive_themes.dart';
import '../widgets/app_date_picker.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/halloween_decorations.dart';
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
    MyPlacesController.instance.addListener(_onFavoritesChanged);
    _tryAutoSelectNearestStop();
    PoiRepository.instance.load();
  }

  @override
  void dispose() {
    _favorites.removeListener(_onFavoritesChanged);
    MyPlacesController.instance.removeListener(_onFavoritesChanged);
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

  // Nightlife cerca sempre dalle 22:00, salvo "Torna a casa" (da adesso).
  bool _nightFromNow = false;

  TimeOfDay get _searchTime => _tab == _HomeTab.nightlife && !_nightFromNow
      ? const TimeOfDay(hour: 22, minute: 0)
      : _time;

  String get _baseCalendarId {
    if (_tab == _HomeTab.nightlife) return 'night';
    final dt = DateTime(_date.year, _date.month, _date.day, _time.hour, _time.minute);
    return CalendarResolver.calendarIdForDateTime(dt);
  }

  DateTime get _dateTime => DateTime(
      _date.year, _date.month, _date.day, _searchTime.hour, _searchTime.minute);

  // Nightlife non ha più un orario reale (fisso 22:00): su quella tab,
  // _date="domenica" deve contare anche come "mattina dopo sabato notte",
  // non solo come "sera di domenica" (che non ha servizio). Si verifica
  // _dateTime (sera) OR _date alle 03:00 (fa scattare lo shift di un
  // giorno già previsto in CalendarResolver per le corse post-mezzanotte).
  bool _nightAvailable(bool Function(DateTime) check) {
    if (_tab != _HomeTab.nightlife) return check(_dateTime);
    final morningAfter = DateTime(_date.year, _date.month, _date.day, 3, 0);
    return check(_dateTime) || check(morningAfter);
  }

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
            _nightAvailable(CalendarResolver.isNightNt3Available)) {
          return 'night_nt3';
        }
        if (salouIds.contains(destId) && salouIds.contains(originId) &&
            _nightAvailable(CalendarResolver.isNightSalouAvailable)) {
          return 'night_salou';
        }
      } else {
        if (salouIds.contains(destId) && _nightAvailable(CalendarResolver.isNightSalouAvailable)) {
          return 'night_salou';
        }
        if (nt3Ids.contains(destId) && !nightIds.contains(destId) &&
            _nightAvailable(CalendarResolver.isNightNt3Available)) {
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
      if (_nightAvailable(CalendarResolver.isNightSalouAvailable)) {
        candidates.addAll(_repo.stopsForCalendar('night_salou'));
      }
      if (_nightAvailable(CalendarResolver.isNightNt3Available)) {
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
    final validIds = _destinationCandidates.map((s) => s.id).toSet();
    final pois = PoiRepository.instance.pois
        .where((p) => validIds.contains(p.nearestStopId))
        .toList();
    return _tab == _HomeTab.nightlife
        ? pois.where((p) => p.category == 'nightlife').toList()
        : pois.where((p) => p.category != 'nightlife').toList();
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
        _nightFromNow = false;
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
    final validIds = _destinationCandidates.map((s) => s.id).toSet();
    if (!validIds.contains(_destination!.stop.id)) {
      _destination = null;
    }
  }

  Future<void> _openDestinationPicker({String? categoryFilter}) async {
    final l = AppLocalizations.of(context)!;
    final pois = categoryFilter != null
        ? _allPois.where((p) => p.category == categoryFilter).toList()
        : _allPois;
    // When filtering by category, only show stops near matching POIs
    final stops = categoryFilter != null
        ? _destinationCandidates
            .where((s) => pois.any((p) => p.nearestStopId == s.id))
            .toList()
        : _destinationCandidates;
    final selected = await showStopPicker(
      context,
      title: l.whereDoYouWantToGo,
      stops: stops,
      pois: pois,
    );
    if (selected != null && mounted) {
      setState(() => _destination = selected);
    }
  }

  void _switchTab(_HomeTab tab) {
    if (_tab == tab) return;
    setState(() {
      _nightFromNow = false;
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
    AnalyticsService.instance.log('journey_search', {
      'origin': origin.id,
      'destination': _destination!.stop.id,
      if (_destination!.poi != null) 'poi': _destination!.poi!.id,
      'mode': _mode.name,
      'calendar': _calendarId,
    });
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ResultsScreen(
        origin: origin,
        destination: _destination!.stop,
        destinationPoi: _destination!.poi,
        date: _date,
        time: _searchTime,
        mode: _mode,
        calendarId: _calendarId,
        dayTypeLabel: _calendarLabel(l),
      ),
    )).then((_) => ReviewPrompt.instance.maybeAsk());
  }

  /// "Alla fermata abituale" / "Torna a casa" di giorno: da adesso, un tocco.
  void _quickRoute(String originId, String destinationId) {
    final now = DateTime.now();
    setState(() {
      _tab = _HomeTab.daylife;
      _nightFromNow = false;
      _date = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay.fromDateTime(now);
      _mode = SearchMode.departAfter;
      _nearestStop = _repo.stopById(originId);
      _gpsSucceeded = false;
      _destination = StopOrPoi.fromStop(_repo.stopById(destinationId));
    });
    _search();
  }

  /// "Torna a casa" in Nightlife: parte dalla fermata di ritorno del locale
  /// scelto, altrimenti dalla fermata trovata con il GPS.
  void _nightBackHome() {
    final homeId = MyPlacesController.instance.homeStopId;
    if (homeId == null) return;
    final now = DateTime.now();
    final poi = _destination?.poi;
    final fromPoi = poi == null ? null : _repo.stopById(poi.returnStopId ?? poi.nearestStopId);
    setState(() {
      _nightFromNow = true;
      _date = DateTime(now.year, now.month, now.day);
      _time = TimeOfDay.fromDateTime(now);
      _mode = SearchMode.departAfter;
      if (fromPoi != null) {
        _nearestStop = fromPoi;
        _gpsSucceeded = false;
      }
      _destination = StopOrPoi.fromStop(_repo.stopById(homeId));
    });
    _search();
  }

  /// Pulsante a fondo pagina: minigiochi per l'attesa.
  Widget _arcadeButton(AppLocalizations l, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const ArcadeScreen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_esports_rounded, color: scheme.onSecondaryContainer, size: 30),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.arcadeButton,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSecondaryContainer)),
                    const SizedBox(height: 2),
                    Text(l.arcadeSubtitle,
                        style: TextStyle(
                            fontSize: 12.5,
                            color: scheme.onSecondaryContainer.withOpacity(0.8))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSecondaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _myRoutes(AppLocalizations l, ColorScheme scheme, {required bool night}) {
    final places = MyPlacesController.instance;
    if (!places.configured) {
      // Solo finché non sono impostati: porta alle Impostazioni → I miei posti.
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MyPlacesScreen()),
          ),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.bookmark_added_rounded, color: scheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.configureMyRoutes,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer)),
                      const SizedBox(height: 2),
                      Text(l.configureMyRoutesSub,
                          style: TextStyle(
                              fontSize: 12,
                              color: scheme.onPrimaryContainer.withOpacity(0.8))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: scheme.onPrimaryContainer),
              ],
            ),
          ),
        ),
      );
    }
    final home = places.homeStopId!;
    final usual = places.usualStopId!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonalIcon(
              onPressed: night ? _nightBackHome : () => _quickRoute(usual, home),
              icon: const Icon(Icons.home_rounded, size: 18),
              label: Text(l.backHome),
            ),
          ),
          if (!night) ...[
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _quickRoute(home, usual),
                icon: const Icon(Icons.school_rounded, size: 18),
                label: Text(l.goToUsual, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Poi? _poiOf(FavoriteRoute f) {
    if (f.poiId == null) return null;
    for (final p in PoiRepository.instance.pois) {
      if (p.id == f.poiId) return p;
    }
    return null;
  }

  void _selectFavorite(FavoriteRoute f) {
    final stop = _repo.stopById(f.destinationId);
    final poi = _poiOf(f);
    setState(() {
      _nearestStop = _repo.stopById(f.originId);
      _destination = poi != null
          ? StopOrPoi.fromPoi(stop: stop, poiRef: poi)
          : StopOrPoi.fromStop(stop);
    });
  }

  Widget _favoriteChips(List<FavoriteRoute> favorites, ColorScheme scheme) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final f = favorites[index];
          final o = _repo.stopById(f.originId);
          final d = _repo.stopById(f.destinationId);
          final to = _poiOf(f)?.name ?? d.city;
          return InputChip(
            avatar: const Icon(Icons.star_rounded, size: 16),
            label: Text('${o.city} → $to', style: const TextStyle(fontSize: 12)),
            onPressed: () => _selectFavorite(f),
            onDeleted: () => _favorites.remove(f),
            deleteIconColor: scheme.onSurfaceVariant,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final localeName = Localizations.localeOf(context).languageCode;
    final dateLabel = DateFormat('EEE d MMM', localeName).format(_date);
    final favorites = _favorites.itemsFor(night: _tab == _HomeTab.nightlife);
    final isHalloween = ThemeController.instance.isHalloween;
    final festive = ThemeController.instance.festive;
    final seed = festive != null
        ? festive.accent
        : isHalloween
        ? const Color(0xFFFF6B00)
        : ThemeController.instance.isChristmas
            ? const Color(0xFFE53935)
            : ThemeController.instance.seedColor;
    final onSeed = seed.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;
    final isNight = _tab == _HomeTab.nightlife;

    // La home non ha AppBar: senza questo, le icone della barra di stato
    // restavano quelle impostate da un'altra schermata (es. bianche su bianco).
    final overlay = (Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(statusBarColor: Colors.transparent);
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlay,
        child: Stack(
        fit: StackFit.expand, // vincoli stretti: lo scroll view riempie lo schermo
        children: [
          // Neve e alberi sparsi su tutto lo schermo, dietro ai contenuti.
          if (ThemeController.instance.isChristmas)
            const Positioned.fill(
              child: IgnorePointer(child: SnowScatter()),
            ),
          if (festive != null)
            Positioned.fill(
              child: IgnorePointer(child: FestiveScatter(festive.deco)),
            ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderWithGo(context, l, scheme, seed, onSeed, isNight),
                  isNight
                      ? _buildNightBody(context, l, scheme, seed, dateLabel, favorites)
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

  // Floating capsule switch — straddles the header/card boundary (half on
  // the seed header, half overlapping the card). Self-sizing: no need to
  // know the available width, AnimatedSize handles the expand/collapse.
  Widget _buildFloatingTabSwitch(Color seed, Color onSeed) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFloatingTab(_HomeTab.daylife, Icons.wb_sunny_outlined, 'Daylife', seed, onSeed),
          const SizedBox(width: 4),
          _buildFloatingTab(_HomeTab.nightlife, Icons.nightlight_outlined, 'Nightlife', seed, onSeed),
        ],
      ),
    );
  }

  Widget _buildFloatingTab(_HomeTab tab, IconData icon, String label, Color seed, Color onSeed) {
    final isActive = _tab == tab;
    return GestureDetector(
      onTap: () => _switchTab(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 10, vertical: 9),
        decoration: BoxDecoration(
          color: isActive
              ? (ThemeController.instance.isChristmas && tab == _HomeTab.nightlife
                  ? const Color(0xFF2E9B4A)
                  : seed)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? onSeed : Colors.white70),
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeInOut,
                child: isActive
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        const SizedBox(width: 6),
                        Text(label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSeed,
                            )),
                      ])
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Intestazione + pulsante "Vai" a cavallo del bordo inferiore (stesso
  /// stile del selettore Daylife/Nightlife). I 26px extra nel layout tengono
  /// la metà inferiore del pulsante dentro l'area che riceve i tocchi.
  Widget _buildHeaderWithGo(BuildContext context, AppLocalizations l,
      ColorScheme scheme, Color seed, Color onSeed, bool isNight) {
    const overhang = 26.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: overhang),
          child: _buildHeader(context, l, scheme, seed, onSeed, isNight),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(child: _buildGoButton(context, l)),
        ),
      ],
    );
  }

  Widget _buildGoButton(BuildContext context, AppLocalizations l) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    return ElevatedButton.icon(
      onPressed: _destination == null ? _openDestinationPicker : _search,
      icon: const Icon(Icons.search_rounded, size: 22),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.goButton),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward_rounded, size: 20),
        ],
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 6,
        shape: StadiumBorder(side: BorderSide(color: bg, width: 4)),
        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l, ColorScheme scheme,
      Color seed, Color onSeedIn, bool isNight) {
    final isHalloween = ThemeController.instance.isHalloween;
    final isChristmas = ThemeController.instance.isChristmas;
    final festive = ThemeController.instance.festive;
    final onSeed = festive?.onBanner ?? onSeedIn;
    return Container(
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: (isNight && !isHalloween && !isChristmas && festive == null) ? seed : null,
        gradient: festive != null
            ? festive.gradient
            : (isNight && !isHalloween && !isChristmas)
            ? null
            : LinearGradient(
                colors: isHalloween
                    ? const [Color(0xFFE8600A), Color(0xFF1A0500)]
                    : isChristmas
                        // Taglio netto rosso/verde con filo bianco: niente
                        // tonalità fangose a metà sfumatura.
                        ? const [
                            Color(0xFFE53935), Color(0xFFE53935),
                            Color(0xFFFFFFFF), Color(0xFFFFFFFF),
                            Color(0xFF2E9B4A), Color(0xFF2E9B4A),
                          ]
                        : [seed, Color.lerp(seed, Colors.black, 0.28)!],
                stops: isChristmas ? const [0, 0.66, 0.66, 0.675, 0.675, 1] : null,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isHalloween) ...[
                      const SkullIcon(size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                    ],
                    if (isChristmas) ...[
                      const SnowflakeIcon(size: 14, color: Colors.white70),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      'ErasBus Tarragona',
                      style: TextStyle(
                        color: onSeed.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_destination != null)
                      IconButton(
                        icon: Icon(Icons.map_rounded, color: onSeed),
                        tooltip: l.mapTooltip,
                        onPressed: () {
                          final stop = _destination!.stop;
                          final d = _destination!.poi?.dropoff;
                          final uri = Uri.parse(
                            'https://www.google.com/maps/search/?api=1&query=${d?.lat ?? stop.lat},${d?.lng ?? stop.lng}',
                          );
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.info_outline_rounded, color: onSeed),
                      tooltip: l.usefulInfoTitle,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const InfoScreen()),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.settings_rounded, color: onSeed),
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              isNight ? l.titleNightlife : l.titleDaylife,
              style: TextStyle(
                color: onSeed,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
          if (isChristmas)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🎄', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Flexible(
                    // Su schermi stretti o con testo grande il motto si rimpicciolisce.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'M E R R Y  C H R I S T M A S',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('🎅', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          if (festive != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(festive.mottoLeft, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        festive.mottoText,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(festive.mottoRight, style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          if (isHalloween)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SkullIcon(size: 18, color: Color(0xFFF3E7CE)),
                  const SizedBox(width: 10),
                  const Text(
                    'H A L L O W E E N',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFF3E7CE), // osso, alto contrasto sull'arancio
                      letterSpacing: 3,
                      shadows: [
                        Shadow(color: Colors.black, offset: Offset(1.4, 1.4)),
                        Shadow(color: Colors.black87, blurRadius: 10),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const SkullIcon(size: 18, color: Color(0xFFF3E7CE)),
                ],
              ),
            ),
          // Search card — floating tab switch straddles header/card boundary
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  // Origin row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
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
                Positioned(
                  top: 0,
                  child: _buildFloatingTabSwitch(seed, onSeed),
                ),
              ],
            ),
          ),
        ],
      ),
          if (isChristmas) ...[
            const Positioned(
              top: 0,
              left: 0,
              child: IgnorePointer(
                child: SnowCorner(size: 74, color: Colors.white70),
              ),
            ),
            const Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: SnowCorner(
                    size: 74, color: Colors.white70, corner: Alignment.topRight),
              ),
            ),
          ],
          if (isHalloween) ...[
            Positioned(
              top: 0,
              left: 0,
              child: IgnorePointer(
                child: CobwebCorner(size: 70, color: Colors.black.withValues(alpha: 0.35)),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IgnorePointer(
                child: CobwebCorner(
                  size: 70,
                  color: Colors.black.withValues(alpha: 0.35),
                  corner: Alignment.topRight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDayBody(BuildContext context, AppLocalizations l,
      ColorScheme scheme, String dateLabel, List<FavoriteRoute> favorites) {
    final isHalloween = ThemeController.instance.isHalloween;
    final isChristmas = ThemeController.instance.isChristmas;
    return Stack(
      children: [
        Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _myRoutes(l, scheme, night: false),
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
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.88,
              child: SegmentedButton<SearchMode>(
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
            ),
          ),
          const SubscriptionBanner(),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 16),
            NextBusCard(
              origin: _repo.stopById(favorites.first.originId),
              destination: _repo.stopById(favorites.first.destinationId),
            ),
            const SizedBox(height: 8),
            _favoriteChips(favorites, scheme),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              if (ThemeController.instance.isChristmas)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Text('🎁', style: TextStyle(fontSize: 18)),
                ),
              if (ThemeController.instance.isHalloween)
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: SkullIcon(size: 20, color: Color(0xFFF3E7CE)),
                ),
              Expanded(
                child: Text(
                  l.whereDoYouWantToGo,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CategoryCard(
            icon: Icons.school_rounded,
            label: l.categoryUniversity,
            color: scheme.surfaceContainerHighest,
            iconColor: scheme.onSurface,
            fullWidth: true,
            onTap: () => _openDestinationPicker(categoryFilter: 'university'),
          ),
          const SizedBox(height: 10),
          _CategoryCard(
            icon: Icons.directions_bus_rounded,
            label: l.categoryAllStops,
            subtitle: 'Tarragona · Reus · Salou',
            color: scheme.surfaceContainerHighest,
            iconColor: scheme.onSurface,
            fullWidth: true,
            onTap: () => _openDestinationPicker(),
          ),
          _arcadeButton(l, scheme),
        ],
      ),
        ),
        if (isChristmas)
          const Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: SnowCorner(
                size: 56,
                color: Color(0xFFB7D4EE),
                corner: Alignment.topRight,
              ),
            ),
          ),
        if (isHalloween)
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: CobwebCorner(
                size: 56,
                color: Colors.white.withValues(alpha: 0.08),
                corner: Alignment.topRight,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNightBody(BuildContext context, AppLocalizations l,
      ColorScheme scheme, Color seed, String dateLabel,
      List<FavoriteRoute> favorites) {
    final isHalloween = ThemeController.instance.isHalloween;
    final isChristmas = ThemeController.instance.isChristmas;
    return Stack(
      children: [
        Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _myRoutes(l, scheme, night: true),
          _ChipButton(
            icon: Icons.calendar_month_rounded,
            label: dateLabel,
            onTap: _pickDate,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Text(
              _calendarLabel(l),
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
          if (favorites.isNotEmpty) ...[
            const SizedBox(height: 12),
            _favoriteChips(favorites, scheme),
          ],
          const SizedBox(height: 16),
          _CategoryCard(
            icon: Icons.nightlife_rounded,
            label: l.categoryNightlife,
            subtitle: 'Tropical Club · Flash Back · La Fàbrica...',
            color: scheme.surfaceContainerHighest,
            iconColor: scheme.onSurface,
            fullWidth: true,
            onTap: () => _openDestinationPicker(categoryFilter: 'nightlife'),
          ),
          _arcadeButton(l, scheme),
        ],
      ),
        ),
        if (isChristmas)
          const Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: SnowCorner(
                size: 56,
                color: Color(0xFFB7D4EE),
                corner: Alignment.topRight,
              ),
            ),
          ),
        if (isHalloween)
          Positioned(
            top: 0,
            right: 0,
            child: IgnorePointer(
              child: CobwebCorner(
                size: 56,
                color: Colors.white.withValues(alpha: 0.08),
                corner: Alignment.topRight,
              ),
            ),
          ),
      ],
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
