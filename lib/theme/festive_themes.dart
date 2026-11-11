import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;

/// Decorazione di sfondo associata a un tema festivo.
enum FestiveDeco { santaTecla, fiesta, italy, newYearLight, newYearDark }

/// Tema festivo "a tavolozza fissa" (Santa Tecla, Fiesta, Italia, Capodanno).
/// Come Natale e Halloween blocca la modalità chiaro/scuro: [brightness].
class FestiveTheme {
  /// Colore identificativo salvato nelle preferenze (non è un colore da mostrare).
  final Color seed;
  final String label;
  final String emoji;
  final Brightness brightness;

  /// Colore dei pulsanti/chip attivi nella home.
  final Color accent;

  /// Colore pieno per riquadri con testo bianco (es. dettaglio corsa).
  final Color hero;
  final LinearGradient gradient;
  final Color onBanner;
  final FestiveDeco deco;

  /// Motto della testata; `{year}` viene sostituito col prossimo anno nuovo.
  final String motto;
  final String mottoLeft;
  final String mottoRight;

  /// Colori della miniatura nelle Impostazioni.
  final List<Color> swatch;
  final ThemeData Function() build;

  const FestiveTheme({
    required this.seed,
    required this.label,
    required this.emoji,
    required this.brightness,
    required this.accent,
    required this.hero,
    required this.gradient,
    required this.onBanner,
    required this.deco,
    required this.motto,
    required this.mottoLeft,
    required this.mottoRight,
    required this.swatch,
    required this.build,
  });

  String get mottoText {
    final now = DateTime.now();
    final year = now.month >= 6 ? now.year + 1 : now.year; // da giugno in poi: prossimo Capodanno
    return motto.replaceAll('{year}', year.toString().split('').join(' '));
  }
}

class FestiveThemes {
  FestiveThemes._();

  static const santaTeclaSeed = Color(0xFFB3261F);
  static const fiestaSeed = Color(0xFFC8431C);
  static const italySeed = Color(0xFF008C46);
  static const newYearLightSeed = Color(0xFF1E2A5B);
  static const newYearDarkSeed = Color(0xFF0C1031);

  static final santaTecla = FestiveTheme(
    seed: santaTeclaSeed,
    label: 'Santa Tecla 🔥',
    emoji: '🔥',
    brightness: Brightness.light,
    accent: const Color(0xFFB3261E),
    hero: const Color(0xFFB3261E),
    gradient: const LinearGradient(
      colors: [Color(0xFFB3261E), Color(0xFFE5541B), Color(0xFFE8A100)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    onBanner: Colors.white,
    deco: FestiveDeco.santaTecla,
    motto: 'V I S C A  S A N T A  T E C L A',
    mottoLeft: '🔥',
    mottoRight: '🏰',
    swatch: const [Color(0xFFB3261E), Color(0xFFE5541B), Color(0xFFE8A100)],
    build: () => _build(
      brightness: Brightness.light,
      primary: const Color(0xFFB3261E),
      onPrimary: Colors.white,
      secondary: const Color(0xFFE8A100),
      onSecondary: const Color(0xFF2B1A12),
      surface: const Color(0xFFFFF6E8),
      onSurface: const Color(0xFF2B1A12),
      onSurfaceVariant: const Color(0xFF7A5A44),
      card: Colors.white,
      highest: const Color(0xFFF7E0BE),
      high: const Color(0xFFFBEBD3),
      low: const Color(0xFFFFF9F0),
      mid: const Color(0xFFFCEFDC),
      appBar: const Color(0xFFB3261E),
      onAppBar: Colors.white,
      cta: const Color(0xFFB3261E),
      onCta: Colors.white,
    ),
  );

  static final fiesta = FestiveTheme(
    seed: fiestaSeed,
    label: 'Spagna 💃',
    emoji: '💃',
    brightness: Brightness.light,
    accent: const Color(0xFFC8431B),
    hero: const Color(0xFFC8431B),
    gradient: const LinearGradient(
      colors: [Color(0xFFF7A31C), Color(0xFFE8581F), Color(0xFFC42B3A)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    onBanner: Colors.white,
    deco: FestiveDeco.fiesta,
    motto: '¡ F I E S T A !',
    mottoLeft: '🎉',
    mottoRight: '💃',
    swatch: const [Color(0xFFF7A31C), Color(0xFFE8581F), Color(0xFFC42B3A)],
    build: () => _build(
      brightness: Brightness.light,
      primary: const Color(0xFFC8431B),
      onPrimary: Colors.white,
      secondary: const Color(0xFFF7A31C),
      onSecondary: const Color(0xFF3A1A0C),
      surface: const Color(0xFFFFF1DC),
      onSurface: const Color(0xFF3A1A0C),
      onSurfaceVariant: const Color(0xFF8A5A3A),
      card: Colors.white,
      highest: const Color(0xFFFAD9AE),
      high: const Color(0xFFFFE6C2),
      low: const Color(0xFFFFF6E8),
      mid: const Color(0xFFFFEBCD),
      appBar: const Color(0xFFC8431B),
      onAppBar: Colors.white,
      cta: const Color(0xFFC42B3A),
      onCta: Colors.white,
    ),
  );

  static final italy = FestiveTheme(
    seed: italySeed,
    label: 'Italia 🍕',
    emoji: '🍕',
    brightness: Brightness.light,
    accent: const Color(0xFF008C45),
    hero: const Color(0xFF008C45),
    // Taglio netto verde / filo bianco / rosso, come il Natale.
    gradient: const LinearGradient(
      colors: [
        Color(0xFF008C45), Color(0xFF008C45),
        Color(0xFFF4F5F0), Color(0xFFF4F5F0),
        Color(0xFFCD212A), Color(0xFFCD212A),
      ],
      stops: [0, 0.64, 0.64, 0.68, 0.68, 1],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    onBanner: Colors.white,
    deco: FestiveDeco.italy,
    motto: 'B U O N  V I A G G I O',
    mottoLeft: '🍕',
    mottoRight: '☕',
    swatch: const [Color(0xFF008C45), Color(0xFFF4F5F0), Color(0xFFCD212A)],
    build: () => _build(
      brightness: Brightness.light,
      primary: const Color(0xFF008C45),
      onPrimary: Colors.white,
      secondary: const Color(0xFFCD212A),
      onSecondary: Colors.white,
      surface: const Color(0xFFFAF8F2),
      onSurface: const Color(0xFF1C2A22),
      onSurfaceVariant: const Color(0xFF66705F),
      card: Colors.white,
      highest: const Color(0xFFE6E4D6),
      high: const Color(0xFFF1EFE4),
      low: const Color(0xFFFCFBF7),
      mid: const Color(0xFFF5F3EA),
      appBar: const Color(0xFF008C45),
      onAppBar: Colors.white,
      cta: const Color(0xFFCD212A),
      onCta: Colors.white,
    ),
  );

  static final newYearLight = FestiveTheme(
    seed: newYearLightSeed,
    label: 'Capodanno 🥂',
    emoji: '🥂',
    brightness: Brightness.light,
    accent: const Color(0xFF1E2A5A),
    hero: const Color(0xFF1E2A5A),
    gradient: const LinearGradient(
      colors: [Color(0xFF1E2A5A), Color(0xFF3A4A8C), Color(0xFFC9A227)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    onBanner: Colors.white,
    deco: FestiveDeco.newYearLight,
    motto: 'B U O N  {year}',
    mottoLeft: '🥂',
    mottoRight: '🎆',
    swatch: const [Color(0xFF1E2A5A), Color(0xFF3A4A8C), Color(0xFFC9A227)],
    build: () => _build(
      brightness: Brightness.light,
      primary: const Color(0xFF1E2A5A),
      onPrimary: const Color(0xFFF5E2A0),
      secondary: const Color(0xFFC9A227),
      onSecondary: const Color(0xFF1B1F33),
      surface: const Color(0xFFFBF8F0),
      onSurface: const Color(0xFF1B1F33),
      onSurfaceVariant: const Color(0xFF6B6A7A),
      card: Colors.white,
      highest: const Color(0xFFEFE5C8),
      high: const Color(0xFFF6EFD9),
      low: const Color(0xFFFDFBF5),
      mid: const Color(0xFFF9F3E2),
      appBar: const Color(0xFF1E2A5A),
      onAppBar: const Color(0xFFF5E2A0),
      cta: const Color(0xFF1E2A5A),
      onCta: const Color(0xFFF5E2A0),
    ),
  );

  static final newYearDark = FestiveTheme(
    seed: newYearDarkSeed,
    label: 'Capodanno 🎆',
    emoji: '🎆',
    brightness: Brightness.dark,
    accent: const Color(0xFFF2C94C),
    hero: const Color(0xFF3A2A8C),
    gradient: const LinearGradient(
      colors: [Color(0xFF2A1B6E), Color(0xFF6B3FD0), Color(0xFFC79A2E)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    onBanner: Colors.white,
    deco: FestiveDeco.newYearDark,
    motto: 'B U O N  {year}',
    mottoLeft: '🥂',
    mottoRight: '🎆',
    swatch: const [Color(0xFF0C1030), Color(0xFF6B3FD0), Color(0xFFF2C94C)],
    build: () => _build(
      brightness: Brightness.dark,
      primary: const Color(0xFFF2C94C),
      onPrimary: const Color(0xFF1B1400),
      secondary: const Color(0xFF9B6BFF),
      onSecondary: Colors.white,
      surface: const Color(0xFF0C1030),
      onSurface: const Color(0xFFEDE8FF),
      onSurfaceVariant: const Color(0xFFB4B0E0),
      card: const Color(0xFF1A1F4A),
      highest: const Color(0xFF2C3270),
      high: const Color(0xFF222859),
      low: const Color(0xFF141842),
      mid: const Color(0xFF1B2050),
      appBar: const Color(0xFF0C1030),
      onAppBar: const Color(0xFFF2C94C),
      cta: const Color(0xFFF2C94C),
      onCta: const Color(0xFF1B1400),
    ),
  );

  static final List<FestiveTheme> all = [
    santaTecla,
    fiesta,
    italy,
    newYearLight,
    newYearDark,
  ];

  static FestiveTheme? byColor(Color c) {
    for (final t in all) {
      if (t.seed.toARGB32() == c.toARGB32()) return t;
    }
    return null;
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color card,
    required Color highest,
    required Color high,
    required Color low,
    required Color mid,
    required Color appBar,
    required Color onAppBar,
    required Color cta,
    required Color onCta,
  }) {
    final base = ColorScheme.fromSeed(seedColor: primary, brightness: brightness);
    final scheme = base.copyWith(
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: onSecondary,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      surfaceContainerHighest: highest,
      surfaceContainerHigh: high,
      surfaceContainerLow: low,
      surfaceContainer: mid,
    );
    final lightBar = appBar.computeLuminance() < 0.5;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      cardColor: card,
      hintColor: onSurfaceVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: appBar,
        foregroundColor: onAppBar,
        // Icone di stato chiare su barra scura e viceversa.
        systemOverlayStyle: lightBar ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cta,
          foregroundColor: onCta,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }
}

/// Decorazione di sfondo leggera (statica) dietro i contenuti di una schermata.
class FestiveScatter extends StatelessWidget {
  final FestiveDeco deco;
  const FestiveScatter(this.deco, {super.key});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _FestivePainter(deco), size: Size.infinite);
}

class _FestivePainter extends CustomPainter {
  final FestiveDeco deco;
  _FestivePainter(this.deco);

  /// Generatore pseudo-casuale deterministico: la decorazione non "salta".
  math.Random get _rnd => math.Random(deco.index * 97 + 13);

  @override
  void paint(Canvas canvas, Size size) {
    switch (deco) {
      case FestiveDeco.santaTecla:
        _santaTecla(canvas, size);
      case FestiveDeco.fiesta:
        _fiesta(canvas, size);
      case FestiveDeco.italy:
        _italy(canvas, size);
      case FestiveDeco.newYearLight:
        _confetti(canvas, size);
      case FestiveDeco.newYearDark:
        _night(canvas, size);
    }
  }

  void _spark(Canvas canvas, Offset c, double r, Paint p) {
    final path = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r);
    canvas.drawPath(path, p);
  }

  void _santaTecla(Canvas canvas, Size size) {
    final r = _rnd;
    // Torre umana (castell) sfumata in basso a destra.
    final tower = Paint()..color = const Color(0xFFB3261E).withValues(alpha: 0.10);
    final base = Offset(size.width - 70, size.height - 28);
    for (var row = 0; row < 5; row++) {
      final n = 5 - row;
      for (var i = 0; i < n; i++) {
        final x = base.dx + (i - (n - 1) / 2) * 17;
        final y = base.dy - row * 20;
        canvas.drawCircle(Offset(x, y - 8), 5.5, tower);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(x, y + 2), width: 11, height: 14),
              const Radius.circular(4)),
          tower,
        );
      }
    }
    // Scintille dorate dei correfocs.
    for (var i = 0; i < 26; i++) {
      final p = Paint()
        ..color = (i.isEven ? const Color(0xFFE8A100) : const Color(0xFFE5541B))
            .withValues(alpha: 0.18 + r.nextDouble() * 0.2);
      _spark(canvas, Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
          3 + r.nextDouble() * 4, p);
    }
  }

  void _fiesta(Canvas canvas, Size size) {
    final r = _rnd;
    // Bandierine di carta appese in alto.
    final string = Paint()
      ..color = const Color(0xFF8A5A3A).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final w = size.width;
    final sag = 16.0;
    final line = Path()..moveTo(0, 2);
    line.quadraticBezierTo(w / 2, 2 + sag * 2, w, 2);
    canvas.drawPath(line, string);
    const colors = [Color(0xFFC42B3A), Color(0xFFF7A31C), Color(0xFFE8581F), Color(0xFFFFFFFF)];
    final count = (w / 26).floor();
    for (var i = 0; i < count; i++) {
      final t = (i + 0.5) / count;
      final x = t * w;
      final y = 2 + sag * 2 * t * (1 - t) * 2;
      final flag = Path()
        ..moveTo(x - 9, y)
        ..lineTo(x + 9, y)
        ..lineTo(x, y + 20)
        ..close();
      canvas.drawPath(flag, Paint()..color = colors[i % 4].withValues(alpha: 0.75));
    }
    // Coriandoli caldi sparsi.
    for (var i = 0; i < 30; i++) {
      final p = Paint()..color = colors[i % 3].withValues(alpha: 0.2);
      final c = Offset(r.nextDouble() * w, 60 + r.nextDouble() * (size.height - 60));
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(r.nextDouble() * math.pi);
      canvas.drawRect(const Rect.fromLTWH(0, 0, 5, 9), p);
      canvas.restore();
    }
    // Sole in basso a destra.
    final sun = Offset(w - 34, size.height - 40);
    canvas.drawCircle(sun, 16, Paint()..color = const Color(0xFFF7A31C).withValues(alpha: 0.2));
    final ray = Paint()
      ..color = const Color(0xFFF7A31C).withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var a = 0; a < 12; a++) {
      final t = a / 12 * math.pi * 2;
      canvas.drawLine(sun + Offset(math.cos(t), math.sin(t)) * 22,
          sun + Offset(math.cos(t), math.sin(t)) * 32, ray);
    }
  }

  void _italy(Canvas canvas, Size size) {
    // Ramo d'ulivo in basso a sinistra, con qualche oliva rossa.
    final green = Paint()..color = const Color(0xFF008C45).withValues(alpha: 0.16);
    final stem = Paint()
      ..color = const Color(0xFF008C45).withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(-6, size.height - 10)
      ..cubicTo(60, size.height - 40, 120, size.height - 34, 190, size.height - 84);
    canvas.drawPath(path, stem);
    for (var i = 0; i <= 10; i++) {
      final t = i / 10;
      final x = -6 + t * 196;
      final y = size.height - 10 - t * 74 - math.sin(t * 3) * 12;
      final side = i.isEven ? -1.0 : 1.0;
      canvas.save();
      canvas.translate(x, y + side * -8);
      canvas.rotate(side * -0.7);
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 24, height: 8), green);
      canvas.restore();
    }
    final olive = Paint()..color = const Color(0xFFCD212A).withValues(alpha: 0.18);
    canvas.drawCircle(Offset(70, size.height - 42), 4, olive);
    canvas.drawCircle(Offset(125, size.height - 52), 4, olive);
    // Tre puntini tricolore in alto a destra.
    final dots = [const Color(0xFF008C45), const Color(0xFFF4F5F0), const Color(0xFFCD212A)];
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(size.width - 46 + i * 12, 14), 4,
          Paint()..color = dots[i].withValues(alpha: i == 1 ? 0.9 : 0.35));
    }
  }

  void _confetti(Canvas canvas, Size size) {
    final r = _rnd;
    const colors = [Color(0xFFC9A227), Color(0xFF1E2A5A), Color(0xFFE8C85A), Color(0xFF8E9BD6)];
    for (var i = 0; i < 46; i++) {
      final p = Paint()..color = colors[i % 4].withValues(alpha: 0.28);
      canvas.save();
      canvas.translate(r.nextDouble() * size.width, r.nextDouble() * size.height);
      canvas.rotate(r.nextDouble() * math.pi);
      canvas.drawRect(Rect.fromLTWH(0, 0, 4 + r.nextDouble() * 3, 8 + r.nextDouble() * 4), p);
      canvas.restore();
    }
  }

  void _night(Canvas canvas, Size size) {
    final r = _rnd;
    // Stelle.
    for (var i = 0; i < 60; i++) {
      canvas.drawCircle(
        Offset(r.nextDouble() * size.width, r.nextDouble() * size.height),
        0.6 + r.nextDouble() * 1.3,
        Paint()..color = Colors.white.withValues(alpha: 0.2 + r.nextDouble() * 0.4),
      );
    }
    // Tre fuochi d'artificio fermi.
    const colors = [Color(0xFFF2C94C), Color(0xFF9B6BFF), Colors.white];
    final bursts = [
      Offset(size.width * 0.22, size.height - 60),
      Offset(size.width * 0.78, size.height - 120),
      Offset(size.width * 0.5, size.height - 40),
    ];
    for (var j = 0; j < bursts.length; j++) {
      final p = Paint()
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;
      for (var a = 0; a < 14; a++) {
        final t = a / 14 * math.pi * 2;
        final d = Offset(math.cos(t), math.sin(t));
        p.color = colors[(a + j) % 3].withValues(alpha: 0.28);
        canvas.drawLine(bursts[j] + d * 6, bursts[j] + d * (22 + j * 4), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FestivePainter old) => old.deco != deco;
}
