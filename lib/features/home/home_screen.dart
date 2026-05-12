import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_layout.dart';
import 'layouts/home_mobile.dart';
import 'layouts/home_desktop.dart';

/// Thin router — detects screen size and delegates to the correct layout.
/// All providers/controllers remain untouched.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile:  (_) => const HomeMobile(),
      desktop: (_) => const HomeDesktop(),
    );
  }
}
