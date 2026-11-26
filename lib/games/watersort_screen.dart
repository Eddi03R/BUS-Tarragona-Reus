import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'rewarded_offer.dart';
import 'logic/watersort_logic.dart';
import '../services/game_sound.dart';

const _liquid = [
  Color(0xFFE53935),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFDD835),
  Color(0xFF8E24AA),
  Color(0xFFFB8C00),
  Color(0xFF00ACC1),
  Color(0xFFEC407A),
];

/// Disposizione delle provette: stessa per il disegno e per i tocchi.
@visibleForTesting
class WaterSortLayout {
  static const topPad = 74.0, bottomPad = 30.0, rowGap = 36.0, gap = 14.0, sidePad = 12.0;

  static int cols(int n) => n <= 6 ? 3 : (n + 1) ~/ 2;
  static double tubeWidth(double w, int n) => min(54.0, (w - 2 * sidePad - (cols(n) - 1) * gap) / cols(n));
  static double tubeHeight(double w, int n) => 4 * 33.0 + 16;
  static double boardHeight(double w, int n) {
    final rows = (n / cols(n)).ceil();
    return topPad + rows * tubeHeight(w, n) + (rows - 1) * rowGap + bottomPad;
  }

  /// Rettangolo (a riposo) di ogni provetta.
  static List<Rect> rects(Size size, int n) {
    final c = cols(n), tw = tubeWidth(size.width, n), th = tubeHeight(size.width, n);
    final out = <Rect>[];
    for (var i = 0; i < n; i++) {
      final row = i ~/ c, inRow = min(c, n - row * c), col = i - row * c;
      final rowW = inRow * tw + (inRow - 1) * gap;
      final x0 = (size.width - rowW) / 2 + col * (tw + gap);
      out.add(Rect.fromLTWH(x0, topPad + row * (th + rowGap), tw, th));
    }
    return out;
  }
}

class _Pour {
  final int from, to, count, color;
  const _Pour(this.from, this.to, this.count, this.color);
}

/// Travasa i colori: tocca una provetta e poi un'altra per versare; vinci
/// quando ogni provetta contiene un solo colore.
class WaterSortScreen extends StatefulWidget {
  final Difficulty difficulty;
  const WaterSortScreen({super.key, this.difficulty = Difficulty.easy});

  @override
  State<WaterSortScreen> createState() => WaterSortScreenState();
}

class WaterSortScreenState extends State<WaterSortScreen> with SingleTickerProviderStateMixin {
  final _rand = Random();
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late List<List<int>> _start;
  late List<List<int>> _tubes;
  final List<List<List<int>>> _undo = [];
  int? _sel;
  _Pour? _pour;
  int _moves = 0;
  bool _won = false, _newRecord = false;
  bool _extraTube = false; // aiuto con pubblicità già usato in questa partita

  @visibleForTesting
  List<List<int>> get tubes => _tubes;
  @visibleForTesting
  bool get busy => _pour != null;

  int get _d => widget.difficulty.index;
  String get _key => 'watersort_${widget.difficulty.name}';

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _load(List<List<int>> t) {
    _ac.stop();
    setState(() {
      _pour = null;
      _start = t;
      _tubes = [for (final x in t) List<int>.of(x)];
      _undo.clear();
      _sel = null;
      _moves = 0;
      _won = _newRecord = false;
      _extraTube = false;
    });
  }

  void _newGame() => _load(WaterSortLogic.generate(_d, _rand));
  void _restart() => _load(_start);

  Future<void> _tap(int i) async {
    if (_won || _pour != null) return;
    final s = _sel;
    if (s == null) {
      if (_tubes[i].isNotEmpty) {
        GameSound.instance.play(Sfx.glass);
        setState(() => _sel = i);
      }
      return;
    }
    if (s == i) {
      setState(() => _sel = null);
      return;
    }
    if (!WaterSortLogic.canPour(_tubes, s, i)) {
      // se è un'altra provetta con qualcosa, la nuova selezione sostituisce la vecchia
      HapticFeedback.selectionClick();
      if (_tubes[i].isNotEmpty) GameSound.instance.play(Sfx.glass);
      setState(() => _sel = _tubes[i].isNotEmpty ? i : null);
      return;
    }
    final color = _tubes[s].last;
    var n = 0;
    while (n < _tubes[s].length && _tubes[s][_tubes[s].length - 1 - n] == color && _tubes[i].length + n < WaterSortLogic.cap) {
      n++;
    }
    _undo.add([for (final x in _tubes) List<int>.of(x)]);
    setState(() {
      _pour = _Pour(s, i, n, color);
      _sel = null;
    });
    GameSound.instance.play(Sfx.pour, delay: const Duration(milliseconds: 330));
    await _ac.forward(from: 0);
    if (!mounted) return;
    final next = WaterSortLogic.pour(_tubes, s, i);
    final win = WaterSortLogic.isSolved(next);
    final tubeDone = next[i].length == WaterSortLogic.cap && next[i].every((c) => c == color);
    var record = false;
    if (win) record = await GameStats.instance.submitBest(_key, _moves + 1);
    if (!mounted) return;
    if (tubeDone && !win) GameSound.instance.play(Sfx.tubeDone);
    setState(() {
      _tubes = next;
      _pour = null;
      _moves++;
      if (win) {
        _won = true;
        _newRecord = record;
      }
    });
  }

  void _undoMove() {
    if (_undo.isEmpty || _won || _pour != null) return;
    setState(() {
      _tubes = _undo.removeLast();
      _sel = null;
      _moves = max(0, _moves - 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final best = GameStats.instance.best(_key);
    return GameScaffold(
      title: l.gameWaterSort,
      celebrate: _won,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(l.gameMoves(_moves),
                  overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            Text(best == null ? l.gameNoRecord : l.gameBestMoves(best)),
          ],
        ),
        const SizedBox(height: 8),
        StatusSlot(
          child: _won
              ? ResultBanner(
                  key: const ValueKey('ww'),
                  text: _newRecord ? '${l.gameYouWin} 🏆' : l.gameYouWin,
                  kind: ResultKind.win)
              : Text(l.gameWaterSortHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -1),
                radius: 1.3,
                colors: [Color(0xFF17517A), Color(0xFF0B2F4C), Color(0xFF071B2E)],
                stops: [0, 0.55, 1],
              ),
            ),
            child: LayoutBuilder(builder: (context, c) {
              final size = Size(c.maxWidth, WaterSortLayout.boardHeight(c.maxWidth, _tubes.length));
              final rects = WaterSortLayout.rects(size, _tubes.length);
              return GestureDetector(
                key: const ValueKey('ws-board'),
                behavior: HitTestBehavior.opaque,
                onTapUp: (d) {
                  for (var i = 0; i < rects.length; i++) {
                    if (rects[i].inflate(8).contains(d.localPosition)) {
                      _tap(i);
                      return;
                    }
                  }
                },
                child: SizedBox(
                  width: size.width,
                  height: size.height,
                  child: CustomPaint(
                    painter: _BoardPainter(_tubes, rects, _sel, _pour, _ac),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 22),
        if (!_won) ...[
          if (!_extraTube && _pour == null)
            HintButton(
              game: 'watersort',
              onGranted: () => setState(() {
                // una provetta vuota in più (anche negli stati da cui si può annullare)
                _tubes.add([]);
                for (final u in _undo) {
                  u.add([]);
                }
                _extraTube = true;
              }),
            ),
          GameButton(
            primary: false,
            onPressed: _undo.isEmpty ? null : _undoMove,
            icon: Icons.undo_rounded,
            label: l.wsUndo,
          ),
          const SizedBox(height: 10),
          GameButton(primary: false, onPressed: _restart, icon: Icons.replay_rounded, label: l.wsRestart),
          const SizedBox(height: 10),
        ],
        GameButton(primary: _won, onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
      ],
    );
  }
}

class _BoardPainter extends CustomPainter {
  final List<List<int>> tubes;
  final List<Rect> rects;
  final int? selected;
  final _Pour? pour;
  final Animation<double> anim;
  _BoardPainter(this.tubes, this.rects, this.selected, this.pour, this.anim) : super(repaint: anim);

  static const double _tilt = 62 * pi / 180;

  static double _ease(double t) => t <= 0 ? 0 : (t >= 1 ? 1 : t * t * (3 - 2 * t));

  @override
  void paint(Canvas canvas, Size size) {
    final p = pour;
    final t = anim.value;
    // fasi: 0-.22 la provetta si alza e si inclina, .22-.78 si versa, .78-1 torna
    final move = p == null ? 0.0 : (t < .22 ? _ease(t / .22) : (t > .78 ? 1 - _ease((t - .78) / .22) : 1.0));
    final q = p == null ? 0.0 : ((t - .22) / .56).clamp(0.0, 1.0);

    // provette a riposo (la sorgente si disegna per ultima, sopra le altre)
    for (var i = 0; i < tubes.length; i++) {
      if (p != null && i == p.from) continue;
      var units = tubes[i].length.toDouble();
      if (p != null && i == p.to) units += p.count * _ease(q);
      final lift = selected == i ? -14.0 : 0.0;
      final colors = p != null && i == p.to ? [...tubes[i], ...List.filled(p.count, p.color)] : tubes[i];
      _tube(canvas, rects[i].shift(Offset(0, lift)), colors, units, glow: selected == i, done: _isDone(i, p), shadow: true);
      if (p != null && i == p.to && q > 0 && q < 1) _bubbles(canvas, rects[i], units, p.color, q);
    }
    if (p != null) {
      final r = rects[p.from], d = rects[p.to];
      final dir = d.center.dx >= size.width / 2 ? 1.0 : -1.0; // il corpo si inclina verso il centro
      final w = r.width;
      final pivotEnd = Offset(d.center.dx - dir * (w / 2) * cos(_tilt), d.top - 28 - (w / 2) * sin(_tilt));
      final pivotStart = Offset(r.center.dx, r.top);
      final pivot = Offset.lerp(pivotStart, pivotEnd, move)!;
      final angle = dir * _tilt * move;
      final units = tubes[p.from].length - p.count * _ease(q);
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(angle);
      _tube(canvas, Rect.fromLTWH(-w / 2, 0, w, r.height), tubes[p.from], units.toDouble(), shadow: false);
      canvas.restore();
      if (q > 0 && q < 1) {
        // filo di liquido dal bordo della provetta inclinata al livello della provetta che riceve
        final lip = pivot + Offset(dir * (w / 2) * cos(angle.abs()), (w / 2) * sin(angle.abs()));
        final unitH = (d.height - 16) / WaterSortLogic.cap;
        final level = d.bottom - 6 - (tubes[p.to].length + p.count * _ease(q)) * unitH;
        final width = 6.0 * (q < .1 ? q / .1 : (q > .9 ? (1 - q) / .1 : 1.0));
        final paint = Paint()
          ..color = _liquid[p.color]
          ..strokeWidth = max(1.0, width)
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(Offset(d.center.dx, lip.dy), Offset(d.center.dx, level), paint);
        if (lip.dx != d.center.dx) canvas.drawLine(lip, Offset(d.center.dx, lip.dy + 4), paint);
      }
    }
  }

  bool _isDone(int i, _Pour? p) {
    if (p != null && (i == p.from || i == p.to)) return false;
    final t = tubes[i];
    return t.length == WaterSortLogic.cap && t.every((c) => c == t.first);
  }

  void _bubbles(Canvas canvas, Rect r, double units, int color, double q) {
    final unitH = (r.height - 16) / WaterSortLogic.cap;
    final surface = r.bottom - 6 - units * unitH;
    final paint = Paint();
    for (var k = 0; k < 6; k++) {
      final ph = (q * 3 + k * .17) % 1;
      final x = r.left + 10 + ((k * 37) % 100) / 100 * (r.width - 20);
      paint.color = Colors.white.withOpacity((1 - ph) * .7);
      canvas.drawCircle(Offset(x, surface + 4 - ph * 34), 2.6 + (k % 3) * .6, paint);
    }
  }

  /// Una provetta di vetro con [units] unità di liquido (anche frazionarie).
  void _tube(Canvas canvas, Rect r, List<int> colors, double units,
      {bool glow = false, bool done = false, bool shadow = true}) {
    final w = r.width, h = r.height;
    final path = Path()
      ..addRRect(RRect.fromRectAndCorners(r,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
          bottomLeft: Radius.circular(w / 2),
          bottomRight: Radius.circular(w / 2)));
    if (shadow) {
      canvas.drawOval(Rect.fromLTWH(r.left + 4, r.bottom + 4, w - 8, 9), Paint()
        ..color = Colors.black.withOpacity(.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
    if (glow) {
      canvas.drawPath(path, Paint()
        ..color = Colors.white.withOpacity(.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8));
    }
    canvas.drawPath(path, Paint()
      ..shader = LinearGradient(colors: [
        Colors.white.withOpacity(.18),
        Colors.white.withOpacity(.04),
        Colors.white.withOpacity(.1),
      ], stops: const [0, .4, 1]).createShader(r));
    // liquido
    canvas.save();
    canvas.clipPath(path);
    final unitH = (h - 16) / WaterSortLogic.cap;
    for (var k = 0; k < colors.length; k++) {
      final top = min(k + 1.0, units);
      final bottom = k.toDouble();
      if (top <= bottom) continue;
      final y1 = r.bottom - 6 - top * unitH, y0 = r.bottom - 6 - bottom * unitH + (k == 0 ? 8 : 0);
      final c = _liquid[colors[k]];
      final box = Rect.fromLTRB(r.left, y1, r.right, y0);
      canvas.drawRect(box, Paint()
        ..shader = LinearGradient(colors: [c, Color.lerp(c, Colors.black, .12)!, Color.lerp(c, Colors.black, .3)!]).createShader(box));
      canvas.drawRect(Rect.fromLTRB(r.left, y1, r.right, y1 + 3.5), Paint()..color = Colors.white.withOpacity(.35));
    }
    canvas.restore();
    // riflesso e bordo
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(r.left + 6, r.top + 10, 5, h - 38), const Radius.circular(3)),
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Colors.white.withOpacity(.7),
            Colors.white.withOpacity(.05),
          ]).createShader(Rect.fromLTWH(r.left, r.top, 11, h)));
    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.55));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(r.left - 4, r.top - 3, w + 8, 9), const Radius.circular(5)), Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.7));
    if (done) {
      final tp = TextPainter(
        text: const TextSpan(text: '✓', style: TextStyle(color: Color(0xFF9CF0B3), fontSize: 20, fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(r.center.dx - tp.width / 2, r.top - 28));
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter old) => true;
}
