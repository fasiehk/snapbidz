import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/glass_card.dart';

/// Screen 2 — Onboarding Screen
/// 3-slide carousel with glassmorphism cards, dot indicators, and CTA.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.search_rounded,
      iconColor: AppColors.primary,
      title: 'Discover Rarity',
      subtitle: 'Find extraordinary pieces from global collectors. From vintage timepieces to rare art — all in one place.',
      gradient: [AppColors.primaryFixed, AppColors.primaryFixedDim],
    ),
    _OnboardingData(
      icon: Icons.gavel_rounded,
      iconColor: AppColors.secondary,
      title: 'Bid with Confidence',
      subtitle: 'Real-time live bidding with instant notifications. Never miss a winning moment again.',
      gradient: [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
    ),
    _OnboardingData(
      icon: Icons.emoji_events_rounded,
      iconColor: AppColors.accent,
      title: 'Win & Celebrate',
      subtitle: 'Secure payments, verified sellers, and worldwide shipping. Your next treasure awaits.',
      gradient: [Color(0xFFFFE4E4), Color(0xFFFFCCCC)],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
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
              // ── Skip Button ───────────────────────────────────────────────
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Skip',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              // ── Page View ─────────────────────────────────────────────────
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // ── Dot Indicators ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: AppConstants.animFast,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? AppColors.primary
                          : AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppConstants.spaceXL),

              // ── CTA Button ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                child: PrimaryButton(
                  label: _currentPage == _pages.length - 1
                      ? 'Get Started'
                      : 'Continue',
                  icon: _currentPage == _pages.length - 1
                      ? Icons.arrow_forward_rounded
                      : null,
                  onPressed: _nextPage,
                ),
              ),

              const SizedBox(height: AppConstants.spaceMD),

              // ── Login link ────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodySmall,
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spaceLG),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual onboarding slide
class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Icon Card ──────────────────────────────────────────────────
          GlassCard(
            padding: const EdgeInsets.all(AppConstants.spaceXXL),
            child: Column(
              children: [
                // Icon circle
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: data.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: data.iconColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, size: 48, color: data.iconColor),
                ),

                const SizedBox(height: AppConstants.spaceXL),

                // Title
                Text(
                  data.title,
                  style: AppTextStyles.headlineMedium,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.spaceMD),

                // Subtitle
                Text(
                  data.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
