import 'dart:math';
import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';

/// Una pagina del tutorial: illumina le zone [targets] (oscurando il resto),
/// con frecce dal riquadro di testo verso ognuna.
enum TutorialScroll {
  /// Torna in cima alla pagina (zone dell'intestazione).
  top,

  /// Porta la zona al centro dello schermo (zone in fondo alla pagina).
  center,

  /// Scorre solo il minimo perché la zona si veda.
  minimal,
}

class TutorialStep {
  final List<GlobalKey> targets;
  final String title;
  final String text;

  /// Come portare la zona in vista scorrendo la pagina sotto.
  final TutorialScroll scroll;
  const TutorialStep(
      {required this.targets,
      required this.title,
      required this.text,
      this.scroll = TutorialScroll.minimal});
}

class AppTutorial {
  /// Mostra il tutorial sopra la schermata corrente (che resta visibile sotto,
  /// così le zone da illuminare si misurano dai suoi widget).
  static Future<void> show(BuildContext context, List<TutorialStep> steps) {
    return Navigator.of(context, rootNavigator: true).push(PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, __, ___) => _TutorialPage(steps: steps),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }
}

class _TutorialPage extends StatefulWidget {
  final List<TutorialStep> steps;
  const _TutorialPage({required this.steps});

  @override
  State<_TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<_TutorialPage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
        ..repeat(reverse: true);
  final _cardKey = GlobalKey();
  int _i = 0;
  List<Rect> _rects = const [];
  Rect? _card;
  int _token = 0; // l'ultima misura vince

  @override
  void initState() {
    super.initState();
    _measure(0);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Porta in vista la zona del passo [i] (scorrendo la pagina sotto) e la misura.
  Future<void> _measure(int i) async {
    final token = ++_token;
    final live = [
      for (final k in widget.steps[i].targets)
        if (k.currentContext != null) k
    ];
    if (live.isNotEmpty) {
      try {
        final ctx = live.first.currentContext!;
        switch (widget.steps[i].scroll) {
          case TutorialScroll.top:
            final pos = Scrollable.maybeOf(ctx)?.position;
            if (pos != null && pos.pixels != pos.minScrollExtent) {
              await pos.animateTo(pos.minScrollExtent,
                  duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
            }
          case TutorialScroll.center:
            await Scrollable.ensureVisible(ctx,
                alignment: 0.5,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut);
          case TutorialScroll.minimal:
            await Scrollable.ensureVisible(ctx,
                alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut);
        }
      } catch (_) {}
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted || token != _token) return;
    final rects = <Rect>[];
    for (final k in live) {
      final box = k.currentContext?.findRenderObject();
      if (box is RenderBox && box.attached && box.hasSize) {
        rects.add(box.localToGlobal(Offset.zero) & box.size);
      }
    }
    setState(() {
      _i = i;
      _rects = rects;
    });
  }

  void _next() {
    if (_i + 1 >= widget.steps.length) {
      Navigator.of(context).pop();
    } else {
      setState(() => _rects = const []);
      _measure(_i + 1);
    }
  }

  void _close() => Navigator.of(context).pop();

  void _readCard() {
    final box = _cardKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.attached && box.hasSize) {
      final r = box.localToGlobal(Offset.zero) & box.size;
      if (_card == null || (_card!.top - r.top).abs() > 0.5 || (_card!.height - r.height).abs() > 0.5) {
        setState(() => _card = r);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final step = widget.steps[_i];
    final last = _i == widget.steps.length - 1;
    final union = _rects.isEmpty ? null : _rects.reduce((a, b) => a.expandToInclude(b));
    // Il testo sta nella metà dello schermo opposta alla zona illuminata.
    final cardAtTop = union != null && union.center.dy > media.size.height * 0.55;
    WidgetsBinding.instance.addPostFrameCallback((_) => mounted ? _readCard() : null);
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Sfondo scuro con le "finestre" illuminate: assorbe anche i tocchi.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: AnimatedBuilder(
                animation: _pulse,
                builder: (context, _) => CustomPaint(
                  painter: _SpotlightPainter(
                    rects: _rects,
                    card: _card,
                    cardAtTop: cardAtTop,
                    pulse: Curves.easeInOut.transform(_pulse.value),
                    glow: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: cardAtTop ? media.padding.top + 16 : null,
            bottom: cardAtTop ? null : media.padding.bottom + 20,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Container(
                  key: _cardKey,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(step.title,
                                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
                          ),
                          Text('${_i + 1}/${widget.steps.length}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurfaceVariant)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(step.text,
                          style: TextStyle(fontSize: 15, height: 1.4, color: scheme.onSurface)),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (!last)
                            TextButton(
                              onPressed: _close,
                              child: Text(l.tutorialSkip),
                            ),
                          const Spacer(),
                          Row(
                            children: [
                              for (var k = 0; k < widget.steps.length; k++)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  width: k == _i ? 18 : 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: k == _i ? scheme.primary : scheme.outlineVariant,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(96, 48),
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            onPressed: _next,
                            child: Text(last ? l.tutorialDone : l.tutorialNext),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final List<Rect> rects;
  final Rect? card;
  final bool cardAtTop;
  final double pulse;
  final Color glow;
  _SpotlightPainter({
    required this.rects,
    required this.card,
    required this.cardAtTop,
    required this.pulse,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final holes = [
      for (final r in rects)
        RRect.fromRectAndRadius(
            r.inflate(6), Radius.circular(min(20.0, (r.height + 12) / 2))),
    ];
    var scrim = Path()..addRect(Offset.zero & size);
    for (final h in holes) {
      scrim = Path.combine(PathOperation.difference, scrim, Path()..addRRect(h));
    }
    canvas.drawPath(scrim, Paint()..color = const Color(0x99000000));
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = glow.withOpacity(0.55 + 0.4 * pulse);
    for (final h in holes) {
      canvas.drawRRect(h, ring);
    }
    final c = card;
    if (c == null) return;
    // Prima i punti d'arrivo, poi le partenze dal riquadro di testo nello
    // stesso ordine da sinistra a destra: così le frecce non si incrociano.
    final dir = Offset(0, cardAtTop ? 1 : -1);
    final ends = <Offset>[];
    for (var i = 0; i < rects.length; i++) {
      final r = rects[i].inflate(6);
      if (rects.length == 1) {
        // Una sola zona: la freccia ne tocca il bordo.
        final ex = rects[i].center.dx.clamp(r.left + 16, r.right - 16).toDouble();
        ends.add(Offset(ex, cardAtTop ? r.top - 4 : r.bottom + 4) - dir * (pulse * 5));
      } else {
        // Più zone (anche una sopra l'altra): ognuna punta dentro la sua.
        final wide = rects[i].width > 200;
        // le zone larghe, in ordine, puntano a x diverse (la prima più a destra)
        final wideRank = rects.take(i).where((x) => x.width > 200).length;
        final ex = wide
            ? rects[i].left + rects[i].width * (0.80 - 0.2 * wideRank)
            : rects[i].center.dx;
        ends.add(Offset(ex, rects[i].center.dy + (cardAtTop ? -1 : 1) * rects[i].height * 0.12) -
            dir * (pulse * 5));
      }
    }
    final order = List<int>.generate(rects.length, (i) => i)
      ..sort((a, b) => ends[a].dx.compareTo(ends[b].dx));
    for (var slot = 0; slot < order.length; slot++) {
      final i = order[slot];
      final sx = (c.left + 36 + (c.width - 72) * (slot + 1) / (rects.length + 1))
          .clamp(c.left + 24, c.right - 24)
          .toDouble();
      final start = Offset(sx, cardAtTop ? c.bottom + 4 : c.top - 4);
      final end = ends[i];
      if ((end - start).distance < 18) continue;
      final ctrl = Offset(start.dx, (start.dy + end.dy) / 2);
      final ctrl2 = Offset(end.dx, (start.dy + end.dy) / 2);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(ctrl.dx, ctrl.dy, ctrl2.dx, ctrl2.dy, end.dx, end.dy);
      // contorno scuro + tratto bianco: si vede sia sullo scuro sia sulle zone chiare
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7.5
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xCC000000),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round
          ..color = Colors.white,
      );
      // punta della freccia, nella direzione dell'ultimo tratto
      final tangent = end - ctrl2;
      final d = tangent.distance == 0 ? dir : tangent / tangent.distance;
      final n = Offset(-d.dy, d.dx);
      final tip = end + d * 3;
      final back = end - d * 13;
      final head = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo((back + n * 9).dx, (back + n * 9).dy)
        ..lineTo((back - n * 9).dx, (back - n * 9).dy)
        ..close();
      canvas.drawPath(
          head,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4
            ..strokeJoin = StrokeJoin.round
            ..color = const Color(0xCC000000));
      canvas.drawPath(head, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter old) => true;
}
