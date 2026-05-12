import 'package:flutter/material.dart';
import '../constants/app_breakpoints.dart';

/// A responsive grid that automatically adjusts its column count
/// based on the current screen size.
///
/// Mobile  → 2 columns
/// Desktop → 4 columns (or custom via [desktopColumns])
///
/// Usage:
/// ```dart
/// ResponsiveGrid(
///   children: auctions.map((a) => AuctionCard(a)).toList(),
/// )
/// ```
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.desktopColumns,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio = 0.72,
  });

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.isDesktop(context)
        ? (desktopColumns ?? AppBreakpoints.desktopColumns)
        : (mobileColumns ?? AppBreakpoints.mobileColumns);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (_, i) => children[i],
    );
  }
}

/// Sliver version of [ResponsiveGrid] for use inside [CustomScrollView].
class SliverResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileColumns;
  final int? desktopColumns;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const SliverResponsiveGrid({
    super.key,
    required this.children,
    this.mobileColumns,
    this.desktopColumns,
    this.spacing = 12,
    this.runSpacing = 12,
    this.childAspectRatio = 0.72,
  });

  @override
  Widget build(BuildContext context) {
    final columns = AppBreakpoints.isDesktop(context)
        ? (desktopColumns ?? AppBreakpoints.desktopColumns)
        : (mobileColumns ?? AppBreakpoints.mobileColumns);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing,
        childAspectRatio: childAspectRatio,
      ),
      delegate: SliverChildBuilderDelegate(
        (_, i) => children[i],
        childCount: children.length,
      ),
    );
  }
}
