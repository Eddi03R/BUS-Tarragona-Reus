import 'package:flutter/material.dart';
import '../services/theme_controller.dart';

/// Colore del testo da usare sopra il banner del tema corrente.
Color themedBannerOnColor() {
  final c = ThemeController.instance;
  if (c.isHalloween || c.isChristmas) return Colors.white;
  return c.seedColor.computeLuminance() > 0.35 ? Colors.black87 : Colors.white;
}

/// Riquadro colorato con lo stesso sfondo dell'header della home:
/// Natale = taglio rosso/verde con filo bianco, Halloween = arancio→nero,
/// altri temi = sfumatura del colore scelto.
class ThemedBanner extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const ThemedBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
  });

  static LinearGradient gradient() {
    final c = ThemeController.instance;
    if (c.isChristmas) {
      return const LinearGradient(
        colors: [
          Color(0xFFE53935), Color(0xFFE53935),
          Color(0xFFFFFFFF), Color(0xFFFFFFFF),
          Color(0xFF2E9B4A), Color(0xFF2E9B4A),
        ],
        stops: [0, 0.66, 0.66, 0.675, 0.675, 1],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (c.isHalloween) {
      return const LinearGradient(
        colors: [Color(0xFFE8600A), Color(0xFF1A0500)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    final seed = c.seedColor;
    return LinearGradient(
      colors: [seed, Color.lerp(seed, Colors.black, 0.28)!],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          gradient: gradient(),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: themedBannerOnColor()),
          child: child,
        ),
      ),
    );
  }
}
