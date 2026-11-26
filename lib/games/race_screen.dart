import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/game_sound.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'race_painter.dart';

/// Corsa del minibus: strada infinita vista da dietro, supera le auto.
/// Trascina il dito (o usa le frecce) per cambiare corsia; 3 vite.
class RaceScreen extends StatefulWidget {
  final Difficulty difficulty;
  final bool night;
  const RaceScreen({super.key, this.difficulty = Difficulty.easy, this.night = false});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final _rand = Random();
  late final Ticker _ticker;
  Duration _last = Duration.zero;
  double _roadPos = 0, _busX = 0, _target = 0, _elapsed = 0, _mul = 1, _invuln = 0, _spawn = 1;
  final List<RaceCar> _cars = [];
  int _lives = 3;
  bool _started = false, _over = false, _newRecord = false;

  String get _key => 'race_${widget.difficulty.name}';
  double get _base => const [7.0, 8.0, 9.0][widget.difficulty.index];
  double get _ramp => min(_base * .6, _elapsed * _base * .01); // +60% in un minuto
  double get _speed => (_base + _ramp) * _mul;
  int get _meters => (_roadPos * 3).floor();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick);
    WidgetsBinding.instance.addObserver(this);
  }

  Sfx get _track => widget.night ? Sfx.raceNight : Sfx.raceDay;

  /// Con l'app in background la musica si ferma; riparte al ritorno.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // "inactive" è transitorio (tendina notifiche, finestre di sistema): non ferma la musica
    if (state == AppLifecycleState.resumed) {
      if (_started && !_over) GameSound.instance.playMusic(_track);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      GameSound.instance.stopMusic();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameSound.instance.stopMusic();
    _ticker.dispose();
    super.dispose();
  }

  void _reset() {
    _ticker.stop();
    GameSound.instance.stopMusic();
    _last = Duration.zero;
    setState(() {
      _roadPos = _busX = _target = _elapsed = _invuln = 0;
      _mul = 1;
      _spawn = 1;
      _cars.clear();
      _lives = 3;
      _started = _over = _newRecord = false;
    });
  }

  /// Aiuto con pubblicità: dopo la sconfitta si riparte da dove eri, con una vita.
  void _revive() {
    _last = Duration.zero;
    _cars.clear();
    _lives = 1;
    _invuln = 2.5;
    _mul = .5;
    setState(() {
      _over = false;
      _newRecord = false;
    });
    _ticker.start();
    GameSound.instance.playMusic(_track);
  }

  void _begin() {
    if (_started || _over) return;
    _started = true;
    _ticker.start();
    GameSound.instance.playMusic(_track);
  }

  void _steer(double dx, double width) {
    _begin();
    _target = ((dx / width) * 2 - 1).clamp(-1, 1) * 1.25;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k != LogicalKeyboardKey.arrowLeft && k != LogicalKeyboardKey.arrowRight) return KeyEventResult.ignored;
    _begin();
    _target = (_target.roundToDouble() + (k == LogicalKeyboardKey.arrowLeft ? -1 : 1)).clamp(-1, 1).toDouble();
    return KeyEventResult.handled;
  }

  void _spawnCar() {
    // sempre almeno una corsia libera: con due corsie già occupate si riusa una di quelle
    final recent = {for (final c in _cars) if (c.d > 16) c.lane};
    final lane = recent.length >= 2 ? recent.elementAt(_rand.nextInt(2)) : _rand.nextInt(3) - 1;
    _cars.add(RaceCar(24, lane, _rand.nextInt(5), 2.0 + _rand.nextDouble() * 1.2));
  }

  void _tick(Duration elapsed) {
    final dt = ((elapsed - _last).inMicroseconds / 1e6).clamp(0.0, 0.04);
    _last = elapsed;
    if (_over) return;
    _elapsed += dt;
    _mul = min(1.0, _mul + dt * .5);
    _invuln = max(0, _invuln - dt);
    final v = _speed;
    _roadPos += v * dt;
    _busX += (_target - _busX) * min(1.0, 9 * dt);
    _spawn -= dt;
    if (_spawn <= 0) {
      _spawnCar();
      final interval = const [1.5, 1.15, .9][widget.difficulty.index] * _base / (_base + _ramp);
      _spawn = interval * (.7 + _rand.nextDouble() * .6);
    }
    RaceCar? hit;
    for (final car in _cars) {
      car.d -= (v - car.speed) * dt;
      if (car.d < .85) {
        car.passed = true;
      } else if (car.d < 1.55 && _invuln <= 0 && (car.lane - _busX).abs() < .75) {
        hit = car;
      }
    }
    _cars.removeWhere((c) => c.d < .2);
    if (hit != null) _crash(hit);
    if (!_over) setState(() {});
  }

  void _crash(RaceCar car) {
    _cars.remove(car);
    _lives--;
    _mul = .5;
    _invuln = 1.6;
    HapticFeedback.heavyImpact();
    GameSound.instance.play(Sfx.thud);
    if (_lives <= 0) _end();
  }

  Future<void> _end() async {
    _ticker.stop();
    GameSound.instance.stopMusic();
    final record = _meters > 0 && await GameStats.instance.submitHigh(_key, _meters);
    if (!mounted) return;
    setState(() {
      _over = true;
      _newRecord = record;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.high(_key);
    final blink = _invuln > 0 && ((_invuln * 10).floor() % 2 == 0);
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: GameScaffold(
        title: l.gameRace,
        guardBack: true,
        celebrate: _over && _newRecord,
        // Durante la corsa la pagina non scorre; a fine partita sì (i pulsanti restano raggiungibili).
        physics: _over ? const ClampingScrollPhysics() : const NeverScrollableScrollPhysics(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.raceMeters(_meters), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Row(children: [
                for (var i = 0; i < 3; i++)
                  Icon(i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 22, color: Colors.red.shade400),
              ]),
              Text('${(_speed * 14).round()} km/h', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerRight,
            child: Text(best == null ? l.gameNoRecord : l.raceBest(best),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
          StatusSlot(
            child: _over
                ? ResultBanner(
                    key: ValueKey('race-$_meters'),
                    text: _newRecord ? '${l.gameOver} 🏆' : l.gameOver,
                    kind: _newRecord ? ResultKind.win : ResultKind.neutral,
                  )
                : Text(l.raceHint,
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          ),
          AspectRatio(
            aspectRatio: .8,
            child: LayoutBuilder(
              builder: (context, box) => ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) => _steer(e.localPosition.dx, box.maxWidth),
                  onPointerMove: (e) => _steer(e.localPosition.dx, box.maxWidth),
                  child: CustomPaint(
                    painter: RacePainter(widget.night ? RaceTheme.nightCity : RaceTheme.day, _roadPos, _busX, _cars, !blink),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_over) HintButton(game: 'race', onGranted: _revive),
          GameButton(onPressed: _reset, icon: Icons.refresh_rounded, label: l.gameNew),
        ],
      ),
    );
  }
}
