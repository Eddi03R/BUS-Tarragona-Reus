import 'package:flutter/material.dart';

/// Ragnatela disegnata a canvas, ancorata a un angolo dello schermo.
class CobwebCorner extends StatelessWidget {
  final double size;
  final Color color;
  final Alignment corner;

  const CobwebCorner({
    super.key,
    this.size = 64,
    this.color = Colors.white24,
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
      child: CustomPaint(
        size: Size(size, size),
        painter: _CobwebPainter(color: color),
      ),
    );
  }
}

class _CobwebPainter extends CustomPainter {
  final Color color;
  const _CobwebPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Raggi dall'angolo (0,0) verso il lato opposto
    final rays = <Offset>[
      Offset(size.width, 0),
      Offset(size.width, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.75),
      Offset(size.width * 0.25, size.height),
      Offset(0, size.height),
    ];
    for (final end in rays) {
      canvas.drawLine(Offset.zero, end, paint);
    }

    // Archi concentrici che collegano i raggi
    for (final f in [0.35, 0.6, 0.85]) {
      final path = Path();
      for (var i = 0; i < rays.length; i++) {
        final p = Offset.lerp(Offset.zero, rays[i], f)!;
        i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CobwebPainter oldDelegate) => oldDelegate.color != color;
}

/// Teschio minimale disegnato a path: cranio + mascella, occhi/naso/denti
/// ritagliati con BlendMode.clear.
class SkullIcon extends StatelessWidget {
  final double size;
  final Color color;
  const SkullIcon({super.key, this.size = 20, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size * 1.1),
      painter: _SkullPainter(color: color),
    );
  }
}

class _SkullPainter extends CustomPainter {
  final Color color;
  const _SkullPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final fill = Paint()..color = color;
    final cut = Paint()..blendMode = BlendMode.clear;

    final skull = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.08, 0, w * 0.84, h * 0.62), Radius.circular(w * 0.38)))
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.22, h * 0.46, w * 0.56, h * 0.32), Radius.circular(w * 0.12)));

    canvas.saveLayer(Rect.fromLTWH(0, 0, w, h), Paint());
    canvas.drawPath(skull, fill);

    canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.2, w * 0.24, h * 0.26), cut);
    canvas.drawOval(Rect.fromLTWH(w * 0.58, h * 0.2, w * 0.24, h * 0.26), cut);

    final nose = Path()
      ..moveTo(w * 0.5, h * 0.42)
      ..lineTo(w * 0.42, h * 0.56)
      ..lineTo(w * 0.58, h * 0.56)
      ..close();
    canvas.drawPath(nose, cut);

    for (final cx in [0.37, 0.5, 0.63]) {
      canvas.drawRect(Rect.fromLTWH(w * cx - w * 0.02, h * 0.6, w * 0.04, h * 0.16), cut);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SkullPainter oldDelegate) => oldDelegate.color != color;
}
