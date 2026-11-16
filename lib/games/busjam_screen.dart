import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/busjam_logic.dart';
import '../services/game_sound.dart';

/// Ogni difficoltà ha 10 livelli (dei 30 generati): facile 1-10, medio 11-20,
/// difficile 21-30. I livelli si sbloccano uno dopo l'altro.
class BusJamScreen extends StatefulWidget {
  final Difficulty difficulty;
  const BusJamScreen({super.key, this.difficulty = Difficulty.easy});

  static const levelsPerGroup = 10;

  static int baseFor(Difficulty d) => d.index * levelsPerGroup;

  /// Livello più alto sbloccato (1..10) per la difficoltà.
  static int unlocked(Difficulty d) =>
      GameStats.instance.value('busjam_unlocked_${d.name}', 1);

  @override
  State<BusJamScreen> createState() => _BusJamScreenState();
}

class _BusJamScreenState extends State<BusJamScreen> {
  int _level = 1; // 1..10 dentro la difficoltà
  JamLevel? _jam;
  List<int> _pos = [];
  int _moves = 0;
  bool _won = false;
  bool _loading = true;
  int _gen = 0; // cambia a ogni (ri)caricamento: fa partire l'animazione
  bool _exited = false; // il bus rosso esce dalla griglia
  bool _locked = false; // blocca lo scroll della pagina mentre si trascina

  int _dragStart = 0;
  int _lo = 0, _hi = 0;
  double _dragAccum = 0;
  final _levelWatch = Stopwatch();
  Timer? _skipTimer;
  bool _skipped = false;

  Difficulty get _difficulty => widget.difficulty;
  int get _unlocked => BusJamScreen.unlocked(_difficulty);
  int get _global => BusJamScreen.baseFor(_difficulty) + _level;

  static const _palette = [
    Colors.indigo, Colors.teal, Colors.orange, Colors.purple, Colors.brown,
    Colors.blueGrey, Colors.green, Colors.pink, Colors.cyan, Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _level = min(_unlocked, BusJamScreen.levelsPerGroup);
    _load();
    // controlla ogni secondo se è ora di offrire il salto del livello
    _skipTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted && !_won && !_loading) setState(() {});
    });
  }

  @override
  void dispose() {
    _skipTimer?.cancel();
    super.dispose();
  }

  /// Dopo 1 minuto sullo stesso livello o 30 mosse si può saltare il livello.
  bool get _canOfferSkip =>
      !_won &&
      !_loading &&
      (_levelWatch.elapsedMilliseconds >= 60000 || _moves >= 30) &&
      RewardedOffer.available;

  Future<void> _skip() async {
    final l = AppLocalizations.of(context)!;
    final ok = await RewardedOffer.ask(context,
        game: 'busjam', action: 'skip', title: l.rewardedSkipTitle, message: l.rewardedSkipMessage);
    if (!ok || !mounted) return;
    if (_level + 1 > _unlocked && _level < BusJamScreen.levelsPerGroup) {
      await GameStats.instance.setValue('busjam_unlocked_${_difficulty.name}', _level + 1);
    }
    if (!mounted) return;
    if (_level < BusJamScreen.levelsPerGroup) {
      _go(_level + 1);
    } else {
      setState(() {
        _won = true;
        _exited = true;
        _skipped = true;
      });
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 60));
    final jam = JamLogic.generate(_global);
    if (!mounted) return;
    setState(() {
      _jam = jam;
      _pos = List<int>.from(jam.start);
      _moves = 0;
      _won = false;
      _exited = false;
      _skipped = false;
      _gen++;
      _loading = false;
    });
    _levelWatch
      ..reset()
      ..start();
  }

  void _go(int level) {
    _level = level.clamp(1, min(_unlocked, BusJamScreen.levelsPerGroup));
    _load();
  }

  void _dragBegin(int i) {
    final jam = _jam!;
    final occ = JamLogic.occupancy(jam.vehicles, _pos);
    final (lo, hi) = JamLogic.reach(jam.vehicles, _pos, i, occ);
    _lo = lo;
    _hi = hi;
    _dragStart = _pos[i];
    _dragAccum = 0;
  }

  void _dragUpdate(int i, DragUpdateDetails d, double cell) {
    if (_won) return;
    final horizontal = _jam!.vehicles[i].horizontal;
    _dragAccum += horizontal ? d.delta.dx : d.delta.dy;
    final target = (_dragStart + (_dragAccum / cell).round()).clamp(_lo, _hi);
    if (target != _pos[i]) setState(() => _pos[i] = target);
  }

  Future<void> _dragEnd(int i) async {
    if (_pos[i] == _dragStart) return;
    GameSound.instance.play(Sfx.place);
    setState(() => _moves++);
    if (JamLogic.solved(_jam!.vehicles, _pos)) {
      await GameStats.instance.submitBest('busjam_$_global', _moves);
      if (_level + 1 > _unlocked && _level < BusJamScreen.levelsPerGroup) {
        await GameStats.instance.setValue('busjam_unlocked_${_difficulty.name}', _level + 1);
      }
      if (mounted) {
        setState(() {
          _won = true;
          _exited = true; // il bus rosso esce dalla griglia
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final jam = _jam;
    final best = GameStats.instance.best('busjam_$_global');
    final maxLevel = min(_unlocked, BusJamScreen.levelsPerGroup);
    return GameScaffold(
      title: l.gameBusJam,
      physics: _locked ? const NeverScrollableScrollPhysics() : null,
      guardBack: true,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _level > 1 ? () => _go(_level - 1) : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Column(
              children: [
                Text(difficultyLabel(l, _difficulty).toUpperCase(),
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                Text(l.gameLevel(_level),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
            IconButton(
              onPressed: _level < maxLevel ? () => _go(_level + 1) : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.gameMoves(_moves)),
            Text(best == null ? l.gameNoRecord : l.gameBestMoves(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: ValueKey('won-$_global-$_gen'),
                  text: _skipped ? l.gameSkipped : l.gameLevelDone,
                  kind: _skipped ? ResultKind.neutral : ResultKind.win,
                )
              : Text(l.gameBusJamHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 420.0);
          final cell = side / JamLogic.size;
          return Center(
            child: Listener(
              onPointerDown: (_) => setState(() => _locked = true),
              onPointerUp: (_) => setState(() => _locked = false),
              onPointerCancel: (_) => setState(() => _locked = false),
              child: SizedBox(
                width: side,
                height: side,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 380),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(begin: const Offset(0.25, 0), end: Offset.zero).animate(
                        CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                      ),
                      child: child,
                    ),
                  ),
                  child: _loading || jam == null
                      ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
                      : KeyedSubtree(
                          key: ValueKey('board-$_global-$_gen'),
                          child: Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: scheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              // freccia di uscita
                              Positioned(
                                right: 2,
                                top: JamLogic.exitRow * cell + cell * 0.25,
                                child: Icon(Icons.keyboard_double_arrow_right_rounded,
                                    color: Colors.red.shade400, size: cell * 0.5),
                              ),
                              for (var i = 0; i < jam.vehicles.length; i++)
                                _vehicle(i, jam.vehicles[i], cell),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        if (_canOfferSkip) ...[
          HelpButton(
              freeIcon: Icons.skip_next_rounded, label: l.rewardedSkipButton, onPressed: _skip),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: GameButton(
                primary: false,
                onPressed: _load,
                icon: Icons.refresh_rounded,
                label: l.gameRestart,
              ),
            ),
            if (_won && _level < BusJamScreen.levelsPerGroup) ...[
              const SizedBox(width: 12),
              Expanded(
                child: GameButton(
                  onPressed: () => _go(_level + 1),
                  icon: Icons.skip_next_rounded,
                  label: l.gameNextLevel,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _vehicle(int i, JamVehicle v, double cell) {
    final x = v.horizontal ? _pos[i] : v.fixed;
    final y = v.horizontal ? v.fixed : _pos[i];
    final color = i == 0 ? Colors.red.shade600 : _palette[i % _palette.length];
    final exiting = i == 0 && _exited;
    return AnimatedPositioned(
      duration: exiting ? const Duration(milliseconds: 500) : Duration.zero,
      curve: Curves.easeIn,
      left: x * cell + (exiting ? cell * 2.2 : 0),
      top: y * cell,
      width: v.horizontal ? v.len * cell : cell,
      height: v.horizontal ? cell : v.len * cell,
      // Gesti sull'asse del mezzo (come lo scroll della pagina): così i mezzi
      // verticali si trascinano senza far scorrere la schermata.
      child: GestureDetector(
        onHorizontalDragStart: v.horizontal ? (_) => _dragBegin(i) : null,
        onHorizontalDragUpdate: v.horizontal ? (d) => _dragUpdate(i, d, cell) : null,
        onHorizontalDragEnd: v.horizontal ? (_) => _dragEnd(i) : null,
        onVerticalDragStart: v.horizontal ? null : (_) => _dragBegin(i),
        onVerticalDragUpdate: v.horizontal ? null : (d) => _dragUpdate(i, d, cell),
        onVerticalDragEnd: v.horizontal ? null : (_) => _dragEnd(i),
        child: CustomPaint(
          painter: _VehiclePainter(color, v.len, v.horizontal, target: i == 0),
        ),
      ),
    );
  }
}

/// Autobus (3 caselle) e minibus (2 caselle) visti dall'alto: tetto con
/// prese d'aria, parabrezza, fari e ruote. Il bus rosso ha la striscia bianca.
class _VehiclePainter extends CustomPainter {
  final Color color;
  final int len;
  final bool horizontal;
  final bool target;
  _VehiclePainter(this.color, this.len, this.horizontal, {required this.target});

  @override
  void paint(Canvas canvas, Size size) {
    // Si disegna sempre in orizzontale (muso a destra); i verticali sono ruotati.
    final long = horizontal ? size.width : size.height;
    final short = horizontal ? size.height : size.width;
    if (!horizontal) {
      canvas.translate(size.width, 0);
      canvas.rotate(pi / 2);
    }
    final w = long, h = short;
    final dark = Color.lerp(color, Colors.black, 0.35)!;
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(4, h * 0.12, w - 8, h * 0.76), Radius.circular(h * 0.26));

    // ombra
    canvas.drawRRect(body.shift(const Offset(0, 2.5)), Paint()..color = Colors.black26);

    // ruote
    final wheel = Paint()..color = const Color(0xFF1B1B1B);
    final wheelLen = h * 0.3, wheelH = h * 0.1;
    final xs = len == 3 ? [w * 0.16, w * 0.70] : [w * 0.17, w * 0.68];
    for (final x in xs) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, h * 0.06, wheelLen, wheelH), const Radius.circular(2)),
          wheel);
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x, h * 0.94 - wheelH, wheelLen, wheelH), const Radius.circular(2)),
          wheel);
    }

    // carrozzeria
    canvas.drawRRect(body, Paint()..color = color);
    canvas.drawRRect(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = dark);

    // tetto
    final roof = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.09, h * 0.2, w - w * 0.09 - h * 0.62, h * 0.6),
      Radius.circular(h * 0.14),
    );
    canvas.drawRRect(roof, Paint()..color = Colors.white.withOpacity(0.22));

    // prese d'aria sul tetto
    final vents = len == 3 ? 3 : 2;
    final ventPaint = Paint()..color = Colors.white.withOpacity(0.35);
    final roofW = roof.width;
    for (var i = 0; i < vents; i++) {
      final cx = roof.left + roofW * (i + 1) / (vents + 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, h / 2), width: roofW * 0.12, height: h * 0.34),
            const Radius.circular(3)),
        ventPaint,
      );
    }

    // striscia bianca del bus rosso
    if (target) {
      canvas.drawRect(
        Rect.fromLTWH(roof.left + 4, h / 2 - 2, roofW - 8, 4),
        Paint()..color = Colors.white.withOpacity(0.8),
      );
    }

    // parabrezza
    final glass = Path()
      ..moveTo(w - h * 0.56, h * 0.2)
      ..lineTo(w - h * 0.2, h * 0.3)
      ..lineTo(w - h * 0.2, h * 0.7)
      ..lineTo(w - h * 0.56, h * 0.8)
      ..close();
    canvas.drawPath(glass, Paint()..color = const Color(0xFF22303A));
    canvas.drawPath(
        glass,
        Paint()
          ..color = Colors.white.withOpacity(0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1);

    // lunotto
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.045, h * 0.3, h * 0.12, h * 0.4), const Radius.circular(3)),
      Paint()..color = const Color(0xFF22303A),
    );

    // fari
    final light = Paint()..color = const Color(0xFFFFF59D);
    canvas.drawCircle(Offset(w - 8, h * 0.28), h * 0.055, light);
    canvas.drawCircle(Offset(w - 8, h * 0.72), h * 0.055, light);
  }

  @override
  bool shouldRepaint(covariant _VehiclePainter old) =>
      old.color != color || old.len != len || old.horizontal != horizontal || old.target != target;
}
