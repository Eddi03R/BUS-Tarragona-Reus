import 'dart:math';
import 'package:flutter/material.dart';
import 'logic/briscola_logic.dart';

const _suitColors = [Color(0xFFC62828), Color(0xFFE0A100), Color(0xFF1E5AA8), Color(0xFF2E7D32)];

Color briscolaSuitColor(int suit) => _suitColors[suit];

/// Simbolo di un seme (0 coppe, 1 denari, 2 spade, 3 bastoni) in un quadrato
/// di lato [s] centrato in [ctr].
void paintSuit(Canvas c, int suit, Offset ctr, double s) {
  final col = _suitColors[suit];
  final fill = Paint()..color = col;
  final dark = Paint()..color = Color.lerp(col, Colors.black, 0.35)!;
  c.save();
  c.translate(ctr.dx, ctr.dy);
  c.scale(s);
  switch (suit) {
    case 0: // coppa
      final bowl = Path()
        ..moveTo(-.38, -.3)
        ..lineTo(.38, -.3)
        ..cubicTo(.38, .05, .18, .2, 0, .2)
        ..cubicTo(-.18, .2, -.38, .05, -.38, -.3)
        ..close();
      c.drawPath(bowl, fill);
      c.drawRect(const Rect.fromLTWH(-.045, .2, .09, .14), fill);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.22, .33, .44, .08), const Radius.circular(.03)), fill);
      c.drawRect(const Rect.fromLTWH(-.38, -.3, .76, .06), dark);
    case 1: // denaro
      c.drawCircle(Offset.zero, .42, dark);
      c.drawCircle(Offset.zero, .36, fill);
      c.drawCircle(
          Offset.zero,
          .22,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = .05
            ..color = dark.color);
      c.drawCircle(Offset.zero, .08, dark);
    case 2: // spada
      c.rotate(.5);
      final blade = Path()
        ..moveTo(0, -.46)
        ..lineTo(.08, -.34)
        ..lineTo(.08, .12)
        ..lineTo(-.08, .12)
        ..lineTo(-.08, -.34)
        ..close();
      c.drawPath(blade, fill);
      c.drawRect(const Rect.fromLTWH(-.02, -.4, .04, .5), Paint()..color = Colors.white54);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.24, .12, .48, .07), const Radius.circular(.03)), dark);
      c.drawRect(const Rect.fromLTWH(-.035, .19, .07, .17), dark);
      c.drawCircle(const Offset(0, .4), .055, dark);
    case 3: // bastoni incrociati
      for (final a in const [-.55, .55]) {
        c.save();
        c.rotate(a);
        c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.07, -.46, .14, .92), const Radius.circular(.07)), fill);
        c.drawCircle(const Offset(0, -.2), .045, dark);
        c.drawCircle(const Offset(0, .12), .045, dark);
        c.restore();
      }
  }
  c.restore();
}

String _rankLabel(int r) => switch (r) { 1 => 'A', 8 => 'F', 9 => 'C', 10 => 'R', _ => '$r' };

void _text(Canvas c, String t, Offset center, double size, Color color) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

/// Faccia di una carta dentro [r].
void paintBriscolaCard(Canvas c, Rect r, BCard card) {
  final w = r.width;
  final rr = RRect.fromRectAndRadius(r, Radius.circular(w * .09));
  c.drawRRect(rr.shift(Offset(0, w * .02)), Paint()..color = Colors.black26);
  c.drawRRect(rr, Paint()..color = const Color(0xFFFBF6E9));
  c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .02
        ..color = const Color(0xFFBFB59A));
  final col = _suitColors[card.suit];
  paintSuit(c, card.suit, r.center, w * .62);
  _text(c, _rankLabel(card.rank), r.topLeft + Offset(w * .17, w * .17), w * .22, col);
  c.save();
  c.translate(r.center.dx, r.center.dy);
  c.rotate(pi);
  _text(c, _rankLabel(card.rank), Offset(-r.width / 2 + w * .17, -r.height / 2 + w * .17), w * .22, col);
  c.restore();
}

void paintBriscolaBack(Canvas c, Rect r) {
  final w = r.width;
  final rr = RRect.fromRectAndRadius(r, Radius.circular(w * .09));
  c.drawRRect(rr.shift(Offset(0, w * .02)), Paint()..color = Colors.black26);
  c.drawRRect(rr, Paint()..color = const Color(0xFF0F7A5F));
  c.save();
  c.clipRRect(rr.deflate(w * .06));
  final line = Paint()
    ..color = Colors.white24
    ..strokeWidth = w * .02;
  for (var i = -8; i < 20; i++) {
    final x = r.left + i * w * .16;
    c.drawLine(Offset(x, r.top), Offset(x + r.height, r.bottom), line);
    c.drawLine(Offset(x + r.height, r.top), Offset(x, r.bottom), line);
  }
  c.restore();
  c.drawRRect(
      rr.deflate(w * .06),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .025
        ..color = Colors.white70);
}

class BriscolaCardView extends StatelessWidget {
  final BCard? card; // null = dorso
  final double width;
  const BriscolaCardView({super.key, required this.card, required this.width});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width * 1.55),
        painter: _CardPainter(card),
      );
}

class _CardPainter extends CustomPainter {
  final BCard? card;
  _CardPainter(this.card);
  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    if (card == null) {
      paintBriscolaBack(canvas, r);
    } else {
      paintBriscolaCard(canvas, r, card!);
    }
  }

  @override
  bool shouldRepaint(covariant _CardPainter old) => old.card != card;
}

class BriscolaSuitIcon extends StatelessWidget {
  final int suit;
  final double size;
  const BriscolaSuitIcon({super.key, required this.suit, required this.size});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _SuitPainter(suit));
}

class _SuitPainter extends CustomPainter {
  final int suit;
  _SuitPainter(this.suit);
  @override
  void paint(Canvas canvas, Size size) => paintSuit(canvas, suit, size.center(Offset.zero), size.width);
  @override
  bool shouldRepaint(covariant _SuitPainter old) => old.suit != suit;
}
