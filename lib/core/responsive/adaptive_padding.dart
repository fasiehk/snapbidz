import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';

/// Wraps [child] with screen-appropriate horizontal padding and,
/// on desktop, clamps total content width to [AppBreakpoints.maxContentWidth].
///
/// Usage:
/// ```dart
/// AdaptivePadding(child: MyContent())
/// ```
class AdaptivePadding extends StatelessWidget {
  final Widget child;

  /// Optional override for the horizontal padding.
  final double? horizontal;

  const AdaptivePadding({super.key, required this.child, this.horizontal});

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);
    final hPad = horizontal ?? AppBreakpoints.horizontalPadding(context);

    if (!isDesktop) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: child,
      );
    }

    // On desktop: centre-constrain content.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: child,
        ),
      ),
    );
  }
}

/// A desktop content shell that centres and max-width constrains
/// its child without adding extra padding — useful for full-bleed
/// sections that still need the width cap.
class DesktopContentBox extends StatelessWidget {
  final Widget child;
  const DesktopContentBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppBreakpoints.maxContentWidth),
        child: child,
      ),
    );
  }
}
