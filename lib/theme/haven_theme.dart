import 'package:flutter/material.dart';

abstract final class HavenColors {
  static const ink = Color(0xFF070B13);
  static const night = Color(0xFF0C1422);
  static const deep = Color(0xFF111C30);
  static const slate = Color(0xFF1A2740);
  static const mist = Color(0xFF93A3BF);
  static const dim = Color(0xFF66738A);
  static const cream = Color(0xFFF7F2E7);
  static const mint = Color(0xFF67E4C4);
  static const gold = Color(0xFFF3C86B);
  static const lilac = Color(0xFFB8A4FF);
  static const coral = Color(0xFFFF8E8E);
  static const sky = Color(0xFF78C8FF);
  static const rose = Color(0xFFFF9DD3);
}

abstract final class HavenTheme {
  static ThemeData get dark {
    final scheme = const ColorScheme.dark(
      primary: HavenColors.mint,
      onPrimary: HavenColors.ink,
      secondary: HavenColors.gold,
      onSecondary: HavenColors.ink,
      tertiary: HavenColors.lilac,
      surface: HavenColors.night,
      onSurface: HavenColors.cream,
      error: HavenColors.coral,
      onError: HavenColors.ink,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: HavenColors.ink,
      fontFamily: 'Manrope',
      splashFactory: InkSparkle.splashFactory,
    );

    final text = base.textTheme.copyWith(
      displayLarge: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 54,
        height: 0.95,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
        letterSpacing: 0.2,
      ),
      displayMedium: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 42,
        height: 1,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
        letterSpacing: 0.2,
      ),
      displaySmall: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 34,
        height: 1.05,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
      ),
      headlineLarge: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 30,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
      ),
      headlineMedium: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 26,
        height: 1.1,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'Cormorant',
        fontSize: 22,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: HavenColors.cream,
      ),
      titleLarge: const TextStyle(
        fontSize: 19,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: HavenColors.cream,
        letterSpacing: -0.2,
      ),
      titleMedium: const TextStyle(
        fontSize: 15,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: HavenColors.cream,
      ),
      bodyLarge: const TextStyle(
        fontSize: 15,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: HavenColors.mist,
      ),
      bodyMedium: const TextStyle(
        fontSize: 13.5,
        height: 1.5,
        fontWeight: FontWeight.w500,
        color: HavenColors.mist,
      ),
      bodySmall: const TextStyle(
        fontSize: 11.5,
        height: 1.4,
        fontWeight: FontWeight.w600,
        color: HavenColors.dim,
        letterSpacing: 0.1,
      ),
      labelLarge: const TextStyle(
        fontSize: 13,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: HavenColors.cream,
      ),
      labelMedium: const TextStyle(
        fontSize: 10.5,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: HavenColors.mist,
      ),
      labelSmall: const TextStyle(
        fontSize: 9,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.3,
        color: HavenColors.dim,
      ),
    );

    return base.copyWith(
      textTheme: text,
      iconTheme: const IconThemeData(color: HavenColors.cream),
      dividerColor: Colors.white.withValues(alpha: 0.08),
      dialogTheme: const DialogThemeData(
        backgroundColor: HavenColors.night,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HavenColors.slate,
        contentTextStyle: text.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

LinearGradient accentGradient(Color accent, {bool strong = false}) {
  final lighter = Color.lerp(accent, Colors.white, strong ? 0.32 : 0.18)!;
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lighter, accent],
  );
}

LinearGradient panelGradient({Color? tint, double opacity = 1}) {
  final base = tint ?? const Color(0xFFB8C6E3);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.lerp(
        HavenColors.slate,
        base,
        0.1,
      )!.withValues(alpha: 0.58 * opacity),
      HavenColors.night.withValues(alpha: 0.86 * opacity),
    ],
  );
}
