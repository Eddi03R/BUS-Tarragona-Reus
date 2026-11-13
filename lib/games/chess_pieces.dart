import 'package:flutter/material.dart';

/// Pezzi degli scacchi disegnati a mano (vettoriali, uguali su ogni telefono).
/// [piece]: 1 pedone, 2 cavallo, 3 alfiere, 4 torre, 5 donna, 6 re; negativo = nero.
void paintChessPiece(Canvas canvas, int piece, Rect rect) {
  final white = piece > 0;
  final fill = Paint()..color = white ? const Color(0xFFFAF7F0) : const Color(0xFF34302C);
  final line = Paint()
    ..color = white ? const Color(0xFF2B2622) : const Color(0xFFF2EEE6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = white ? 2.6 : 2.0
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;
  final inner = Paint()
    ..color = white ? const Color(0xFF2B2622) : const Color(0xFFF2EEE6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.8
    ..strokeCap = StrokeCap.round;

  canvas.save();
  canvas.translate(rect.left, rect.top);
  canvas.scale(rect.width / 100, rect.height / 100);

  void shape(Path p) {
    canvas.drawPath(p, fill);
    canvas.drawPath(p, line);
  }

  void base() {
    shape(Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(20, 80, 60, 11), const Radius.circular(5))));
  }

  void ball(double x, double y, double r) {
    canvas.drawCircle(Offset(x, y), r, fill);
    canvas.drawCircle(Offset(x, y), r, line);
  }

  Path poly(List<double> xy) {
    final p = Path()..moveTo(xy[0], xy[1]);
    for (var i = 2; i < xy.length; i += 2) {
      p.lineTo(xy[i], xy[i + 1]);
    }
    return p..close();
  }

  switch (piece.abs()) {
    case 1: // pedone
      shape(poly([36, 80, 42, 52, 58, 52, 64, 80]));
      shape(Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(34, 46, 32, 8), const Radius.circular(4))));
      ball(50, 33, 12);
      base();
    case 2: // cavallo
      shape(Path()
        ..moveTo(28, 80)
        ..cubicTo(28, 62, 36, 56, 32, 46)
        ..cubicTo(26, 44, 24, 38, 28, 34)
        ..lineTo(42, 18)
        ..lineTo(44, 10)
        ..lineTo(52, 16)
        ..cubicTo(70, 20, 78, 44, 76, 80)
        ..close());
      ball(44, 32, 2.2);
      canvas.drawLine(const Offset(30, 42), const Offset(40, 40), inner);
      base();
    case 3: // alfiere
      shape(poly([36, 80, 42, 58, 58, 58, 64, 80]));
      shape(Path()
        ..moveTo(50, 20)
        ..cubicTo(68, 34, 66, 56, 62, 58)
        ..lineTo(38, 58)
        ..cubicTo(34, 56, 32, 34, 50, 20)
        ..close());
      ball(50, 16, 5);
      canvas.drawLine(const Offset(50, 34), const Offset(56, 42), inner);
      base();
    case 4: // torre
      shape(poly([34, 80, 37, 40, 63, 40, 66, 80]));
      shape(poly([30, 40, 30, 20, 38, 20, 38, 28, 44, 28, 44, 20, 56, 20, 56, 28, 62, 28, 62, 20, 70, 20, 70, 40]));
      base();
    case 5: // donna
      shape(poly([34, 80, 38, 46, 62, 46, 66, 80]));
      shape(poly([28, 48, 22, 22, 38, 36, 44, 18, 50, 34, 56, 18, 62, 36, 78, 22, 72, 48]));
      ball(22, 20, 4);
      ball(44, 16, 4);
      ball(56, 16, 4);
      ball(78, 20, 4);
      base();
    case 6: // re
      shape(poly([32, 80, 36, 40, 64, 40, 68, 80]));
      shape(Path()
        ..moveTo(34, 42)
        ..cubicTo(30, 26, 70, 26, 66, 42)
        ..close());
      shape(poly([46, 6, 54, 6, 54, 12, 60, 12, 60, 19, 54, 19, 54, 28, 46, 28, 46, 19, 40, 19, 40, 12, 46, 12]));
      base();
  }
  canvas.restore();
}

/// Un pezzo da usare come widget (es. scelta della promozione).
class ChessPieceIcon extends StatelessWidget {
  final int piece;
  final double size;
  const ChessPieceIcon(this.piece, {super.key, this.size = 48});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _IconPainter(piece));
}

class _IconPainter extends CustomPainter {
  final int piece;
  _IconPainter(this.piece);
  @override
  void paint(Canvas canvas, Size size) => paintChessPiece(canvas, piece, Offset.zero & size);
  @override
  bool shouldRepaint(covariant _IconPainter old) => old.piece != piece;
}
