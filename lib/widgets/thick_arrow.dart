import 'package:flutter/material.dart';

/// Freccia "da A a B" con tratto spesso (più leggibile di Icons.arrow_forward).
class ThickArrow extends StatelessWidget {
  final double size;
  final Color color;
  const ThickArrow({super.key, this.size = 22, required this.color});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size(size * 1.25, size * 0.8),
        painter: _ThickArrowPainter(color),
      );
}

class _ThickArrowPainter extends CustomPainter {
  final Color color;
  _ThickArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.height * 0.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final y = s.height / 2;
    final pad = p.strokeWidth / 2;
    canvas.drawLine(Offset(pad, y), Offset(s.width - pad, y), p);
    canvas.drawPath(
      Path()
        ..moveTo(s.width * 0.62, pad)
        ..lineTo(s.width - pad, y)
        ..lineTo(s.width * 0.62, s.height - pad),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _ThickArrowPainter old) => old.color != color;
}
