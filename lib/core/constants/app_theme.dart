import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// SnapBid — Material Theme
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        error: AppColors.error,
        onError: AppColors.onError,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displayLarge: GoogleFonts.manrope(
          fontSize: 48, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        ),
        headlineLarge: GoogleFonts.manrope(
          fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.manrope(
          fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.onSurface,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.onSurface),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
