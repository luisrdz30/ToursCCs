import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFAB3500);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFFF6B35);
  static const Color onPrimaryContainer = Color(0xFF5F1900);
  
  static const Color secondary = Color(0xFF27657C);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFA8E2FD);
  static const Color onSecondaryContainer = Color(0xFF28667D);
  
  static const Color tertiary = Color(0xFF00677E);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF00A7CB);
  static const Color onTertiaryContainer = Color(0xFF003744);

  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  
  static const Color background = Color(0xFFFFF8F6);
  static const Color onBackground = Color(0xFF261814);
  
  static const Color surface = Color(0xFFFFF8F6);
  static const Color onSurface = Color(0xFF261814);
  static const Color onSurfaceVariant = Color(0xFF594139);
  static const Color surfaceVariant = Color(0xFFF7DDD5);
  static const Color surfaceContainerHighest = Color(0xFFF7DDD5);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFFFE9E3);
  static const Color surfaceContainerLow = Color(0xFFFFF1ED);
  static const Color outline = Color(0xFF8D7168);
  static const Color outlineVariant = Color(0xFFE1BFB5);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: error,
        onError: onError,
        errorContainer: errorContainer,
        onErrorContainer: onErrorContainer,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: background,
      textTheme: TextTheme(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          height: 56 / 48,
          letterSpacing: -0.02 * 48,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 40 / 32,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28, // headline-lg-mobile
          fontWeight: FontWeight.w700,
          height: 36 / 28,
        ),
        titleMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 28 / 20,
        ),
        bodyLarge: GoogleFonts.beVietnamPro(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 28 / 18,
        ),
        bodyMedium: GoogleFonts.beVietnamPro(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 20 / 14,
          letterSpacing: 0.01 * 14,
        ),
        labelMedium: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 16 / 12,
          letterSpacing: 0.05 * 12,
        ),
      ),
    );
  }
}