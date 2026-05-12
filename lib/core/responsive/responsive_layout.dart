import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';

/// The heart of SnapBid's responsive system.
///
/// Uses [LayoutBuilder] to pick between [mobile] and [desktop] builders
/// based on [AppBreakpoints]. Tablet (≥600px) shares the desktop layout.
///
/// Wraps the transition in an [AnimatedSwitcher] for a smooth fade whenever
/// the window crosses a breakpoint boundary.
///
/// Usage:
/// ```dart
/// ResponsiveLayout(
///   mobile:  (ctx) => HomeMobile(),
///   desktop: (ctx) => HomeDesktop(),
/// )
/// ```
class ResponsiveLayout extends StatelessWidget {
  final WidgetBuilder mobile;
  final WidgetBuilder desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= AppBreakpoints.desktopMin;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isDesktop
              ? KeyedSubtree(key: const ValueKey('desktop'), child: desktop(context))
              : KeyedSubtree(key: const ValueKey('mobile'),  child: mobile(context)),
        );
      },
    );
  }
}
