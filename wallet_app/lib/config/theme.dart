import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFF0C101A);
  static const Color surface = Color(0xFF131A29);
  static const Color surfaceLight = Color(0xFF1C2538);
  static const Color surfaceBorder = Color(0x1FFFFFFF);
  
  // Vibrant Orange Palette matching design
  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeLight = Color(0xFFFFA23A);
  static const Color orangeDark = Color(0xFFE56A00);
  static const Color orangeGlow = Color(0x4DFF7A00);

  // Status colors
  static const Color success = Color(0xFF00E676);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFAB00);
  static const Color info = Color(0xFF2979FF);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E9BAE);
  static const Color textTertiary = Color(0xFF53627A);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.orange,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        secondary: AppColors.orangeLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 26,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: GoogleFonts.outfit(color: AppColors.textTertiary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
      ),
    );
  }
}
