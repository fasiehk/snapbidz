import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Full-screen radial gradient background used on every screen.
/// Transitions from soft pink → soft purple → soft blue.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.3, -0.5),
          radius: 1.4,
          colors: [
            AppColors.gradientStart,   // soft pink
            AppColors.gradientMid,     // soft purple
            AppColors.gradientEnd,     // soft blue
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: child,
    );
  }
}
