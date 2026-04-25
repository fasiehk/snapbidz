import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';


import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final userName = user?.name ?? 'Alexandra Vance';
    final userInitials = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'A';
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLG),
          child: Column(
            children: [
              // ── Avatar + name ──────────────────────────────────────────────
              const SizedBox(height: AppConstants.spaceMD),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Center(
                      child: Text(userInitials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.onPrimary)),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: AppColors.onPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceMD),
              Text(userName, style: AppTextStyles.headlineSmall),
              const SizedBox(height: 4),
              Text('Premium Collector • Member since 2021', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Stats ──────────────────────────────────────────────────────
              GlassCard(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ProfileStat(value: '47', label: 'Bids Won'),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _ProfileStat(value: '12', label: 'Listed'),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _ProfileStat(value: '4.9★', label: 'Rating'),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _ProfileStat(value: '\$2.1M', label: 'Volume'),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Post an Item CTA ───────────────────────────────────────────
              _SellerCtaCard(onPostItem: () => context.push('/create-listing')),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Seller Reputation ──────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Seller Reputation', style: AppTextStyles.titleMedium),
              ),
              const SizedBox(height: AppConstants.spaceSM),
              GlassCard(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: Column(
                  children: [
                    _ReputationBar(label: 'Communication', percent: 0.98),
                    const SizedBox(height: AppConstants.spaceSM),
                    _ReputationBar(label: 'Item Accuracy', percent: 0.96),
                    const SizedBox(height: AppConstants.spaceSM),
                    _ReputationBar(label: 'Shipping Speed', percent: 0.94),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceLG),

              // ── Account Settings ───────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Account Settings', style: AppTextStyles.titleMedium),
              ),
              const SizedBox(height: AppConstants.spaceSM),
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsTile(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () {}),
                    _SettingsDivider(),
                    _SettingsTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                    _SettingsDivider(),
                    _SettingsTile(icon: Icons.credit_card_outlined, label: 'Payment Methods', onTap: () {}),
                    _SettingsDivider(),
                    _SettingsTile(icon: Icons.gavel_rounded, label: 'My Bids & Listings', onTap: () => context.push('/my-bids')),
                    _SettingsDivider(),
                    _SettingsTile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                    _SettingsDivider(),
                    _SettingsTile(
                      icon: Icons.logout_rounded, 
                      label: 'Sign Out', 
                      isDestructive: true,
                      onTap: () async {
                        await ref.read(authControllerProvider.notifier).logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spaceXL),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Seller CTA Card ───────────────────────────────────────────────────────────

class _SellerCtaCard extends StatelessWidget {
  final VoidCallback onPostItem;
  const _SellerCtaCard({required this.onPostItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A00E0).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header row ────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Start Selling Today',
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                      ),
                      Text(
                        'List your items & let the bidding begin',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha(200)),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Feature pills ─────────────────────────────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FeaturePill(icon: Icons.visibility_rounded, label: 'Visible to all users'),
                _FeaturePill(icon: Icons.gavel_rounded, label: 'Live bidding'),
                _FeaturePill(icon: Icons.timer_outlined, label: 'Custom duration'),
              ],
            ),

            const SizedBox(height: AppConstants.spaceLG),

            // ── Action button ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPostItem,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('Post an Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A00E0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: AppTextStyles.labelLarge,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 5),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
      ],
    );
  }
}

class _ReputationBar extends StatelessWidget {
  final String label;
  final double percent;
  const _ReputationBar({required this.label, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 120, child: Text(label, style: AppTextStyles.bodySmall)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.primaryFixed,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text('${(percent * 100).toInt()}%', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _SettingsTile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLG),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: AppConstants.spaceMD),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color))),
            Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, indent: AppConstants.spaceLG + 20, color: AppColors.outlineVariant.withAlpha(60));
  }
}
