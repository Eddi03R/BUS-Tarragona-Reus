import 'dart:math';
import 'package:flutter/material.dart';
import 'chess_pieces.dart';

enum GameKind { busJam, sudoku, maze, battleship, ticTacToe, blocks, g2048, memory, wordle, flow, snake, minesweeper, solitaire, slide, connections, flappy, quiz, checkers, chess }

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
      case GameKind.snake:
        _snake(canvas);
      case GameKind.minesweeper:
        _mines(canvas);
      case GameKind.solitaire:
        _solitaire(canvas);
      case GameKind.slide:
        _slide(canvas);
      case GameKind.connections:
        _connections(canvas);
      case GameKind.flappy:
        _flappy(canvas);
      case GameKind.quiz:
        _quiz(canvas);
      case GameKind.checkers:
        _checkers(canvas);
      case GameKind.chess:
        _chess(canvas);
    }
    canvas.restore();
  }

  void _chessBoard(Canvas c, Color light, Color dark) {
    const x0 = 18.0, cell = 21.0;
    c.save();
    c.clipRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(x0, x0, cell * 4, cell * 4), const Radius.circular(8)));
    for (var r = 0; r < 4; r++) {
      for (var f = 0; f < 4; f++) {
        c.drawRect(Rect.fromLTWH(x0 + f * cell, x0 + r * cell, cell, cell), _fill((r + f) % 2 == 0 ? light : dark));
      }
    }
    c.restore();
  }

  void _chess(Canvas c) {
    _chessBoard(c, const Color(0xFFF0D9B5), const Color(0xFFB58863));
    paintChessPiece(c, -5, const Rect.fromLTWH(18, 18, 24, 24));
    paintChessPiece(c, 2, const Rect.fromLTWH(60, 39, 24, 24));
    paintChessPiece(c, 6, const Rect.fromLTWH(39, 60, 24, 24));
    paintChessPiece(c, -1, const Rect.fromLTWH(81, 81, 22, 22));
  }

  void _checkers(Canvas c) {
    _chessBoard(c, const Color(0xFFEAD7B1), const Color(0xFF7B4B2A));
    void man(double cx, double cy, bool white, {bool king = false}) {
      c.drawCircle(Offset(cx, cy + 1.2), 8.6, _fill(const Color(0x55000000)));
      c.drawCircle(Offset(cx, cy), 8.6, _fill(white ? const Color(0xFFF7EFDD) : const Color(0xFF3A2A25)));
      c.drawCircle(Offset(cx, cy), 8.6, _stroke(white ? const Color(0xFFB59B6D) : const Color(0xFF8C6A5B), 1.4));
      c.drawCircle(Offset(cx, cy), 5.2, _stroke(white ? const Color(0xFFD9C79F) : const Color(0xFF5B433B), 1));
      if (king) {
        final p = Path()
          ..moveTo(cx - 4.5, cy + 3)
          ..lineTo(cx - 4.5, cy - 3)
          ..lineTo(cx - 2, cy)
          ..lineTo(cx, cy - 4)
          ..lineTo(cx + 2, cy)
          ..lineTo(cx + 4.5, cy - 3)
          ..lineTo(cx + 4.5, cy + 3)
          ..close();
        c.drawPath(p, _fill(const Color(0xFFFFC107)));
      }
    }
    man(70.5, 28.5, false);
    man(28.5, 49.5, false);
    man(49.5, 49.5, true);
    man(91.5, 70.5, true, king: true);
    man(28.5, 91.5, true);
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
    // Labirinto vero 6x6 (generato con un seme fisso, quindi sempre uguale),
    // con il percorso tratteggiato dal bus alla bandiera.
    const n = 6;
    const x0 = 20.0, cell = 80.0 / n;
    final rnd = Random(11);
    final right = List.generate(n, (_) => List.filled(n, true));
    final down = List.generate(n, (_) => List.filled(n, true));
    final seen = List.generate(n, (_) => List.filled(n, false));
    final stack = <(int, int)>[(0, 0)];
    seen[0][0] = true;
    while (stack.isNotEmpty) {
      final (r, col) = stack.last;
      final next = <(int, int)>[
        if (r > 0 && !seen[r - 1][col]) (r - 1, col),
        if (r < n - 1 && !seen[r + 1][col]) (r + 1, col),
        if (col > 0 && !seen[r][col - 1]) (r, col - 1),
        if (col < n - 1 && !seen[r][col + 1]) (r, col + 1),
      ];
      if (next.isEmpty) {
        stack.removeLast();
        continue;
      }
      final (nr, nc) = next[rnd.nextInt(next.length)];
      if (nr == r - 1) down[nr][nc] = false;
      if (nr == r + 1) down[r][col] = false;
      if (nc == col - 1) right[nr][nc] = false;
      if (nc == col + 1) right[r][col] = false;
      seen[nr][nc] = true;
      stack.add((nr, nc));
    }
    // Soluzione (BFS) da (0,0) a (n-1,n-1).
    final prev = <int, int>{0: -1};
    final queue = <int>[0];
    for (var i = 0; i < queue.length; i++) {
      final cur = queue[i];
      final r = cur ~/ n, col = cur % n;
      void go(int nr, int nc, bool open) {
        final id = nr * n + nc;
        if (open && !prev.containsKey(id)) {
          prev[id] = cur;
          queue.add(id);
        }
      }
      if (r > 0) go(r - 1, col, !down[r - 1][col]);
      if (r < n - 1) go(r + 1, col, !down[r][col]);
      if (col > 0) go(r, col - 1, !right[r][col - 1]);
      if (col < n - 1) go(r, col + 1, !right[r][col]);
    }
    Offset center(int id) =>
        Offset(x0 + (id % n + 0.5) * cell, x0 + (id ~/ n + 0.5) * cell);
    final path = Path();
    for (var id = n * n - 1; id != -1; id = prev[id]!) {
      final o = center(id);
      id == n * n - 1 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 5) {
        c.drawPath(m.extractPath(d, min(d + 2.6, m.length)), _stroke(_amber, 2.2));
      }
    }
    // Pareti.
    final walls = Path()..addRect(const Rect.fromLTWH(x0, x0, 80, 80));
    for (var r = 0; r < n; r++) {
      for (var col = 0; col < n; col++) {
        final x = x0 + col * cell, y = x0 + r * cell;
        if (col < n - 1 && right[r][col]) {
          walls..moveTo(x + cell, y)..lineTo(x + cell, y + cell);
        }
        if (r < n - 1 && down[r][col]) {
          walls..moveTo(x, y + cell)..lineTo(x + cell, y + cell);
        }
      }
    }
    c.drawPath(walls, _stroke(Colors.white, 2.4));
    // Partenza (bus) e arrivo (bandiera).
    final s0 = center(0);
    _rr(c, s0.dx - 5.5, s0.dy - 4.5, 11, 9, 2.5, _amber, border: Colors.white, bw: 1);
    _rr(c, s0.dx - 3.5, s0.dy - 2.2, 7, 3.5, 1, _red);
    _text(c, '🏁', center(n * n - 1), 11, Colors.white);
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
    // Partita finita: la X vince in diagonale, la O ha riempito altre caselle.
    // Griglia 3x3 con caselle da 26 (da 21 a 99): centri 34, 60, 86.
    _board(c, 0.2);
    final l = _stroke(Colors.white.withOpacity(0.85), 3);
    c.drawLine(const Offset(47, 24), const Offset(47, 96), l);
    c.drawLine(const Offset(73, 24), const Offset(73, 96), l);
    c.drawLine(const Offset(24, 47), const Offset(96, 47), l);
    c.drawLine(const Offset(24, 73), const Offset(96, 73), l);
    const centers = [34.0, 60.0, 86.0];
    final x = _stroke(_amber, 4.5);
    final o = _stroke(Colors.white, 4.5);
    for (final i in [0, 1, 2]) {
      final cx = centers[i], cy = centers[i];
      c.drawLine(Offset(cx - 7, cy - 7), Offset(cx + 7, cy + 7), x);
      c.drawLine(Offset(cx + 7, cy - 7), Offset(cx - 7, cy + 7), x);
    }
    for (final (col, row) in const [(1, 0), (0, 1), (1, 2)]) {
      c.drawCircle(Offset(centers[col], centers[row]), 7.5, o);
    }
    c.drawLine(const Offset(26, 26), const Offset(94, 94), _stroke(_red, 4));
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

  void _snake(Canvas c) {
    _board(c);
    // griglia 7×7 con scacchiera leggera
    const cell = 12.0, ox = 18.0, oy = 18.0;
    for (var r = 0; r < 7; r++) {
      for (var k = 0; k < 7; k++) {
        if ((r + k).isOdd) {
          c.drawRect(Rect.fromLTWH(ox + k * cell, oy + r * cell, cell, cell),
              _fill(Colors.white.withOpacity(0.06)));
        }
      }
    }
    // bus-serpente: dalla coda (chiara) alla testa (rossa)
    const path = [
      [0, 5], [1, 5], [2, 5], [3, 5], [4, 5], [4, 4], [4, 3], [3, 3], [2, 3], [2, 2], [2, 1],
    ];
    for (var i = 0; i < path.length; i++) {
      final t = i / (path.length - 1);
      final col = Color.lerp(const Color(0xFFFFAB91), const Color(0xFFD32F2F), t)!;
      _rr(c, ox + path[i][0] * cell + 0.8, oy + path[i][1] * cell + 0.8, cell - 1.6, cell - 1.6,
          i == path.length - 1 ? 5 : 3.5, col);
    }
    // occhi della testa
    final hx = ox + 2 * cell, hy = oy + 1 * cell;
    c.drawCircle(Offset(hx + 3.5, hy + 4), 1.9, _fill(Colors.white));
    c.drawCircle(Offset(hx + 8.5, hy + 4), 1.9, _fill(Colors.white));
    c.drawCircle(Offset(hx + 3.5, hy + 4), 0.8, _fill(Colors.black87));
    c.drawCircle(Offset(hx + 8.5, hy + 4), 0.8, _fill(Colors.black87));
    // fermata da mangiare
    final fc = Offset(ox + 5.5 * cell, oy + 1.5 * cell);
    c.drawCircle(fc, 5.2, _fill(_amber));
    c.drawCircle(fc, 2.4, _fill(Colors.white));
  }

  void _mines(Canvas c) {
    _board(c);
    // 4×4: 0 vuoto aperto, 1-3 numeri, 9 chiuso, 8 bandiera, 7 bomba
    const grid = [
      [0, 0, 1, 9],
      [1, 1, 2, 8],
      [9, 2, 9, 9],
      [9, 9, 7, 9],
    ];
    const cell = 19.0, gap = 2.0, ox = 18.5, oy = 18.5;
    const numCols = {1: Color(0xFF1976D2), 2: Color(0xFF388E3C), 3: Color(0xFFD32F2F)};
    for (var r = 0; r < 4; r++) {
      for (var k = 0; k < 4; k++) {
        final v = grid[r][k];
        final x = ox + k * (cell + gap), y = oy + r * (cell + gap);
        final open = v <= 3;
        _rr(c, x, y, cell, cell, 4,
            open ? Colors.white.withOpacity(0.92) : Colors.white.withOpacity(0.28));
        if (v >= 1 && v <= 3) {
          _text(c, '$v', Offset(x + cell / 2, y + cell / 2), 13, numCols[v]!);
        } else if (v == 8) {
          _text(c, '🚩', Offset(x + cell / 2, y + cell / 2), 12, Colors.white);
        } else if (v == 7) {
          _text(c, '💣', Offset(x + cell / 2, y + cell / 2), 12, Colors.white);
        }
      }
    }
  }

  void _solitaire(Canvas c) {
    // ventaglio di tre carte, con il perno in basso al centro
    void card(double angle, String rank, String suit, Color color) {
      c.save();
      c.translate(60, 98);
      c.rotate(angle);
      const w = 38.0, h = 54.0;
      c.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(-w / 2, -h, w, h), const Radius.circular(5)),
          _fill(Colors.black.withOpacity(0.25)));
      _rr(c, -w / 2, -h - 1, w, h, 5, Colors.white, border: Colors.black26, bw: 1);
      _text(c, rank, const Offset(-w / 2 + 8, -h + 9), 11, color);
      _text(c, suit, const Offset(-w / 2 + 8, -h + 20), 10, color);
      _text(c, suit, const Offset(2, -h / 2 - 3), 24, color);
      c.restore();
    }

    const black = Color(0xFF212121), red = Color(0xFFD32F2F);
    card(-0.42, 'K', '♠', black);
    card(0.0, 'Q', '♦', red);
    card(0.42, 'A', '♥', red);
  }

  void _slide(Canvas c) {
    _board(c);
    // 3×3 quasi risolto: manca solo lo spostamento dell'ultima tessera
    const cell = 26.0, gap = 3.0, ox = 18.0, oy = 18.0;
    const nums = [1, 2, 3, 4, 5, 6, 7, 0, 8];
    const cols = [
      Color(0xFFFFC107), Color(0xFFFF8A65), Color(0xFFBA68C8), Color(0xFF4FC3F7),
      Color(0xFF66BB6A), Color(0xFFFFD54F), Color(0xFF9575CD), Color(0xFF000000), Color(0xFFEF5350),
    ];
    for (var i = 0; i < 9; i++) {
      final x = ox + (i % 3) * (cell + gap), y = oy + (i ~/ 3) * (cell + gap);
      if (nums[i] == 0) {
        _rr(c, x, y, cell, cell, 6, Colors.white.withOpacity(0.08),
            border: Colors.white.withOpacity(0.35), bw: 1.2);
        // freccia: la tessera 8 scorre qui
        final a = Path()
          ..moveTo(x + cell * 0.7, y + cell * 0.5)
          ..lineTo(x + cell * 0.3, y + cell * 0.5)
          ..moveTo(x + cell * 0.46, y + cell * 0.32)
          ..lineTo(x + cell * 0.3, y + cell * 0.5)
          ..lineTo(x + cell * 0.46, y + cell * 0.68);
        c.drawPath(a, _stroke(Colors.white.withOpacity(0.7), 2));
        continue;
      }
      _rr(c, x, y, cell, cell, 6, cols[i]);
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x + 3, y + 2.5, cell - 6, 4), const Radius.circular(2)),
          _fill(Colors.white.withOpacity(0.28)));
      _text(c, '${nums[i]}', Offset(x + cell / 2, y + cell / 2 + 1), 15, Colors.white);
    }
  }

  void _connections(Canvas c) {
    _board(c);
    const ox = 18.0, oy = 18.0, cw = 19.0, ch = 17.0, gap = 2.5;
    // riga risolta (gruppo giallo)
    _rr(c, ox, oy, 4 * cw + 3 * gap, ch, 5, const Color(0xFFF9A825));
    _rr(c, ox + 12, oy + 5, 4 * cw + 3 * gap - 24, 7, 3.5, Colors.white.withOpacity(0.75));
    // righe da risolvere: parole (barrette) e due già selezionate
    for (var r = 1; r < 4; r++) {
      for (var k = 0; k < 4; k++) {
        final x = ox + k * (cw + gap), y = oy + r * (ch + gap);
        final selected = r == 1 && k < 2;
        _rr(c, x, y, cw, ch, 5, selected ? const Color(0xFF1E88E5) : Colors.white.withOpacity(0.9));
        _rr(c, x + 4, y + ch / 2 - 1.5, cw - 8, 3, 1.5,
            selected ? Colors.white : const Color(0xFF90A4AE));
      }
    }
  }

  void _flappy(Canvas c) {
    // cielo con sfumatura (dentro la scheda arrotondata)
    final board = RRect.fromRectAndRadius(
        const Rect.fromLTWH(14, 14, 92, 92), const Radius.circular(12));
    c.save();
    c.clipRRect(board);
    c.drawRect(
      const Rect.fromLTWH(14, 14, 92, 92),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF4FC3F7), Color(0xFFB3E5FC)],
        ).createShader(const Rect.fromLTWH(14, 14, 92, 92)),
    );
    // nuvole
    for (final p in const [Offset(34, 30), Offset(90, 52)]) {
      c.drawCircle(p, 6, _fill(Colors.white.withOpacity(0.85)));
      c.drawCircle(p + const Offset(7, 2), 5, _fill(Colors.white.withOpacity(0.85)));
      c.drawCircle(p + const Offset(-6, 2), 4.5, _fill(Colors.white.withOpacity(0.85)));
    }
    // palazzi sopra e sotto con finestre
    void tower(double top, double bottom) {
      _rr(c, 68, top, 24, bottom - top, 3, const Color(0xFF8D6E63), border: const Color(0xFF5D4037));
      for (var y = top + 6; y < bottom - 8; y += 11) {
        c.drawRect(Rect.fromLTWH(73, y, 5, 6), _fill(const Color(0xFFFFE082)));
        c.drawRect(Rect.fromLTWH(82, y, 5, 6), _fill(const Color(0xFFFFE082)));
      }
    }

    tower(6, 42);
    tower(70, 114);
    // strada
    c.drawRect(const Rect.fromLTWH(14, 98, 92, 8), _fill(const Color(0xFF616161)));
    c.drawRect(const Rect.fromLTWH(14, 98, 92, 2), _fill(_amber));
    c.restore();
    // bus inclinato in salita, con linee di velocità
    c.save();
    c.translate(42, 56);
    c.rotate(-0.22);
    for (final dy in const [-6.0, 0.0, 6.0]) {
      c.drawLine(Offset(-30, dy), Offset(-21, dy), _stroke(Colors.white.withOpacity(0.7), 1.6));
    }
    _rr(c, -18, -11, 38, 22, 7, _red, border: Colors.white, bw: 1.5);
    for (var i = 0; i < 3; i++) {
      c.drawRect(Rect.fromLTWH(-13 + i * 10.0, -6, 8, 7), _fill(Colors.white));
    }
    c.drawCircle(const Offset(-9, 11), 4.2, _fill(const Color(0xFF222222)));
    c.drawCircle(const Offset(10, 11), 4.2, _fill(const Color(0xFF222222)));
    c.restore();
  }

  void _quiz(Canvas c) {
    _board(c);
    // fumetto con il punto interrogativo
    _rr(c, 22, 18, 76, 38, 12, Colors.white.withOpacity(0.96));
    final tail = Path()
      ..moveTo(40, 55)
      ..lineTo(36, 63)
      ..lineTo(52, 55)
      ..close();
    c.drawPath(tail, _fill(Colors.white.withOpacity(0.96)));
    _text(c, '?', const Offset(60, 37), 34, const Color(0xFF5E35B1));
    // tre risposte, quella giusta in verde con la spunta
    for (var i = 0; i < 3; i++) {
      final y = 66.0 + i * 12;
      final ok = i == 1;
      _rr(c, 22, y, 76, 9.5, 4.75, ok ? const Color(0xFF43A047) : Colors.white.withOpacity(0.32));
      if (ok) {
        final tick = Path()
          ..moveTo(86, y + 5)
          ..lineTo(89, y + 7.7)
          ..lineTo(94, y + 2.5);
        c.drawPath(tick, _stroke(Colors.white, 1.8));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtPainter old) => old.kind != kind;
}
