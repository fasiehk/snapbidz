import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_layout.dart';
import 'layouts/browse_mobile.dart';
import 'layouts/browse_desktop.dart';

/// Thin router for Browse — delegates to mobile or desktop layout.
class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile:  (_) => const BrowseMobile(),
      desktop: (_) => const BrowseDesktop(),
    );
  }
}
