import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fiocco di neve a 6 braccia disegnato a canvas.
class SnowflakeIcon extends StatelessWidget {
  final double size;
  final Color color;
  const SnowflakeIcon({super.key, this.size = 20, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SnowflakePainter(color: color),
    );
  }
}

class _SnowflakePainter extends CustomPainter {
  final Color color;
  const _SnowflakePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = math.max(1.2, size.width / 14)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final dir = Offset(math.cos(a), math.sin(a));
      final tip = c + dir * r;
      canvas.drawLine(c, tip, paint);
      // Due rametti per braccio
      final branchBase = c + dir * (r * 0.6);
      for (final s in [-1, 1]) {
        final ba = a + s * math.pi / 4;
        canvas.drawLine(
          branchBase,
          branchBase + Offset(math.cos(ba), math.sin(ba)) * (r * 0.32),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SnowflakePainter old) => old.color != color;
}

/// Angolo con fiocchi di neve sparsi, ancorato a un angolo (stesso schema di
/// [CobwebCorner] per Halloween).
class SnowCorner extends StatelessWidget {
  final double size;
  final Color color;
  final Alignment corner;
  const SnowCorner({
    super.key,
    this.size = 70,
    this.color = Colors.white70,
    this.corner = Alignment.topLeft,
  });

  @override
  Widget build(BuildContext context) {
    final flipX = corner.x > 0;
    final flipY = corner.y > 0;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scaleByDouble(flipX ? -1.0 : 1.0, flipY ? -1.0 : 1.0, 1.0, 1.0),
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          children: [
            Positioned(left: size * 0.08, top: size * 0.06, child: SnowflakeIcon(size: size * 0.34, color: color)),
            Positioned(left: size * 0.55, top: size * 0.04, child: SnowflakeIcon(size: size * 0.18, color: color)),
            Positioned(left: size * 0.30, top: size * 0.50, child: SnowflakeIcon(size: size * 0.22, color: color)),
            Positioned(left: size * 0.72, top: size * 0.42, child: SnowflakeIcon(size: size * 0.12, color: color)),
          ],
        ),
      ),
    );
  }
}
