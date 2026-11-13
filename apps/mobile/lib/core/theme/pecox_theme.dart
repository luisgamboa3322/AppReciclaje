import 'package:flutter/material.dart';

/// Official PECOX Vision color tokens derived from `docs/ui-ux/design-system.md`.
abstract final class PecoxColors {
  static const forest900 = Color(0xFF12382D);
  static const forest800 = Color(0xFF0C6D53);
  static const emerald700 = Color(0xFF087D60);
  static const emerald500 = Color(0xFF12C994);
  static const mint100 = Color(0xFFE9FAF3);
  static const mint200 = Color(0xFFD7F6EB);
  static const lime300 = Color(0xFFC9F36B);
  static const canvas = Color(0xFFFAFCFB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF17221E);
  static const textMuted = Color(0xFF66766E);
  static const border = Color(0xFFE7EFEB);
  static const error = Color(0xFFC83D42);
  static const warningBg = Color(0xFFFFF7E5);
  static const warningInk = Color(0xFF7A6125);
}

abstract final class PecoxSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class PecoxRadii {
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 999;
}

abstract final class PecoxTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: PecoxColors.emerald700,
      primary: PecoxColors.emerald700,
      onPrimary: Colors.white,
      secondary: PecoxColors.forest900,
      onSecondary: Colors.white,
      surface: PecoxColors.surface,
      onSurface: PecoxColors.ink,
      error: PecoxColors.error,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: PecoxColors.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: PecoxColors.canvas,
        foregroundColor: PecoxColors.forest900,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: PecoxColors.forest900,
          letterSpacing: -0.3,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: PecoxColors.emerald700,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PecoxRadii.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: PecoxColors.forest900,
          backgroundColor: PecoxColors.surface,
          minimumSize: const Size(double.infinity, 48),
          side: const BorderSide(color: PecoxColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PecoxRadii.md),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PecoxColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PecoxRadii.md),
          borderSide: const BorderSide(color: PecoxColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PecoxRadii.md),
          borderSide: const BorderSide(color: PecoxColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PecoxRadii.md),
          borderSide: const BorderSide(color: PecoxColors.emerald700, width: 1.6),
        ),
      ),
      cardTheme: CardTheme(
        color: PecoxColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PecoxRadii.lg),
          side: const BorderSide(color: PecoxColors.border),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
