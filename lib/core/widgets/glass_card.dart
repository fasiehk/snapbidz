import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// Reusable glassmorphism card — the core visual component of SnapBid.
/// Used on Home, Browse, Details, Watchlist, Profile, Auth screens.
///
/// Recipe (from Stitch design system):
///   - 70% white background
///   - 10px backdrop blur
///   - 1px white border at 30% opacity
///   - Soft ambient shadow
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(AppConstants.spaceLG),
    this.borderRadius = AppConstants.radiusLG,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppConstants.glassBlur,
            sigmaY: AppConstants.glassBlur,
          ),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ??
                  AppColors.glassWhite.withOpacity(AppConstants.glassOpacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
