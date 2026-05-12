// profile_mobile.dart
// The entire original ProfileScreen content, verbatim.
// This file is the mobile layout — no logic changes.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/gradient_background.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auctions/controllers/auction_controller.dart';
import '../../seller_verification/controllers/seller_verification_controller.dart';

class ProfileMobile extends ConsumerStatefulWidget {
  const ProfileMobile({super.key});

  @override
  ConsumerState<ProfileMobile> createState() => _ProfileMobileState();
}

class _ProfileMobileState extends ConsumerState<ProfileMobile> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;
    final userName = user?.name ?? 'Alexandra Vance';
    final userInitials = userName.isNotEmpty ? userName.substring(0, 1).toUpperCase() : 'A';

    String memberSince = 'Member since 2021';
    if (user != null && user.registration.isNotEmpty) {
      try {
        final date = DateTime.parse(user.registration);
        memberSince = 'Member since ${DateFormat.yMMMM().format(date)}';
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceLG),
            child: Column(
              children: [
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
                      bottom: 0, right: 0,
                      child: Container(
                        width: 26, height: 26,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      user?.emailVerification == true ? Icons.verified_user_rounded : Icons.warning_amber_rounded,
                      size: 14,
                      color: user?.emailVerification == true ? AppColors.secondary : AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user?.emailVerification == true ? 'Email Verified' : 'Email Not Verified',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: user?.emailVerification == true ? AppColors.secondary : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(memberSince, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppConstants.spaceLG),

                // Email verification banner
                if (user != null && !user.emailVerification) ...[
                  GlassCard(
                    backgroundColor: AppColors.error.withOpacity(0.05),
                    padding: const EdgeInsets.all(AppConstants.spaceMD),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.mail_lock_rounded, color: AppColors.error),
                            const SizedBox(width: AppConstants.spaceMD),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Verify your email', style: AppTextStyles.titleSmall),
                                  Text(
                                    'You must verify your email to bid or post items.',
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spaceMD),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showManualVerifyDialog(context, ref),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.error),
                                  foregroundColor: AppColors.error,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                                ),
                                child: const Text('Enter Code'),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceSM),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await ref.read(authControllerProvider.notifier).sendEmailVerification();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Verification email sent!')),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                                ),
                                child: const Text('Send Email'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLG),
                ],

                // Stats
                user == null
                    ? const SizedBox()
                    : ref.watch(profileStatsProvider(user.$id)).when(
                        loading: () => GlassCard(
                          padding: const EdgeInsets.all(AppConstants.spaceMD),
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        ),
                        error: (err, _) => const SizedBox(),
                        data: (stats) {
                          final listedCount = int.tryParse(stats['listed']!) ?? 0;
                          return Column(
                            children: [
                              GlassCard(
                                padding: const EdgeInsets.all(AppConstants.spaceMD),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _ProfileStat(value: stats['bids']!, label: 'Active Bids'),
                                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                                    _ProfileStat(value: stats['listed']!, label: 'Listed'),
                                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                                    _ProfileStat(value: stats['volume']!, label: 'Volume'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: AppConstants.spaceLG),
                              _SellerCtaCard(
                                hasListings: listedCount > 0,
                                onPostItem: () async {
                                  if (user == null) return;
                                  if (!user.emailVerification) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Please verify your email first.'), backgroundColor: AppColors.error),
                                    );
                                    return;
                                  }
                                  final isComplete = await ref.read(sellerProfileProvider.notifier).isProfileComplete(user.$id);
                                  if (!context.mounted) return;
                                  if (isComplete) context.push('/create'); else context.push('/seller-verify');
                                },
                              ),
                            ],
                          );
                        },
                      ),

                // Admin
                if (ref.watch(authControllerProvider.notifier).isAdmin) ...[
                  const SizedBox(height: AppConstants.spaceLG),
                  GlassCard(
                    onTap: () => context.push('/admin'),
                    backgroundColor: AppColors.primary.withOpacity(0.05),
                    child: ListTile(
                      leading: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
                      title: Text('Admin Panel', style: AppTextStyles.titleSmall),
                      subtitle: Text('Manage users and platform listings', style: AppTextStyles.bodySmall),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                ],

                const SizedBox(height: AppConstants.spaceMD),

                // Settings
                Align(alignment: Alignment.centerLeft, child: Text('Account Settings', style: AppTextStyles.titleMedium)),
                const SizedBox(height: AppConstants.spaceSM),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _SettingsTile(icon: Icons.person_outline_rounded, label: 'Edit Profile', onTap: () => context.push('/edit-profile')),
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
      ),
    );
  }

  void _showManualVerifyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.9),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
        title: Text('Enter Verification Code', style: AppTextStyles.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copy the "secret" parameter from the verification link sent to your email.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppConstants.spaceLG),
            AppTextField(label: 'Secret Code', hint: 'Paste secret here...', controller: controller),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant))),
          ElevatedButton(
            onPressed: () async {
              final secret = controller.text.trim();
              if (secret.isEmpty) return;
              final user = ref.read(authControllerProvider).value;
              if (user == null) return;
              try {
                showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
                await ref.read(authControllerProvider.notifier).verifyEmail(userId: user.$id, secret: secret);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email verified!')));
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD))),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}

// ── Shared profile sub-widgets ─────────────────────────────────────────────────

class _SellerCtaCard extends StatelessWidget {
  final VoidCallback onPostItem;
  final bool hasListings;
  const _SellerCtaCard({required this.onPostItem, this.hasListings = false});

  @override
  Widget build(BuildContext context) {
    final title = hasListings ? 'Create a New Listing' : 'Start Selling Today';
    final subtitle = hasListings ? 'Ready to post another item?' : 'List your items & let the bidding begin';
    final gradient = hasListings
        ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : const LinearGradient(colors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)], begin: Alignment.topLeft, end: Alignment.bottomRight);

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: (hasListings ? AppColors.primary : const Color(0xFF4A00E0)).withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: EdgeInsets.all(hasListings ? AppConstants.spaceMD : AppConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: hasListings ? 36 : 44, height: hasListings ? 36 : 44,
                  decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                  child: Icon(hasListings ? Icons.add_rounded : Icons.storefront_rounded, color: Colors.white, size: hasListings ? 20 : 24),
                ),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: (hasListings ? AppTextStyles.titleSmall : AppTextStyles.titleMedium).copyWith(color: Colors.white)),
                      Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withAlpha(200))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceLG),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
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
