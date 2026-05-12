import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A desktop-aware card wrapper that adds a smooth scale + shadow
/// hover animation on mouse-over.
///
/// On touch devices the hover effect is invisible — the card behaves
/// like a normal widget.
///
/// Usage:
/// ```dart
/// HoverCard(
///   onTap: () => ...,
///   child: MyCardContent(),
/// )
/// ```
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppConstants.radiusLG);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: _hovered
              ? (Matrix4.identity()..scale(1.015))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.white.withOpacity(0.75),
            borderRadius: radius,
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// A subtle hover effect for sidebar navigation items — highlights
/// background on hover without scaling.
class HoverNavItem extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isSelected;
  final BorderRadius? borderRadius;

  const HoverNavItem({
    super.key,
    required this.child,
    this.onTap,
    this.isSelected = false,
    this.borderRadius,
  });

  @override
  State<HoverNavItem> createState() => _HoverNavItemState();
}

class _HoverNavItemState extends State<HoverNavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppConstants.radiusMD);
    final bgColor = widget.isSelected
        ? AppColors.primary.withOpacity(0.15)
        : _hovered
            ? Colors.white.withOpacity(0.08)
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(color: bgColor, borderRadius: radius),
          child: widget.child,
        ),
      ),
    );
  }
}
