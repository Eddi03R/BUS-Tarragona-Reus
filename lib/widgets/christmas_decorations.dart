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

  static void draw(Canvas canvas, Offset c, double diameter, Color color) {
    final r = diameter / 2;
    final paint = Paint()
      ..color = color
      ..strokeWidth = math.max(1.2, diameter / 14)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c, c + dir * r, paint);
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
  void paint(Canvas canvas, Size size) =>
      draw(canvas, size.center(Offset.zero), size.width, color);

  @override
  bool shouldRepaint(covariant _SnowflakePainter old) => old.color != color;
}

/// Fiocchi di neve sparsi su tutta l'area disponibile (sfondo chiaro).
/// Va messo in uno Stack dentro un Positioned.fill + IgnorePointer.
class SnowScatter extends StatelessWidget {
  final Color color;
  const SnowScatter({super.key, this.color = const Color(0xFF9CC3E6)});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _ScatterPainter(color), size: Size.infinite);
}

class _ScatterPainter extends CustomPainter {
  final Color color;
  const _ScatterPainter(this.color);

  // (x frazione, y frazione, diametro px, opacità)
  static const _flakes = <(double, double, double, double)>[
    (0.06, 0.04, 20, 0.45), (0.30, 0.02, 12, 0.35), (0.52, 0.07, 16, 0.40),
    (0.80, 0.03, 10, 0.35), (0.92, 0.16, 18, 0.45), (0.14, 0.20, 14, 0.35),
    (0.42, 0.24, 22, 0.40), (0.70, 0.27, 12, 0.35), (0.04, 0.38, 16, 0.40),
    (0.26, 0.44, 10, 0.35), (0.58, 0.46, 18, 0.45), (0.88, 0.43, 14, 0.35),
    (0.12, 0.60, 20, 0.40), (0.38, 0.64, 12, 0.35), (0.66, 0.66, 16, 0.40),
    (0.94, 0.62, 10, 0.35), (0.22, 0.80, 14, 0.40), (0.50, 0.84, 20, 0.45),
    (0.78, 0.86, 12, 0.35), (0.06, 0.94, 16, 0.40), (0.90, 0.95, 18, 0.40),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (final f in _flakes) {
      _SnowflakePainter.draw(
        canvas,
        Offset(size.width * f.$1, size.height * f.$2),
        f.$3,
        color.withValues(alpha: f.$4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ScatterPainter old) => old.color != color;
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
