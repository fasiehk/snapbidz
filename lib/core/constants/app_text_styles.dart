import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// SnapBid Design System — Typography
/// Manrope → Headings | Inter → Body/Labels
abstract class AppTextStyles {
  // ─── Display (Manrope) ────────────────────────────────────────────────────
  static TextStyle displayLarge = GoogleFonts.manrope(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02 * 48,
    color: AppColors.onSurface,
  );

  static TextStyle displayMedium = GoogleFonts.manrope(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.02 * 36,
    color: AppColors.onSurface,
  );

  // ─── Headlines (Manrope) ──────────────────────────────────────────────────
  static TextStyle headlineLarge = GoogleFonts.manrope(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.3,
    letterSpacing: -0.01 * 32,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.manrope(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  // ─── Title (Manrope) ──────────────────────────────────────────────────────
  static TextStyle titleLarge = GoogleFonts.manrope(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );
  

  static TextStyle titleSmall = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.onSurface,
  );

  // ─── Body (Inter) ─────────────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.onSurfaceVariant,
  );

  // ─── Label (Inter) ────────────────────────────────────────────────────────
  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.0,
    letterSpacing: 0.5,
    color: AppColors.onSurfaceVariant,
  );

  // ─── Price (Manrope — special) ────────────────────────────────────────────
  static TextStyle priceLarge = GoogleFonts.manrope(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    height: 1.2,
    color: AppColors.primary,
  );

  static TextStyle priceMedium = GoogleFonts.manrope(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
  );

  static TextStyle priceSmall = GoogleFonts.manrope(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.primary,
  );
}
