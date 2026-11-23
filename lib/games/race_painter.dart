import 'dart:math';
import 'package:flutter/material.dart';

/// Ambientazioni della corsa: giorno sulla costa e notte in città.
class RaceTheme {
  final List<Color> sky;
  final Color hill, far, sea, grassA, grassB, roadA, roadB, rumA, rumB, line, bus, busAccent, tail;
  final List<Color> cars;
  final bool night;
  const RaceTheme({
    required this.sky,
    required this.hill,
    required this.far,
    required this.sea,
    required this.grassA,
    required this.grassB,
    required this.roadA,
    required this.roadB,
    required this.rumA,
    required this.rumB,
    required this.line,
    required this.bus,
    required this.busAccent,
    required this.tail,
    required this.cars,
    required this.night,
  });

  static const day = RaceTheme(
    sky: [Color(0xFF7CC8F2), Color(0xFFD9F1FB)],
    hill: Color(0xFF5FAE8A),
    far: Color(0xFF2F9BC7),
    sea: Color(0xFF3BB0D8),
    grassA: Color(0xFF7BC86C),
    grassB: Color(0xFF6FBD60),
    roadA: Color(0xFF6B7280),
    roadB: Color(0xFF737A88),
    rumA: Colors.white,
    rumB: Color(0xFFE5484D),
    line: Colors.white,
    bus: Color(0xFF0F7A5F),
    busAccent: Colors.white,
    tail: Color(0xFFFF3B3B),
    cars: [Color(0xFFE5484D), Color(0xFFF5A524), Color(0xFF2F6FED), Color(0xFF9B5DE5), Color(0xFFFFFFFF)],
    night: false,
  );

  static const nightCity = RaceTheme(
    sky: [Color(0xFF10062B), Color(0xFF6A1B9A)],
    hill: Color(0xFF1B0F3D),
    far: Color(0xFF2A1056),
    sea: Color(0xFF1B0F3D),
    grassA: Color(0xFF150A33),
    grassB: Color(0xFF1A0D3C),
    roadA: Color(0xFF2B2A3D),
    roadB: Color(0xFF313048),
    rumA: Color(0xFF00E5FF),
    rumB: Color(0xFFFF2BD6),
    line: Color(0xFFFFE66D),
    bus: Color(0xFF00C2A8),
    busAccent: Color(0xFFFFE66D),
    tail: Color(0xFFFF2244),
    cars: [Color(0xFFFF2BD6), Color(0xFF00E5FF), Color(0xFFFFE66D), Color(0xFF8A5CFF), Color(0xFFFF6B6B)],
    night: true,
  );
}

/// Un'auto sulla strada: [d] distanza davanti al bus (1 = affiancata), [lane] corsia (-1, 0, 1).
class RaceCar {
  double d;
  final int lane;
  final int color;
  final double speed; // più lenta del bus: la raggiungi e la superi
  bool passed = false;
  RaceCar(this.d, this.lane, this.color, this.speed);
}

/// Posizione sul mondo → quanto curva la strada.
double raceCurve(double world) => sin(world * .09) * .55 + sin(world * .035) * .35;

/// Strada vista da dietro, in pseudo-3D. [roadPos] = quanta strada è passata.
class RacePainter extends CustomPainter {
  final RaceTheme t;
  final double roadPos, busX;
  final List<RaceCar> cars;
  final bool showBus;
  RacePainter(this.t, this.roadPos, this.busX, this.cars, this.showBus);

  static const lane = .55; // larghezza di una corsia rispetto alla mezza strada

  Color _shade(Color c, double k) => Color.lerp(c, k < 0 ? Colors.black : Colors.white, k.abs())!;

  void _rr(Canvas c, double x, double y, double w, double h, double r, Color col) =>
      c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)), Paint()..color = col);

  @override
  void paint(Canvas c, Size size) {
    final W = size.width, H = size.height, hy = H * .38;
    c.save();
    c.clipRect(Offset.zero & size);
    // cielo
    c.drawRect(
        Rect.fromLTWH(0, 0, W, hy + 2),
        Paint()
          ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: t.sky)
              .createShader(Rect.fromLTWH(0, 0, W, hy)));
    final p = Paint();
    if (t.night) {
      p.color = Colors.white;
      for (var i = 0; i < 40; i++) {
        p.color = Colors.white.withOpacity(.3 + ((i * 13) % 7) / 12);
        c.drawRect(Rect.fromLTWH((i * 97) % W, (i * 53) % (hy * .7), 2, 2), p);
      }
      p.color = const Color(0xFFFFD9F6);
      c.drawCircle(Offset(W * .78, hy * .32), W * .045, p);
      for (var i = 0; i < 14; i++) {
        final bw = W / 14, bh = hy * (.18 + ((i * 29) % 10) / 30);
        p.color = t.far;
        c.drawRect(Rect.fromLTWH(i * bw, hy - bh, bw - 3, bh), p);
        p.color = const Color(0xFFFFE66D);
        for (var k = 0; k < 5; k++) {
          if ((i * 5 + k) % 3 != 0) c.drawRect(Rect.fromLTWH(i * bw + 6 + (k % 2) * 10, hy - bh + 8 + k * 14, 4, 6), p);
        }
      }
    } else {
      p.color = const Color(0xFFFFF7C2);
      c.drawCircle(Offset(W * .22, hy * .45), W * .055, p);
      p.color = Colors.white.withOpacity(.8);
      for (final o in const [[.6, .22, .05], [.72, .28, .04], [.35, .3, .035]]) {
        c.drawCircle(Offset(W * o[0], hy * o[1] * 2), W * o[2], p);
        c.drawCircle(Offset(W * (o[0] + .05), hy * o[1] * 2 + 4), W * o[2] * .8, p);
      }
      p.color = t.sea;
      c.drawRect(Rect.fromLTWH(0, hy - hy * .08, W, hy * .08 + 2), p);
      final hill = Path()..moveTo(0, hy);
      for (var x = 0.0; x <= W; x += 20) {
        hill.lineTo(x, hy - hy * .14 - sin(x * .012 + 1) * hy * .07);
      }
      hill
        ..lineTo(W, hy)
        ..close();
      c.drawPath(hill, Paint()..color = t.hill);
    }

    final rows = H - hy;
    double half(double y) => W * .04 + (y - hy) / rows * W * .62;
    double cx(double y) {
      final q = (y - hy) / rows, z = 1 / (q + .02);
      return W / 2 + raceCurve(z + roadPos) * (1 - q) * (1 - q) * W * .55;
    }

    for (var y = hy.floorToDouble(); y < H; y += 2) {
      final q = (y - hy) / rows, z = 1 / (q + .02);
      final s = (((z + roadPos) * 1.2).floor() & 1) == 1;
      final x = cx(y), hw = half(y);
      c.drawRect(Rect.fromLTWH(0, y, W, 2), p..color = s ? t.grassA : t.grassB);
      c.drawRect(Rect.fromLTWH(x - hw * 1.14, y, hw * 2.28, 2), p..color = s ? t.rumA : t.rumB);
      c.drawRect(Rect.fromLTWH(x - hw, y, hw * 2, 2), p..color = s ? t.roadA : t.roadB);
      if (s) {
        final lw = max(1.0, hw * .03);
        p.color = t.line;
        for (final k in const [-.33, .33]) {
          c.drawRect(Rect.fromLTWH(x + hw * k - lw, y, lw * 2, 2), p);
        }
      }
    }

    // lampioni / palme e auto, dal fondo al davanti
    final items = <(double, int, RaceCar?)>[];
    for (var i = 0; i < 10; i++) {
      final d = ((i * 1.6 - roadPos) % 16 + 16) % 16 + 1;
      items.add((d, i.isEven ? -1 : 1, null));
    }
    for (final car in cars) {
      items.add((car.d, car.lane, car));
    }
    items.sort((a, b) => b.$1.compareTo(a.$1));
    for (final (d, side, car) in items) {
      final q = 1.05 / (d + .02);
      if (q < .03 || q > 1.8) continue;
      final y = hy + q * rows, x = cx(y), hw = half(y);
      if (car == null) {
        final px = x + side * hw * 1.45, sz = q * W * .5;
        if (t.night) {
          c.drawRect(Rect.fromLTWH(px - sz * .02, y - sz * .45, sz * .04, sz * .45), p..color = const Color(0xFF2A2A45));
          c.drawCircle(Offset(px, y - sz * .47), sz * .05 * 2.2, p..color = const Color(0x33FFD166));
          c.drawCircle(Offset(px, y - sz * .47), sz * .05, p..color = const Color(0xFFFFE9A8));
        } else {
          c.drawRect(Rect.fromLTWH(px - sz * .02, y - sz * .4, sz * .04, sz * .4), p..color = const Color(0xFF8A5A3B));
          p.color = const Color(0xFF2F9E44);
          for (var a = 0; a < 5; a++) {
            c.save();
            c.translate(px + cos(a * 1.26) * sz * .09, y - sz * .42 + sin(a * 1.26) * sz * .04);
            c.rotate(a * 1.26);
            c.drawOval(Rect.fromCenter(center: Offset.zero, width: sz * .2, height: sz * .06), p);
            c.restore();
          }
        }
      } else {
        _car(c, x + car.lane * lane * hw, y, q * W * .30, t.cars[car.color % t.cars.length]);
      }
    }
    if (showBus) {
      final yb = H * .9;
      _bus(c, cx(yb) + busX * lane * half(yb), yb, W * .26);
    }
    c.restore();
  }

  void _car(Canvas c, double x, double y, double w, Color col) {
    final h = w * .62;
    c.save();
    c.translate(x, y);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 1.1, height: w * .18), Paint()..color = Colors.black26);
    _rr(c, -w * .5, -h * .28, w * .16, h * .3, w * .03, const Color(0xFF111111));
    _rr(c, w * .34, -h * .28, w * .16, h * .3, w * .03, const Color(0xFF111111));
    _rr(c, -w * .5, -h * .75, w, h * .52, w * .08, col);
    _rr(c, -w * .36, -h * 1.08, w * .72, h * .42, w * .1, _shade(col, -.18));
    _rr(c, -w * .3, -h * 1.0, w * .6, h * .3, w * .06, t.night ? const Color(0xFF1C2340) : const Color(0xFFCFE8F5));
    if (t.night) {
      _rr(c, -w * .5, -h * .66, w * .28, h * .2, w * .05, t.tail.withOpacity(.3));
      _rr(c, w * .22, -h * .66, w * .28, h * .2, w * .05, t.tail.withOpacity(.3));
    }
    _rr(c, -w * .46, -h * .62, w * .22, h * .12, w * .03, t.tail);
    _rr(c, w * .24, -h * .62, w * .22, h * .12, w * .03, t.tail);
    _rr(c, -w * .5, -h * .3, w, h * .07, w * .03, Colors.black26);
    c.restore();
  }

  void _bus(Canvas c, double x, double y, double w) {
    final h = w * .95;
    c.save();
    c.translate(x, y);
    c.drawOval(Rect.fromCenter(center: Offset.zero, width: w * 1.2, height: w * .2), Paint()..color = Colors.black38);
    _rr(c, -w * .46, -h * .3, w * .17, h * .32, w * .03, const Color(0xFF0D0D10));
    _rr(c, w * .29, -h * .3, w * .17, h * .32, w * .03, const Color(0xFF0D0D10));
    _rr(c, -w * .5, -h * 1.0, w, h * .8, w * .12, t.bus);
    _rr(c, -w * .5, -h * 1.0, w, h * .14, w * .12, Colors.white24);
    _rr(c, -w * .4, -h * .9, w * .8, h * .36, w * .07, t.night ? const Color(0xFF14213A) : const Color(0xFFD6EEF7));
    final glare = Path()
      ..moveTo(-w * .3, -h * .9)
      ..lineTo(-w * .12, -h * .9)
      ..lineTo(-w * .28, -h * .54)
      ..lineTo(-w * .4, -h * .54)
      ..close();
    c.drawPath(glare, Paint()..color = Colors.white38);
    _rr(c, -w * .5, -h * .5, w, h * .07, 0, t.busAccent);
    if (t.night) {
      _rr(c, -w * .5, -h * .43, w * .28, h * .18, w * .05, t.tail.withOpacity(.3));
      _rr(c, w * .22, -h * .43, w * .28, h * .18, w * .05, t.tail.withOpacity(.3));
    }
    _rr(c, -w * .46, -h * .4, w * .2, h * .12, w * .03, t.tail);
    _rr(c, w * .26, -h * .4, w * .2, h * .12, w * .03, t.tail);
    _rr(c, -w * .12, -h * .38, w * .24, h * .1, w * .02, const Color(0xFFF4F4F4));
    final tp = TextPainter(
      text: TextSpan(text: 'ERASBUS', style: TextStyle(fontFamily: 'Roboto', fontSize: w * .065, fontWeight: FontWeight.w700, color: const Color(0xFF222222))),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(-tp.width / 2, -h * .335 - tp.height / 2 + h * .03));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant RacePainter old) => true;
}
