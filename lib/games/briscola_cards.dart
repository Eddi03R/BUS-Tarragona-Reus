import 'dart:math';
import 'package:flutter/material.dart';
import 'logic/briscola_logic.dart';

const _suitColors = [Color(0xFFC62828), Color(0xFFE0A100), Color(0xFF1E5AA8), Color(0xFF2E7D32)];

Color briscolaSuitColor(int suit) => _suitColors[suit];

/// Simbolo di un seme (0 coppe, 1 denari, 2 spade, 3 bastoni) in un quadrato
/// di lato [s] centrato in [ctr]. Stile delle carte trevigiane: coppa a calice,
/// denaro con il sole, sciabola curva, bastone nodoso.
void paintSuit(Canvas c, int suit, Offset ctr, double s) {
  final col = _suitColors[suit];
  final fill = Paint()..color = col;
  final dark = Paint()..color = Color.lerp(col, Colors.black, 0.4)!;
  Paint stroke(Paint p, double w) => Paint()
    ..color = p.color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round;
  c.save();
  c.translate(ctr.dx, ctr.dy);
  c.scale(s);
  switch (suit) {
    case 0: // coppa: calice con bordo, nodo e piede
      final bowl = Path()
        ..moveTo(-.4, -.34)
        ..lineTo(.4, -.34)
        ..cubicTo(.4, .02, .2, .16, 0, .16)
        ..cubicTo(-.2, .16, -.4, .02, -.4, -.34)
        ..close();
      c.drawPath(bowl, fill);
      c.drawOval(const Rect.fromLTWH(-.4, -.4, .8, .12), dark);
      c.drawRect(const Rect.fromLTWH(-.04, .16, .08, .16), dark);
      c.drawCircle(const Offset(0, .24), .07, fill);
      c.drawOval(const Rect.fromLTWH(-.24, .3, .48, .12), dark);
      c.drawPath(
          Path()
            ..moveTo(-.26, -.22)
            ..quadraticBezierTo(-.24, -.02, -.1, .06),
          stroke(Paint()..color = Colors.white54, .035));
    case 1: // denaro: moneta con il sole al centro
      c.drawCircle(Offset.zero, .44, dark);
      c.drawCircle(Offset.zero, .39, fill);
      c.drawCircle(Offset.zero, .3, stroke(dark, .035));
      for (var i = 0; i < 8; i++) {
        final a = i * pi / 4;
        c.drawLine(Offset(cos(a) * .14, sin(a) * .14), Offset(cos(a) * .25, sin(a) * .25), stroke(dark, .04));
      }
      c.drawCircle(Offset.zero, .11, dark);
    case 2: // spada: sciabola curva con elsa
      final blade = Path()
        ..moveTo(0, .2)
        ..quadraticBezierTo(-.24, -.08, .2, -.46);
      c.drawPath(blade, stroke(fill, .15));
      c.drawPath(blade.shift(const Offset(-.02, 0)), stroke(Paint()..color = Colors.white60, .02));
      c.save();
      c.translate(0, .2);
      c.rotate(-.35);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.2, -.035, .4, .07), const Radius.circular(.03)), dark);
      c.restore();
      c.drawLine(const Offset(0, .22), const Offset(0, .38), stroke(dark, .07));
      c.drawCircle(const Offset(0, .42), .055, dark);
    case 3: // bastone nodoso in diagonale
      c.rotate(.6);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.12, -.46, .24, .92), const Radius.circular(.12)), fill);
      c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-.07, -.4, .045, .8), const Radius.circular(.02)),
          Paint()..color = Colors.white30);
      for (final y in const [-.26, .02, .28]) {
        c.drawOval(Rect.fromCenter(center: Offset(0, y), width: .28, height: .09), dark);
      }
  }
  c.restore();
}

String _rankLabel(int r) => '$r';

void _text(Canvas c, String t, Offset center, double size, Color color) {
  final tp = TextPainter(
    text: TextSpan(text: t, style: TextStyle(fontSize: size, fontWeight: FontWeight.w900, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
}

/// Posizioni (in unità di larghezza carta, dal centro) e grandezza dei semi per le carte 1-7.
(List<Offset>, double) _pips(int rank) => switch (rank) {
      1 => (const [Offset(0, 0)], .66),
      2 => (const [Offset(0, -.34), Offset(0, .34)], .4),
      3 => (const [Offset(0, -.4), Offset(0, 0), Offset(0, .4)], .34),
      4 => (const [Offset(-.19, -.3), Offset(.19, -.3), Offset(-.19, .3), Offset(.19, .3)], .35),
      5 => (const [Offset(-.19, -.3), Offset(.19, -.3), Offset(0, 0), Offset(-.19, .3), Offset(.19, .3)], .33),
      6 => (const [Offset(-.19, -.4), Offset(.19, -.4), Offset(-.19, 0), Offset(.19, 0), Offset(-.19, .4), Offset(.19, .4)], .31),
      _ => (const [Offset(-.19, -.4), Offset(.19, -.4), Offset(0, -.2), Offset(-.19, 0), Offset(.19, 0), Offset(-.19, .4), Offset(.19, .4)], .29),
    };

/// Figura di Fante (8), Cavallo (9) o Re (10), semplificata, dentro un riquadro centrato in (0,0).
void _paintFigure(Canvas c, int rank, int suit, double w) {
  final col = _suitColors[suit];
  final fill = Paint()..color = col;
  final dark = Paint()..color = Color.lerp(col, Colors.black, 0.4)!;
  final skin = Paint()..color = const Color(0xFFF2C79B);
  final gold = Paint()..color = const Color(0xFFE0A100);
  final ink = Paint()..color = const Color(0xFF3B2A20);
  final panel = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w * .62, height: w * 1.0), Radius.circular(w * .05));
  c.drawRRect(panel, Paint()..color = col.withOpacity(.12));
  c.drawRRect(panel, Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w * .015
    ..color = col.withOpacity(.55));
  c.save();
  c.translate(0, -w * .06);
  c.scale(w);
  switch (rank) {
    case 8: // fante: ragazzo in piedi con berretto e piuma
      c.drawRect(const Rect.fromLTWH(-.07, .18, .06, .2), ink);
      c.drawRect(const Rect.fromLTWH(.01, .18, .06, .2), ink);
      c.drawPath(
          Path()
            ..moveTo(-.12, -.02)
            ..lineTo(.12, -.02)
            ..lineTo(.15, .22)
            ..lineTo(-.15, .22)
            ..close(),
          fill);
      c.drawRect(const Rect.fromLTWH(-.15, .1, .3, .04), gold);
      c.drawCircle(const Offset(0, -.12), .085, skin);
      c.drawPath(
          Path()
            ..moveTo(-.1, -.15)
            ..quadraticBezierTo(0, -.3, .1, -.15)
            ..close(),
          dark);
      c.drawPath(
          Path()
            ..moveTo(.06, -.22)
            ..quadraticBezierTo(.2, -.34, .16, -.4),
          Paint()
            ..color = const Color(0xFFFFFFFF)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .03
            ..strokeCap = StrokeCap.round);
      c.drawLine(const Offset(.12, .02), const Offset(.2, .14), Paint()
        ..color = ink.color
        ..strokeWidth = .025);
    case 9: // cavallo: cavallo con cavaliere
      c.drawOval(const Rect.fromLTWH(-.2, .02, .36, .18), Paint()..color = const Color(0xFF8D5A3B));
      c.drawPath(
          Path()
            ..moveTo(.1, .06)
            ..lineTo(.2, -.12)
            ..lineTo(.3, -.1)
            ..lineTo(.28, -.02)
            ..lineTo(.2, .0)
            ..lineTo(.16, .14)
            ..close(),
          Paint()..color = const Color(0xFF8D5A3B));
      c.drawCircle(const Offset(.26, -.07), .015, Paint()..color = Colors.white);
      for (final x in const [-.17, -.09, .06, .13]) {
        c.drawRect(Rect.fromLTWH(x, .17, .03, .2), ink);
      }
      c.drawPath(
          Path()
            ..moveTo(-.2, .06)
            ..quadraticBezierTo(-.3, .12, -.28, .24),
          Paint()
            ..color = ink.color
            ..style = PaintingStyle.stroke
            ..strokeWidth = .03);
      c.drawRect(const Rect.fromLTWH(-.08, -.12, .12, .16), fill); // cavaliere
      c.drawCircle(const Offset(-.02, -.2), .06, skin);
      c.drawPath(
          Path()
            ..moveTo(-.09, -.22)
            ..lineTo(.05, -.22)
            ..lineTo(-.02, -.32)
            ..close(),
          dark);
      c.drawLine(const Offset(.06, -.12), const Offset(.2, -.34), Paint()
        ..color = ink.color
        ..strokeWidth = .025);
    default: // re: sovrano con corona, barba e mantello
      c.drawPath(
          Path()
            ..moveTo(-.1, -.04)
            ..lineTo(.1, -.04)
            ..lineTo(.2, .38)
            ..lineTo(-.2, .38)
            ..close(),
          fill);
      c.drawRect(const Rect.fromLTWH(-.02, -.04, .04, .42), Paint()..color = Colors.white70);
      c.drawRect(const Rect.fromLTWH(-.19, .3, .38, .06), Paint()..color = Colors.white);
      c.drawCircle(const Offset(0, -.13), .09, skin);
      c.drawPath(
          Path()
            ..moveTo(-.08, -.1)
            ..quadraticBezierTo(0, .12, .08, -.1)
            ..close(),
          Paint()..color = const Color(0xFFE8E8E8));
      c.drawPath(
          Path()
            ..moveTo(-.1, -.2)
            ..lineTo(-.1, -.33)
            ..lineTo(-.05, -.26)
            ..lineTo(0, -.36)
            ..lineTo(.05, -.26)
            ..lineTo(.1, -.33)
            ..lineTo(.1, -.2)
            ..close(),
          gold);
      c.drawLine(const Offset(.17, .0), const Offset(.17, .3), Paint()
        ..color = gold.color
        ..strokeWidth = .03);
      c.drawCircle(const Offset(.17, -.02), .04, gold);
  }
  c.restore();
  paintSuit(c, suit, Offset(0, w * .38), w * .2);
}

/// Faccia di una carta dentro [r]: indice con seme negli angoli, semi in
/// numero pari al valore (1-7), figura per Fante, Cavallo e Re.
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
  c.save();
  c.translate(r.center.dx, r.center.dy);
  if (card.rank >= 8) {
    _paintFigure(c, card.rank, card.suit, w);
  } else {
    final (pos, size) = _pips(card.rank);
    for (final o in pos) {
      paintSuit(c, card.suit, o * w, size * w);
    }
  }
  // indici negli angoli (alto a sinistra e, ruotato, in basso a destra)
  for (var k = 0; k < 2; k++) {
    c.save();
    if (k == 1) c.rotate(pi);
    final tl = Offset(-r.width / 2 + w * .17, -r.height / 2 + w * .15);
    _text(c, _rankLabel(card.rank), tl, w * .2, col);
    paintSuit(c, card.suit, tl + Offset(0, w * .2), w * .16);
    c.restore();
  }
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
