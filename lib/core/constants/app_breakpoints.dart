import 'package:flutter/material.dart';

/// Screen-size enum used throughout the app.
enum ScreenSize { mobile, desktop }

/// Breakpoint constants and helpers for SnapBid's responsive system.
///
/// Rule:
///   mobile  : width < 600
///   desktop : width >= 600   (tablet + desktop share the desktop layout)
class AppBreakpoints {
  AppBreakpoints._();

  // ── Raw thresholds ────────────────────────────────────────────────────────
  static const double mobileMax = 599;
  static const double desktopMin = 600;

  // ── Content constraints ───────────────────────────────────────────────────
  /// Maximum width of centred content on large screens.
  static const double maxContentWidth = 1280;

  /// Sidebar width on desktop.
  static const double sidebarWidth = 240;

  // ── Padding ───────────────────────────────────────────────────────────────
  static const double mobilePadding = 16;
  static const double desktopPadding = 48;

  // ── Grid columns ──────────────────────────────────────────────────────────
  static const int mobileColumns = 2;
  static const int desktopColumns = 4;

  // ── Core helper ──────────────────────────────────────────────────────────
  /// Returns the [ScreenSize] for the current [BuildContext].
  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= desktopMin ? ScreenSize.desktop : ScreenSize.mobile;
  }

  /// True when the current window is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenSize.desktop;

  /// True when the current window is mobile-sized.
  static bool isMobile(BuildContext context) =>
      of(context) == ScreenSize.mobile;

  // ── Computed values ───────────────────────────────────────────────────────
  /// Horizontal content padding appropriate for the current screen size.
  static double horizontalPadding(BuildContext context) =>
      isDesktop(context) ? desktopPadding : mobilePadding;

  /// Grid cross-axis count appropriate for the current screen size.
  static int gridColumns(BuildContext context) =>
      isDesktop(context) ? desktopColumns : mobileColumns;
}
