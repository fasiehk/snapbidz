import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_background.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/controllers/auth_controller.dart';

/// Screen 1 — Splash Screen
/// Stitch reference: "LuxAuction Splash Screen"
/// Shows animated logo + tagline, then navigates to Onboarding or Home based on auth.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _subtitleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    // Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );

    // App name animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    // Subtitle animation
    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController, curve: Curves.easeIn),
    );

    _startAnimationSequence();
  }

  Future<void> _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    await _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    await _textController.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    await _subtitleController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Wait for the auth controller to finish initializing its session check
    final authState = ref.read(authControllerProvider);
    
    if (mounted) {
      if (authState.value != null) {
        // User is logged in
        context.go('/home');
      } else {
        // User is not logged in
        context.go('/onboarding');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Logo Icon ─────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.gavel_rounded,
                      color: AppColors.onPrimary,
                      size: 50,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── App Name ──────────────────────────────────────────────────
              AnimatedBuilder(
                animation: _textController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  AppConstants.appName,
                  style: AppTextStyles.displayLarge.copyWith(
                    foreground: Paint()
                      ..shader = const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                      ).createShader(
                        const Rect.fromLTWH(0, 0, 200, 60),
                      ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spaceSM),

              // ── Tagline ───────────────────────────────────────────────────
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Text(
                  AppConstants.appTagline,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spaceSM),

              // ── Sub tagline ───────────────────────────────────────────────
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMD,
                    vertical: AppConstants.spaceXS + 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    AppConstants.appSubtitle,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // ── Loading indicator ─────────────────────────────────────────
              FadeTransition(
                opacity: _subtitleOpacity,
                child: Column(
                  children: [
                    SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.primaryFixed,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMD),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),
            ],
          ),
        ),
      ),
    );
  }
}
