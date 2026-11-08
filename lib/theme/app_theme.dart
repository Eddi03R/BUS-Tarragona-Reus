import 'package:flutter/material.dart';

class AppTheme {
  static const accent = Color(0xFFFF7A45);

  static ThemeData light(Color seed) => _build(seed, Brightness.light);
  static ThemeData dark(Color seed) => _build(seed, Brightness.dark);

  static ThemeData halloween() {
    const pumpkin = Color(0xFFFF6B00);
    const midnight = Color(0xFF120800);
    const parchment = Color(0xFFF5E6C8);

    final base = ColorScheme.fromSeed(
      seedColor: pumpkin,
      brightness: Brightness.dark,
    );
    final scheme = base.copyWith(
      surface: midnight,
      surfaceContainerHighest: const Color(0xFF3D2200), // card bg - più leggibile
      surfaceContainerHigh: const Color(0xFF2D1500),
      surfaceContainerLow: const Color(0xFF1F0C00),
      surfaceContainer: const Color(0xFF241000),
      surfaceDim: const Color(0xFF0A0400),
      surfaceBright: const Color(0xFF4A2800),
      onSurface: parchment,
      onSurfaceVariant: const Color(0xFFEBCE8A), // testo secondario più brillante
      secondary: const Color(0xFF9B59B6),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFF5A2480),
      onSecondaryContainer: const Color(0xFFF0DAFF),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: midnight,
      cardColor: scheme.surfaceContainerHigh,
      hintColor: scheme.onSurfaceVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: midnight,
        foregroundColor: parchment,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: pumpkin,
          foregroundColor: Colors.black,
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

  /// Tema natalizio: sempre chiaro, rosso/verde su sfondo "neve".
  static ThemeData christmas() {
    const red = Color(0xFFC62829);
    const green = Color(0xFF1B5E20);
    const snow = Color(0xFFF8FBFF);

    final base = ColorScheme.fromSeed(seedColor: red, brightness: Brightness.light);
    final scheme = base.copyWith(
      primary: red,
      onPrimary: Colors.white,
      secondary: green,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFD7EFD9),
      onSecondaryContainer: const Color(0xFF0B3D12),
      surface: snow,
      surfaceContainerHighest: const Color(0xFFFBE4E4),
      surfaceContainerHigh: const Color(0xFFFDEEEE),
      surfaceContainerLow: const Color(0xFFFFF7F7),
      surfaceContainer: const Color(0xFFFEF1F1),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: snow,
      cardColor: Colors.white,
      hintColor: scheme.onSurfaceVariant,
      appBarTheme: const AppBarTheme(
        backgroundColor: snow,
        foregroundColor: Color(0xFF3A0A0A),
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: green,
          foregroundColor: Colors.white,
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

  static ThemeData _build(Color seed, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? scheme.surface : const Color(0xFFF5F7F6),
      cardColor: isDark ? scheme.surfaceContainerHigh : Colors.white,
      hintColor: scheme.onSurfaceVariant,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? scheme.surfaceContainerHigh : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? scheme.surfaceContainerHigh : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
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
