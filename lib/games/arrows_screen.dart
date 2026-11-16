import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../services/game_sound.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/arrows_logic.dart';

/// Frecce: tocca le frecce per farle uscire dal tabellone, ma la loro strada
/// deve essere libera. Tre vite: un tocco su una freccia bloccata ne toglie una.
/// I livelli sono infiniti e in sequenza, per ogni difficoltà.
class ArrowsScreen extends StatefulWidget {
  final Difficulty difficulty;
  const ArrowsScreen({super.key, this.difficulty = Difficulty.easy});

  static const lives = 3;

  /// Livello da cui si riparte per la difficoltà.
  static int levelFor(Difficulty d) => GameStats.instance.value('arrows_level_${d.name}', 1);

  @override
  State<ArrowsScreen> createState() => _ArrowsScreenState();
}

class _ArrowsScreenState extends State<ArrowsScreen> with TickerProviderStateMixin {
  late int _levelNo;
  late ArrowsLevel _level;
  late List<bool> _removed;
  int _lives = ArrowsScreen.lives;
  bool _won = false;
  bool _revived = false; // una sola vita extra per livello
  int _gen = 0;

  // Animazioni: frecce che stanno uscendo e freccia bloccata che "sbatte".
  final Map<int, AnimationController> _exiting = {};
  AnimationController? _bump;
  int? _bumpIdx;
  int _bumpFree = 0;

  bool get _lost => _lives <= 0;
  int get _left => _removed.where((r) => !r).length;

  @override
  void initState() {
    super.initState();
    _levelNo = ArrowsScreen.levelFor(widget.difficulty);
    _load();
  }

  @override
  void dispose() {
    _clearAnimations();
    super.dispose();
  }

  void _clearAnimations() {
    for (final c in _exiting.values) {
      c.dispose();
    }
    _exiting.clear();
    _bump?.dispose();
    _bump = null;
    _bumpIdx = null;
  }

  void _load() {
    _clearAnimations();
    _level = ArrowsLogic.generate(widget.difficulty.index, _levelNo);
    _removed = List<bool>.filled(_level.arrows.length, false);
    _lives = ArrowsScreen.lives;
    _won = false;
    _revived = false;
    _gen++;
  }

  void _restart() => setState(_load);

  void _next() => setState(() {
        _levelNo++;
        _load();
      });

  /// Una sola vita in più per livello, in cambio di una pubblicità
  /// (gratis per gli abbonati e sul sito).
  Future<void> _offerRevive() async {
    if (_revived || !_lost || _won || !mounted || !RewardedOffer.available) return;
    final gen = _gen;
    final l = AppLocalizations.of(context)!;
    final ok = await RewardedOffer.ask(context,
        game: 'arrows',
        action: 'revive',
        title: l.rewardedReviveTitle,
        message: l.rewardedArrowsMessage);
    if (!ok || !mounted || gen != _gen) return;
    setState(() {
      _lives = 1;
      _revived = true;
    });
  }

  int? _arrowAt(Offset p, double side) {
    final n = _level.n;
    final cell = side / n;
    // la freccia più vicina al tocco (entro poco più di mezza casella)
    int? best;
    var bestD = cell * 0.75;
    for (var i = 0; i < _level.arrows.length; i++) {
      if (_removed[i]) continue;
      for (final c in _level.arrows[i].cells) {
        final d = (Offset((c % n + 0.5) * cell, (c ~/ n + 0.5) * cell) - p).distance;
        if (d < bestD) {
          bestD = d;
          best = i;
        }
      }
    }
    return best;
  }

  Future<void> _tap(Offset p, double side) async {
    if (_won || _lost) return;
    final i = _arrowAt(p, side);
    if (i == null) return;
    final free = _level.blockedAfter(i, _removed);
    if (free != null) {
      // strada sbarrata: la freccia sbatte e si perde una vita
      HapticFeedback.heavyImpact();
      GameSound.instance.play(Sfx.wrong);
      _bump?.dispose();
      final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
      setState(() {
        _bump = c;
        _bumpIdx = i;
        _bumpFree = free;
        _lives--;
      });
      c.forward().whenCompleteOrCancel(() {
        if (mounted && _bump == c) setState(() => _bumpIdx = null);
      });
      if (_lost) {
        // finite le vite: propone la pubblicità per averne una sola
        await Future<void>.delayed(const Duration(milliseconds: 600));
        _offerRevive();
      }
      return;
    }
    HapticFeedback.selectionClick();
    GameSound.instance.play(Sfx.flip);
    final a = _level.arrows[i];
    final c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 220 + 45 * (a.cells.length + _level.ray(i).length)),
    );
    setState(() {
      _removed[i] = true;
      _exiting[i] = c;
    });
    final gen = _gen;
    c.forward().whenCompleteOrCancel(() {
      if (!mounted || gen != _gen) return;
      setState(() => _exiting.remove(i)?.dispose());
    });
    if (_left == 0) {
      await GameStats.instance.setValue('arrows_level_${widget.difficulty.name}', _levelNo + 1);
      await GameStats.instance.submitHigh('arrows_${widget.difficulty.name}', _levelNo);
      if (mounted && gen == _gen) setState(() => _won = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return GameScaffold(
      title: l.gameArrows,
      celebrate: _won,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(difficultyLabel(l, widget.difficulty).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: scheme.onSurfaceVariant)),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(l.gameLevel(_levelNo),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            Semantics(
              label: '$_lives / ${ArrowsScreen.lives}',
              child: Row(
                children: [
                  for (var i = 0; i < ArrowsScreen.lives; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: i < _lives ? Colors.red.shade600 : scheme.outline,
                        size: 26,
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(l.gameArrowsLeft(_left)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(key: ValueKey('won-$_gen'), text: l.gameLevelDone, kind: ResultKind.win)
              : _lost
                  ? ResultBanner(key: ValueKey('lost-$_gen'), text: l.gameYouLose, kind: ResultKind.lose)
                  : Text(l.gameArrowsHint,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        LayoutBuilder(builder: (context, box) {
          final side = min(box.maxWidth, 460.0);
          return Center(
            child: GestureDetector(
              onTapUp: (d) => _tap(d.localPosition, side),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: side,
                  height: side,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([..._exiting.values, if (_bump != null) _bump!]),
                    builder: (context, _) => CustomPaint(
                      painter: _ArrowsPainter(
                        level: _level,
                        removed: _removed,
                        exiting: {
                          for (final e in _exiting.entries)
                            e.key: Curves.easeIn.transform(e.value.value)
                        },
                        bumpIdx: _bumpIdx,
                        bump: _bump?.value ?? 0,
                        bumpFree: _bumpFree,
                        bg: scheme.surfaceContainerHighest,
                        ink: scheme.onSurface,
                        go: scheme.primary,
                        bad: Colors.red.shade600,
                        gen: _gen,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        if (_lost && !_revived && RewardedOffer.available) ...[
          HelpButton(
              freeIcon: Icons.favorite_rounded,
              label: l.rewardedArrowsButton,
              onPressed: _offerRevive),
          const SizedBox(height: 10),
        ],
        if (_won)
          GameButton(onPressed: _next, icon: Icons.arrow_forward_rounded, label: l.gameNextLevel)
        else
          GameButton(
            primary: _lost,
            onPressed: _restart,
            icon: Icons.refresh_rounded,
            label: l.gameRestart,
          ),
      ],
    );
  }
}

class _ArrowsPainter extends CustomPainter {
  final ArrowsLevel level;
  final List<bool> removed;
  final Map<int, double> exiting; // indice → avanzamento 0..1
  final int? bumpIdx;
  final double bump;
  final int bumpFree;
  final Color bg, ink, go, bad;
  final int gen;
  _ArrowsPainter({
    required this.level,
    required this.removed,
    required this.exiting,
    required this.bumpIdx,
    required this.bump,
    required this.bumpFree,
    required this.bg,
    required this.ink,
    required this.go,
    required this.bad,
    required this.gen,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = level.n;
    final cell = size.width / n;
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    // puntini della griglia
    final dot = Paint()..color = ink.withOpacity(0.10);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        canvas.drawCircle(Offset((x + 0.5) * cell, (y + 0.5) * cell), cell * 0.045, dot);
      }
    }
    for (var i = 0; i < level.arrows.length; i++) {
      final out = exiting[i];
      if (removed[i] && out == null) continue;
      final a = level.arrows[i];
      final len = a.cells.length - 1; // lunghezza in caselle
      // Di quanto è avanzata lungo la sua strada (in caselle).
      var shift = 0.0;
      var color = ink;
      if (out != null) {
        shift = out * (len + n + 1.5);
        color = go;
      } else if (i == bumpIdx) {
        // va avanti fin dove può (al massimo un po') e torna indietro
        shift = sin(bump * pi) * min(bumpFree + 0.32, 0.8);
        color = Color.lerp(bad, ink, Curves.easeIn.transform(bump))!;
      }
      _arrow(canvas, a, n, cell, shift, color);
    }
  }

  /// Punto a distanza [t] (in caselle) dalla coda, lungo il corpo e poi dritto.
  Offset _at(Arrow a, int n, double cell, double t) {
    final last = a.cells.length - 1;
    Offset c(int k) => Offset((k % n + 0.5) * cell, (k ~/ n + 0.5) * cell);
    if (t >= last) {
      return c(a.head) + Offset(a.dx * cell, a.dy * cell) * (t - last);
    }
    final i = t.floor();
    return Offset.lerp(c(a.cells[i]), c(a.cells[i + 1]), t - i)!;
  }

  void _arrow(Canvas canvas, Arrow a, int n, double cell, double shift, Color color) {
    final last = a.cells.length - 1;
    final from = shift, to = shift + last;
    final path = Path();
    final start = _at(a, n, cell, from);
    path.moveTo(start.dx, start.dy);
    for (var k = from.floor() + 1; k < to; k++) {
      final p = _at(a, n, cell, k.toDouble());
      path.lineTo(p.dx, p.dy);
    }
    final tip = _at(a, n, cell, to);
    // direzione della punta: quella dell'ultimo tratto percorso
    final before = _at(a, n, cell, max(from, to - 0.5));
    var dir = tip - before;
    dir = dir.distance == 0 ? Offset(a.dx.toDouble(), a.dy.toDouble()) : dir / dir.distance;
    final head = cell * 0.30;
    final neck = tip - dir * (head * 0.6);
    path.lineTo(neck.dx, neck.dy);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(2.0, cell * 0.13)
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    final nrm = Offset(-dir.dy, dir.dx);
    final front = tip + dir * (head * 0.45);
    final back = tip - dir * (head * 0.75);
    canvas.drawPath(
      Path()
        ..moveTo(front.dx, front.dy)
        ..lineTo((back + nrm * head * 0.72).dx, (back + nrm * head * 0.72).dy)
        ..lineTo((back - nrm * head * 0.72).dx, (back - nrm * head * 0.72).dy)
        ..close(),
      Paint()
        ..color = color
        ..style = PaintingStyle.fill
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ArrowsPainter old) => true;
}
