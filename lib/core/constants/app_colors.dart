import 'package:flutter/material.dart';

/// SnapBid Design System — Color Tokens
/// Extracted directly from Google Stitch "SnapBid Premium Redesign UI"
abstract class AppColors {
  // ─── Brand Primary (Indigo) ───────────────────────────────────────────────
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4648D4);
  static const Color primaryContainer = Color(0xFF6063EE);
  static const Color primaryFixed = Color(0xFFE1E0FF);
  static const Color primaryFixedDim = Color(0xFFC0C1FF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFFFFFBFF);

  // ─── Secondary (Emerald — success / >24hr timers) ─────────────────────────
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryDark = Color(0xFF006C49);
  static const Color secondaryContainer = Color(0xFF6CF8BB);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF00714D);

  // ─── Accent (Coral — urgency / <1hr timers) ───────────────────────────────
  static const Color accent = Color(0xFFFF6B6B);
  static const Color tertiary = Color(0xFF904900);
  static const Color tertiaryContainer = Color(0xFFB55D00);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // ─── Surface ──────────────────────────────────────────────────────────────
  static const Color surface = Color(0xFFFCF8FF);
  static const Color surfaceDim = Color(0xFFDBD8E4);
  static const Color surfaceBright = Color(0xFFFCF8FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF5F2FE);
  static const Color surfaceContainer = Color(0xFFEFECF8);
  static const Color surfaceContainerHigh = Color(0xFFE9E6F3);
  static const Color surfaceContainerHighest = Color(0xFFE4E1ED);

  // ─── On Surface ───────────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFF1B1B23);
  static const Color onSurfaceVariant = Color(0xFF464554);

  // ─── Outline ──────────────────────────────────────────────────────────────
  static const Color outline = Color(0xFF767586);
  static const Color outlineVariant = Color(0xFFC7C4D7);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onError = Color(0xFFFFFFFF);

  // ─── Background ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFFCF8FF);
  static const Color onBackground = Color(0xFF1B1B23);

  // ─── Glassmorphism ────────────────────────────────────────────────────────
  static const Color glassWhite = Color(0xB3FFFFFF);       // 70% white
  static const Color glassBorder = Color(0x4DFFFFFF);      // 30% white
  static const Color glassOverlay = Color(0x1AFFFFFF);     // 10% white

  // ─── Gradient stops ───────────────────────────────────────────────────────
  static const Color gradientStart = Color(0xFFFCE4EC);    // soft pink
  static const Color gradientMid = Color(0xFFEDE7F6);      // soft purple
  static const Color gradientEnd = Color(0xFFE3F2FD);      // soft blue

  // ─── Shadows ──────────────────────────────────────────────────────────────
  static const Color shadowLight = Color(0x0D000000);      // 5% black
  static const Color shadowMedium = Color(0x1A000000);     // 10% black

  // ─── Countdown chip states ────────────────────────────────────────────────
  static const Color timerGreen = Color(0xFF10B981);       // >24 hours
  static const Color timerAmber = Color(0xFFF59E0B);       // 1hr–24hr
  static const Color timerCoral = Color(0xFFFF6B6B);       // <1 hour
}
