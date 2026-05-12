import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/responsive/responsive_layout.dart';
import 'layouts/profile_mobile.dart';
import 'layouts/profile_desktop.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile:  (_) => const ProfileMobile(),
      desktop: (_) => const ProfileDesktop(),
    );
  }
}
