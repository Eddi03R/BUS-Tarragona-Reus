import 'dart:math';
import 'package:flutter/material.dart';
import 'logic/briscola_logic.dart';

/// Carte trevigiane: rosso, blu e giallo su fondo crema, contorni scuri.
/// Le coordinate dei disegni sono in "larghezze di carta" (1 = larghezza),
/// con l'origine al centro; l'altezza della carta è [briscolaRatio].
const double briscolaRatio = 1.7;

const _red = Color(0xFFC8372D);
const _blue = Color(0xFF2B4C9B);
const _yel = Color(0xFFEDB92B);
const _ink = Color(0xFF2A2320);
const _skin = Color(0xFFF0C69C);
const _cream = Color(0xFFF8F3E5);

Paint _p(Color c) => Paint()..color = c;
Paint _line(Color c, double w) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round;

/// Disegna [path] riempito e con il contorno scuro.
void _shape(Canvas c, Path path, Color fill, [double ink = .02]) {
  c.drawPath(path, _p(fill));
  c.drawPath(path, _line(_ink, ink));
}

void _circle(Canvas c, Offset o, double r, Color fill, [double ink = .02]) {
  c.drawCircle(o, r, _p(fill));
  c.drawCircle(o, r, _line(_ink, ink));
}

/// Bastone a fasce rosse e blu con i nodi gialli, centrato in [o] e ruotato di [angle].
void _stick(Canvas c, Offset o, double len, double th, double angle) {
  c.save();
  c.translate(o.dx, o.dy);
  c.rotate(angle);
  final body = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: th, height: len), Radius.circular(th / 2));
  c.drawRRect(body, _p(_red));
  c.save();
  c.clipRRect(body);
  const bands = 6;
  for (var i = 1; i < bands; i += 2) {
    c.drawRect(Rect.fromLTWH(-th, -len / 2 + len / bands * i, th * 2, len / bands), _p(_blue));
  }
  c.restore();
  c.drawRRect(body, _line(_ink, .018));
  for (final y in [-len / 2 + th * .3, 0.0, len / 2 - th * .3]) {
    _circle(c, Offset(0, y), th * .5, _yel, .016);
  }
  c.restore();
}

/// Sciabola curva da [base] a [tip]; [bow] la piega della lama, [s] lo spessore.
void _saber(Canvas c, Offset base, Offset tip, double bow, double s) {
  final mid = Offset.lerp(base, tip, .5)!;
  final d = tip - base;
  final n = Offset(-d.dy, d.dx) / d.distance;
  final ctl = mid + n * bow;
  final blade = Path()
    ..moveTo(base.dx, base.dy)
    ..quadraticBezierTo(ctl.dx, ctl.dy, tip.dx, tip.dy);
  c.drawPath(blade, _line(_ink, s * 1.5));
  c.drawPath(blade, _line(const Color(0xFF6C8FD0), s));
  c.drawPath(blade.shift(Offset(-s * .2, 0)), _line(Colors.white70, s * .2));
  // elsa: traversa gialla, impugnatura rossa e pomolo
  final t = (ctl - base) / (ctl - base).distance;
  final perp = Offset(-t.dy, t.dx);
  c.drawLine(base - perp * s * 2.2, base + perp * s * 2.2, _line(_ink, s * .9));
  c.drawLine(base - perp * s * 2.2, base + perp * s * 2.2, _line(_yel, s * .55));
  final grip = base - t * s * 3.4;
  c.drawLine(base, grip, _line(_ink, s * 1.0));
  c.drawLine(base, grip, _line(_red, s * .65));
  _circle(c, grip - t * s * .5, s * .5, _yel, s * .15);
}

/// Simbolo singolo di un seme (0 coppe, 1 denari, 2 spade, 3 bastoni) in un
/// quadrato di lato [s] centrato in [ctr]: serve per gli assi, i semi piccoli
/// delle figure e dell'indice, e per le carte di coppe e denari.
void paintSuit(Canvas c, int suit, Offset ctr, double s) {
  c.save();
  c.translate(ctr.dx, ctr.dy);
  c.scale(s);
  switch (suit) {
    case 0: // coppa: calice con piede esagonale
      final foot = Path()
        ..moveTo(-.24, .4)
        ..lineTo(-.16, .3)
        ..lineTo(.16, .3)
        ..lineTo(.24, .4)
        ..lineTo(.16, .47)
        ..lineTo(-.16, .47)
        ..close();
      _shape(c, foot, _yel, .03);
      c.drawRect(const Rect.fromLTWH(-.045, .15, .09, .17), _p(_blue));
      _circle(c, const Offset(0, .22), .07, _red, .025);
      final bowl = Path()
        ..moveTo(-.42, -.36)
        ..lineTo(.42, -.36)
        ..cubicTo(.42, .0, .22, .17, 0, .17)
        ..cubicTo(-.22, .17, -.42, .0, -.42, -.36)
        ..close();
      c.drawPath(bowl, _p(_red));
      c.save();
      c.clipPath(bowl);
      c.drawRect(const Rect.fromLTWH(-.14, -.4, .28, .6), _p(_blue));
      c.restore();
      c.drawPath(bowl, _line(_ink, .03));
      final rim = Path()..addRect(const Rect.fromLTWH(-.44, -.43, .88, .08));
      _shape(c, rim, _yel, .03);
    case 1: // denaro: moneta con il fiore al centro
      _circle(c, Offset.zero, .45, _yel, .035);
      for (var i = 0; i < 12; i++) {
        final a0 = i * pi / 6, a1 = a0 + pi / 6;
        final petal = Path()
          ..moveTo(cos(a0) * .12, sin(a0) * .12)
          ..lineTo(cos(a0) * .34, sin(a0) * .34)
          ..lineTo(cos(a1) * .34, sin(a1) * .34)
          ..lineTo(cos(a1) * .12, sin(a1) * .12)
          ..close();
        _shape(c, petal, i.isEven ? _red : _blue, .015);
      }
      _circle(c, Offset.zero, .1, _yel, .025);
    case 2: // spada: sciabola curva
      _saber(c, const Offset(.02, .3), const Offset(.12, -.48), -.22, .1);
    case 3: // bastone
      _stick(c, Offset.zero, .98, .22, .5);
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

/// Carte 2-7: simboli in colonna, facili da contare (posizioni in larghezze di
/// carta dal centro, e grandezza del simbolo).
(List<Offset>, double) _pips(int rank) => switch (rank) {
      2 => (const [Offset(0, -.38), Offset(0, .38)], .48),
      3 => (const [Offset(0, -.44), Offset(0, 0), Offset(0, .44)], .4),
      4 => (const [Offset(-.2, -.32), Offset(.2, -.32), Offset(-.2, .32), Offset(.2, .32)], .38),
      5 => (const [Offset(-.2, -.34), Offset(.2, -.34), Offset(0, 0), Offset(-.2, .34), Offset(.2, .34)], .32),
      6 => (const [Offset(-.2, -.44), Offset(.2, -.44), Offset(-.2, 0), Offset(.2, 0), Offset(-.2, .44), Offset(.2, .44)], .3),
      _ => (const [Offset(-.2, -.44), Offset(.2, -.44), Offset(0, -.22), Offset(-.2, 0), Offset(.2, 0), Offset(-.2, .44), Offset(.2, .44)], .28),
    };

/// Colore del seme: serve per il pallino dell'indice (coppe rosse, denari oro, spade blu, bastoni verdi).
const _suitColors = [Color(0xFFD32F2F), Color(0xFFE0A100), Color(0xFF2F6DB5), Color(0xFF3E8E41)];

/// Figura di Fante, Cavallo o Re in un riquadro largo .56 e alto .74 centrato
/// in (0,0); sulla carta si ingrandisce di 1,5 volte.
void _halfFigure(Canvas c, int rank, int suit) {
  void split(Path body, [Color left = _red, Color right = _blue]) {
    c.drawPath(body, _p(left));
    c.save();
    c.clipPath(body);
    c.drawRect(const Rect.fromLTWH(0, -.5, .5, 1.2), _p(right));
    c.restore();
    c.drawPath(body, _line(_ink, .015));
  }

  switch (rank) {
    case 8: // fante: in piedi con berretto e piuma
      c.drawRect(const Rect.fromLTWH(-.095, .18, .08, .17), _p(_red));
      c.drawRect(const Rect.fromLTWH(.015, .18, .08, .17), _p(_blue));
      c.drawRect(const Rect.fromLTWH(-.095, .18, .19, .17), _line(_ink, .012));
      split(Path()
        ..moveTo(-.13, -.05)
        ..lineTo(.13, -.05)
        ..lineTo(.17, .2)
        ..lineTo(-.17, .2)
        ..close());
      c.drawRect(const Rect.fromLTWH(-.17, .1, .34, .04), _p(_yel));
      _circle(c, const Offset(0, -.13), .08, _skin, .014);
      _shape(
          c,
          Path()
            ..moveTo(-.11, -.16)
            ..quadraticBezierTo(0, -.34, .11, -.16)
            ..close(),
          _blue,
          .014);
      c.drawPath(
          Path()
            ..moveTo(.05, -.27)
            ..quadraticBezierTo(.2, -.36, .17, -.3),
          _line(_red, .03));
      paintSuit(c, suit, const Offset(-.2, .0), .24);
    case 9: // cavallo: cavaliere in sella
      final horse = Paint()..color = const Color(0xFFF1EDE0);
      c.drawOval(const Rect.fromLTWH(-.2, .08, .38, .17), horse);
      c.drawOval(const Rect.fromLTWH(-.2, .08, .38, .17), _line(_ink, .014));
      final neck = Path()
        ..moveTo(.1, .12)
        ..lineTo(.16, -.06)
        ..lineTo(.27, -.04)
        ..lineTo(.25, .04)
        ..lineTo(.19, .05)
        ..lineTo(.17, .16)
        ..close();
      c.drawPath(neck, horse);
      c.drawPath(neck, _line(_ink, .014));
      for (final x in const [-.17, -.1, .06, .13]) {
        c.drawLine(Offset(x, .22), Offset(x, .35), _line(_ink, .022));
      }
      c.drawPath(
          Path()
            ..moveTo(-.2, .12)
            ..quadraticBezierTo(-.3, .2, -.27, .32),
          _line(_ink, .03));
      split(Path()
        ..moveTo(-.07, -.12)
        ..lineTo(.05, -.12)
        ..lineTo(.06, .1)
        ..lineTo(-.08, .1)
        ..close());
      _circle(c, const Offset(-.01, -.17), .055, _skin, .013);
      _shape(
          c,
          Path()
            ..moveTo(-.07, -.19)
            ..lineTo(.05, -.19)
            ..lineTo(-.01, -.3)
            ..close(),
          _red,
          .013);
      c.drawLine(const Offset(.06, -.04), const Offset(.2, -.32), _line(_ink, .02));
      paintSuit(c, suit, const Offset(-.2, -.22), .2);
    default: // re: corona, barba, mantello
      split(Path()
        ..moveTo(-.12, -.05)
        ..lineTo(.12, -.05)
        ..lineTo(.2, .35)
        ..lineTo(-.2, .35)
        ..close());
      c.drawRect(const Rect.fromLTWH(-.2, .27, .4, .06), _p(Colors.white));
      c.drawRect(const Rect.fromLTWH(-.2, .27, .4, .06), _line(_ink, .012));
      _circle(c, const Offset(0, -.13), .085, _skin, .014);
      _shape(
          c,
          Path()
            ..moveTo(-.075, -.11)
            ..quadraticBezierTo(0, .13, .075, -.11)
            ..close(),
          const Color(0xFFEDEDED),
          .012);
      _shape(
          c,
          Path()
            ..moveTo(-.1, -.2)
            ..lineTo(-.1, -.34)
            ..lineTo(-.05, -.27)
            ..lineTo(0, -.37)
            ..lineTo(.05, -.27)
            ..lineTo(.1, -.34)
            ..lineTo(.1, -.2)
            ..close(),
          _yel,
          .013);
      c.drawLine(const Offset(.22, -.02), const Offset(.22, .3), _line(_ink, .03));
      c.drawLine(const Offset(.22, -.02), const Offset(.22, .3), _line(_yel, .018));
      _circle(c, const Offset(.22, -.04), .035, _yel, .012);
      paintSuit(c, suit, const Offset(-.21, .1), .24);
  }
}

/// Faccia di una carta dentro [r]: pallino colorato col numero negli angoli,
/// simboli in colonna (2-7), asso a tutta carta, una figura grande (8-10).
void paintBriscolaCard(Canvas c, Rect r, BCard card) {
  final w = r.width;
  final rr = RRect.fromRectAndRadius(r, Radius.circular(w * .08));
  c.drawRRect(rr.shift(Offset(0, w * .02)), _p(Colors.black26));
  c.drawRRect(rr, _p(_cream));
  c.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .02
        ..color = const Color(0xFFBFB59A));
  c.save();
  c.translate(r.center.dx, r.center.dy);
  c.scale(w);
  final h = r.height / w;
  if (card.rank == 1) {
    paintSuit(c, card.suit, Offset.zero, .84);
  } else if (card.rank >= 8) {
    c.save();
    c.translate(0, -.04);
    c.scale(1.5);
    _halfFigure(c, card.rank, card.suit);
    c.restore();
    paintSuit(c, card.suit, Offset(0, h / 2 - .2), .22);
  } else {
    final (pos, size) = _pips(card.rank);
    for (final o in pos) {
      paintSuit(c, card.suit, o, size);
    }
  }
  // indici negli angoli (alto a sinistra e, ruotato, in basso a destra)
  for (var k = 0; k < 2; k++) {
    c.save();
    if (k == 1) c.rotate(pi);
    final tl = Offset(-.5 + .16, -h / 2 + .18);
    _circle(c, tl, .12, _suitColors[card.suit], .015);
    c.save();
    c.scale(1 / w); // il testo si disegna in pixel
    _text(c, _rankLabel(card.rank), tl * w, w * (card.rank == 10 ? .14 : .16), Colors.white);
    c.restore();
    paintSuit(c, card.suit, tl + const Offset(0, .24), .17);
    c.restore();
  }
  c.restore();
}

void paintBriscolaBack(Canvas c, Rect r) {
  final w = r.width;
  final rr = RRect.fromRectAndRadius(r, Radius.circular(w * .08));
  c.drawRRect(rr.shift(Offset(0, w * .02)), _p(Colors.black26));
  c.drawRRect(rr, _p(_blue));
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
        ..color = _yel);
}

class BriscolaCardView extends StatelessWidget {
  final BCard? card; // null = dorso
  final double width;
  const BriscolaCardView({super.key, required this.card, required this.width});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(width, width * briscolaRatio),
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
