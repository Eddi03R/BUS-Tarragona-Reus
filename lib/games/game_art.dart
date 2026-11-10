import 'dart:math';
import 'package:flutter/material.dart';

enum GameKind { busJam, sudoku, maze, battleship, ticTacToe, blocks, g2048, memory, wordle, flow }

/// Illustrazione di un gioco, disegnata a mano: sta sopra lo sfondo del tema
/// (tessere dell'elenco giochi e copertina della pagina di avvio).
class GameArt extends StatelessWidget {
  final GameKind kind;
  const GameArt(this.kind, {super.key});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ArtPainter(kind), child: const SizedBox.expand());
}

class _ArtPainter extends CustomPainter {
  final GameKind kind;
  _ArtPainter(this.kind);

  static const _red = Color(0xFFE53935);
  static const _amber = Color(0xFFFFC107);

  @override
  void paint(Canvas canvas, Size size) {
    final side = min(size.width, size.height);
    canvas.save();
    canvas.translate((size.width - side) / 2, (size.height - side) / 2);
    canvas.scale(side / 120);
    switch (kind) {
      case GameKind.busJam:
        _busJam(canvas);
      case GameKind.sudoku:
        _sudoku(canvas);
      case GameKind.maze:
        _maze(canvas);
      case GameKind.battleship:
        _battleship(canvas);
      case GameKind.ticTacToe:
        _ttt(canvas);
      case GameKind.blocks:
        _blocks(canvas);
      case GameKind.g2048:
        _g2048(canvas);
      case GameKind.memory:
        _memory(canvas);
      case GameKind.wordle:
        _wordle(canvas);
      case GameKind.flow:
        _flow(canvas);
    }
    canvas.restore();
  }

  // ---------------------------------------------------------------- utilità
  Paint _fill(Color c) => Paint()..color = c;
  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _board(Canvas c, [double a = 0.28]) => c.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(14, 14, 92, 92), const Radius.circular(12)),
      _fill(Colors.black.withOpacity(a)));

  void _rr(Canvas c, double x, double y, double w, double h, double r, Color fill,
      {Color? border, double bw = 1.5}) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r));
    c.drawRRect(rr, _fill(fill));
    if (border != null) c.drawRRect(rr, _stroke(border, bw));
  }

  void _text(Canvas c, String t, Offset center, double size, Color color,
      {FontWeight weight = FontWeight.w900}) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(fontSize: size, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, center - Offset(tp.width / 2, tp.height / 2));
  }

  // ------------------------------------------------------------------ disegni
  void _busJam(Canvas c) {
    _board(c);
    _rr(c, 22, 48, 40, 18, 8, _red, border: Colors.white);
    c.drawRect(const Rect.fromLTWH(28, 55, 22, 3), _fill(Colors.white70));
    _rr(c, 52, 51, 7, 12, 2, const Color(0xFF22303A));
    _rr(c, 68, 22, 18, 40, 8, const Color(0xFF3949AB), border: Colors.white);
    _rr(c, 72, 52, 10, 7, 2, const Color(0xFF22303A));
    _rr(c, 40, 82, 48, 18, 8, const Color(0xFF43A047), border: Colors.white);
    _rr(c, 78, 85, 7, 12, 2, const Color(0xFF22303A));
    _rr(c, 22, 22, 30, 16, 7, const Color(0xFFFB8C00), border: Colors.white);
    _rr(c, 92, 48, 14, 18, 6, const Color(0xFF8E24AA), border: Colors.white);
    final arrow = Path()..moveTo(100, 52)..lineTo(106, 57)..lineTo(100, 62);
    c.drawPath(arrow, _stroke(_amber, 3));
  }

  void _sudoku(Canvas c) {
    _rr(c, 18, 18, 84, 84, 10, Colors.white);
    final grid = _stroke(const Color(0xFF9AA7A3), 1);
    for (final v in [46.0, 74.0]) {
      c.drawLine(Offset(v, 18), Offset(v, 102), grid);
      c.drawLine(Offset(18, v), Offset(102, v), grid);
    }
    const nums = [5, 3, 7, 9, 2, 6, 1, 8, 4];
    for (var i = 0; i < 9; i++) {
      final x = 32.0 + (i % 3) * 28, y = 32.0 + (i ~/ 3) * 28;
      _text(c, '${nums[i]}', Offset(x, y), 20,
          i == 1 || i == 3 || i == 7 ? const Color(0xFF0F6E5C) : const Color(0xFF18201E));
    }
  }

  void _maze(Canvas c) {
    _board(c, 0.25);
    final p = Path()
      ..moveTo(22, 22)
      ..lineTo(98, 22)
      ..lineTo(98, 98)
      ..lineTo(22, 98)
      ..close()
      ..moveTo(22, 40)..lineTo(62, 40)
      ..moveTo(62, 22)..lineTo(62, 58)..lineTo(40, 58)
      ..moveTo(80, 40)..lineTo(80, 76)..lineTo(44, 76)
      ..moveTo(22, 58)..lineTo(22, 80)..lineTo(62, 80)
      ..moveTo(80, 98)..lineTo(80, 84)
      ..moveTo(98, 58)..lineTo(80, 58);
    c.drawPath(p, _stroke(Colors.white, 3.2));
    _rr(c, 25, 25, 13, 13, 3, _amber);
    _rr(c, 27, 29, 9, 6, 1.5, _red);
    _text(c, '🏁', const Offset(88, 90), 15, Colors.white);
  }

  void _battleship(Canvas c) {
    _board(c, 0.25);
    final g = _stroke(Colors.white.withOpacity(0.28), 1);
    for (var v = 30.0; v < 106; v += 16) {
      c.drawLine(Offset(v, 14), Offset(v, 106), g);
      c.drawLine(Offset(14, v), Offset(106, v), g);
    }
    final hull = Path()
      ..moveTo(18, 70)..lineTo(70, 70)..lineTo(78, 78)..lineTo(70, 86)..lineTo(18, 86)..close();
    c.drawPath(hull, _fill(const Color(0xFF6E8294)));
    c.drawPath(hull, _stroke(Colors.white, 1.5));
    _rr(c, 26, 75, 30, 6, 3, const Color(0xFFA7B6C4));
    final hull2 = Path()
      ..moveTo(50, 30)..lineTo(80, 30)..lineTo(85, 35)..lineTo(80, 40)..lineTo(50, 40)..close();
    c.drawPath(hull2, _fill(const Color(0xFF6E8294)));
    c.drawPath(hull2, _stroke(Colors.white, 1.5));
    c.drawCircle(const Offset(84, 52), 11, _fill(const Color(0xFFFF7043)));
    c.drawCircle(const Offset(84, 52), 6, _fill(const Color(0xFFFFEB3B)));
    c.drawCircle(const Offset(84, 52), 2.5, _fill(Colors.white));
    final trail = Path()..moveTo(96, 22)..quadraticBezierTo(92, 34, 87, 46);
    c.drawPath(trail, _stroke(_amber, 2.5));
  }

  void _ttt(Canvas c) {
    _rr(c, 18, 18, 84, 84, 12, Colors.black.withOpacity(0.2));
    final l = _stroke(Colors.white, 3.5);
    c.drawLine(const Offset(46, 24), const Offset(46, 96), l);
    c.drawLine(const Offset(74, 24), const Offset(74, 96), l);
    c.drawLine(const Offset(24, 46), const Offset(96, 46), l);
    c.drawLine(const Offset(24, 74), const Offset(96, 74), l);
    final x = _stroke(_amber, 4);
    for (final o in const [Offset(29, 29), Offset(77, 29), Offset(29, 77), Offset(77, 77)]) {
      c.drawLine(o, o + const Offset(12, 12), x);
      c.drawLine(o + const Offset(12, 0), o + const Offset(0, 12), x);
    }
    c.drawCircle(const Offset(60, 60), 8, _stroke(Colors.white, 4));
    c.drawLine(const Offset(26, 26), const Offset(94, 94), _stroke(_red, 5));
  }

  void _blocks(Canvas c) {
    _board(c);
    const colors = [
      Color(0xFFFFC107), Color(0xFF7E57C2), Color(0xFF66BB6A), Color(0xFFEF5350), Color(0xFF42A5F5),
    ];
    // griglia 6x6 con alcuni blocchi già posati
    const cell = 13.0;
    const ox = 21.0, oy = 21.0;
    final placed = {
      0: 1, 1: 1, 6: 1, 12: 4, 13: 4, 14: 4, 18: 2, 24: 2, 25: 2, 30: 3, 31: 3, 32: 2, 33: 2, 34: 2, 35: 2,
    };
    for (var i = 0; i < 36; i++) {
      final x = ox + (i % 6) * cell, y = oy + (i ~/ 6) * cell;
      final k = placed[i];
      if (k == null) {
        _rr(c, x + 1, y + 1, cell - 2, cell - 2, 2.5, Colors.white.withOpacity(0.1));
      } else {
        _rr(c, x + 1, y + 1, cell - 2, cell - 2, 2.5, colors[k]);
        _rr(c, x + 2.5, y + 2.5, cell - 5, 3, 1.5, Colors.white.withOpacity(0.35));
      }
    }
    // pezzo a L che sta per essere posato
    for (final p in const [Offset(76, 62), Offset(76, 75), Offset(76, 88), Offset(89, 88)]) {
      _rr(c, p.dx, p.dy, 12, 12, 2.5, colors[0], border: Colors.white, bw: 1.2);
    }
  }

  void _g2048(Canvas c) {
    _board(c);
    const vals = [2, 4, 8, 16, 32, 64, 128, 256, 1024];
    const cols = [
      Color(0xFFEEE4DA), Color(0xFFEDE0C8), Color(0xFFF2B179), Color(0xFFF59563),
      Color(0xFFF67C5F), Color(0xFFF65E3B), Color(0xFFEDCF72), Color(0xFFEDCC61), Color(0xFFEDC22E),
    ];
    for (var i = 0; i < 9; i++) {
      final x = 21.0 + (i % 3) * 29, y = 21.0 + (i ~/ 3) * 29;
      _rr(c, x, y, 26, 26, 5, cols[i]);
      final v = vals[i];
      _text(c, '$v', Offset(x + 13, y + 13), v >= 1000 ? 9 : (v >= 100 ? 11 : 13),
          v <= 4 ? const Color(0xFF776E65) : Colors.white);
    }
  }

  void _memory(Canvas c) {
    _board(c, 0.2);
    for (var i = 0; i < 4; i++) {
      final x = 20.0 + (i % 2) * 45, y = 20.0 + (i ~/ 2) * 45;
      final flipped = i == 0 || i == 3;
      _rr(c, x, y, 40, 40, 8, flipped ? Colors.white : _amber, border: Colors.white);
      _text(c, flipped ? '🚌' : '?', Offset(x + 20, y + 20), flipped ? 22 : 24,
          flipped ? Colors.black : Colors.white);
    }
  }

  void _wordle(Canvas c) {
    _board(c, 0.2);
    const word = 'WORDS';
    const states = [0, 1, 2, 0, 2]; // 0 grigio, 1 giallo, 2 verde
    const cols = [Color(0xFF6E7C7A), Color(0xFFE0B100), Color(0xFF43A047)];
    for (var i = 0; i < 5; i++) {
      final x = 19.0 + i * 17.5;
      _rr(c, x, 36, 16, 16, 3, cols[states[i]]);
      _text(c, word[i], Offset(x + 8, 44), 11, Colors.white);
    }
    const w2 = 'ERASB';
    for (var i = 0; i < 5; i++) {
      final x = 19.0 + i * 17.5;
      _rr(c, x, 58, 16, 16, 3, i < 3 ? Colors.white.withOpacity(0.2) : Colors.transparent,
          border: Colors.white.withOpacity(0.5), bw: 1);
      if (i < 3) _text(c, w2[i], Offset(x + 8, 66), 11, Colors.white);
    }
    for (var i = 0; i < 5; i++) {
      final x = 19.0 + i * 17.5;
      _rr(c, x, 80, 16, 16, 3, Colors.transparent, border: Colors.white.withOpacity(0.3), bw: 1);
    }
  }

  void _flow(Canvas c) {
    _board(c);
    const g = 4;
    const cell = 21.0, ox = 18.0, oy = 18.0;
    final line = _stroke(Colors.white.withOpacity(0.2), 1);
    for (var i = 0; i <= g; i++) {
      c.drawLine(Offset(ox + i * cell, oy), Offset(ox + i * cell, oy + g * cell), line);
      c.drawLine(Offset(ox, oy + i * cell), Offset(ox + g * cell, oy + i * cell), line);
    }
    Offset ctr(int x, int y) => Offset(ox + (x + 0.5) * cell, oy + (y + 0.5) * cell);
    void flow(List<List<int>> pts, Color color) {
      final p = Path()..moveTo(ctr(pts.first[0], pts.first[1]).dx, ctr(pts.first[0], pts.first[1]).dy);
      for (final q in pts.skip(1)) {
        p.lineTo(ctr(q[0], q[1]).dx, ctr(q[0], q[1]).dy);
      }
      c.drawPath(p, _stroke(color, 8));
      for (final q in [pts.first, pts.last]) {
        c.drawCircle(ctr(q[0], q[1]), 7.5, _fill(color));
      }
    }

    flow([[0, 0], [1, 0], [2, 0], [2, 1]], const Color(0xFFFFC107));
    flow([[0, 1], [0, 2], [1, 2]], const Color(0xFF66BB6A));
    flow([[3, 0], [3, 1], [3, 2], [3, 3]], const Color(0xFFEF5350));
    c.drawCircle(ctr(0, 3), 7.5, _fill(const Color(0xFF42A5F5)));
    c.drawCircle(ctr(2, 3), 7.5, _fill(const Color(0xFF42A5F5)));
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.kind != kind;
}
