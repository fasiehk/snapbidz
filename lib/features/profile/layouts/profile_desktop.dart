import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_breakpoints.dart';

import '../../../core/widgets/hover_card.dart';
import '../../../core/responsive/adaptive_padding.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auctions/controllers/auction_controller.dart';
import '../../seller_verification/controllers/seller_verification_controller.dart';

/// Desktop profile — two-column layout:
///   Left  (profile card + stats + settings list)
///   Right (seller CTA + listings grid)
class ProfileDesktop extends ConsumerWidget {
  const ProfileDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState  = ref.watch(authControllerProvider);
    final user       = authState.value;
    final userName   = user?.name ?? 'SnapBid User';
    final initials   = userName.isNotEmpty ? userName[0].toUpperCase() : 'S';

    String memberSince = 'Member since 2021';
    if (user != null && user.registration.isNotEmpty) {
      try { memberSince = 'Member since ${DateFormat.yMMMM().format(DateTime.parse(user.registration))}'; } catch (_) {}
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        child: DesktopContentBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppBreakpoints.desktopPadding,
              vertical: 40,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Left column: profile card + settings ────────────────
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      // Profile card
                      _ProfileCard(
                        userName: userName,
                        initials: initials,
                        memberSince: memberSince,
                        isVerified: user?.emailVerification ?? false,
                      ),
                      const SizedBox(height: 20),

                      // Stats
                      if (user != null)
                        ref.watch(profileStatsProvider(user.$id)).when(
                          loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))),
                          error: (_, __) => const SizedBox(),
                          data: (stats) => _StatsCard(stats: stats),
                        ),
                      const SizedBox(height: 20),

                      // Settings
                      _SettingsCard(ref: ref),
                    ],
                  ),
                ),

                const SizedBox(width: 28),

                // ── Right column: CTAs + listings ───────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email banner
                      if (user != null && !user.emailVerification)
                        _EmailVerifyBanner(ref: ref, user: user),

                      // Seller CTA
                      _DesktopSellerCta(
                        onPostItem: () async {
                          if (user == null) return;
                          if (!user.emailVerification) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please verify your email first.'), backgroundColor: AppColors.error),
                            );
                            return;
                          }
                          final ok = await ref.read(sellerProfileProvider.notifier).isProfileComplete(user.$id);
                          if (!context.mounted) return;
                          if (ok) context.push('/create'); else context.push('/seller-verify');
                        },
                      ),
                      const SizedBox(height: 20),

                      // Admin panel card
                      if (ref.watch(authControllerProvider.notifier).isAdmin) ...[
                        _AdminCard(),
                        const SizedBox(height: 20),
                      ],

                      // My listings
                      if (user != null) _MyListingsSection(ref: ref, userId: user.$id),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────────────────

class _ProfileCard extends StatelessWidget {
  final String userName;
  final String initials;
  final String memberSince;
  final bool isVerified;
  const _ProfileCard({required this.userName, required this.initials, required this.memberSince, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Center(child: Text(initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white))),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(userName, style: AppTextStyles.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isVerified ? Icons.verified_user_rounded : Icons.warning_amber_rounded, size: 13, color: isVerified ? AppColors.secondary : AppColors.error),
              const SizedBox(width: 4),
              Text(isVerified ? 'Email Verified' : 'Email Not Verified',
                  style: AppTextStyles.bodySmall.copyWith(color: isVerified ? AppColors.secondary : AppColors.error, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          Text(memberSince, style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/edit-profile'),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text('Edit Profile'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withOpacity(0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats card ────────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  final Map<String, String> stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(value: stats['bids'] ?? '0', label: 'Active Bids'),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _StatItem(value: stats['listed'] ?? '0', label: 'Listed'),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _StatItem(value: stats['volume'] ?? '0', label: 'Volume'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

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

// ── Settings card ─────────────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final WidgetRef ref;
  const _SettingsCard({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('Settings', style: AppTextStyles.titleSmall),
          ),
          const Divider(height: 1),
          _Tile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
          _Tile(icon: Icons.credit_card_outlined, label: 'Payment Methods', onTap: () {}),
          _Tile(icon: Icons.gavel_rounded, label: 'My Bids & Listings', onTap: () => context.push('/my-bids')),
          _Tile(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
          const Divider(height: 1),
          _Tile(
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
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _Tile({required this.icon, required this.label, required this.onTap, this.isDestructive = false});

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.onSurface;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: color, fontSize: 14))),
            Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

// ── Email verify banner ───────────────────────────────────────────────────────

class _EmailVerifyBanner extends StatelessWidget {
  final WidgetRef ref;
  final dynamic user;
  const _EmailVerifyBanner({required this.ref, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.06),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.mail_lock_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(child: Text('Verify your email to bid or post items.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error))),
          TextButton(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).sendEmailVerification();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Verification email sent!')));
            },
            child: const Text('Send Email'),
          ),
        ],
      ),
    );
  }
}

// ── Seller CTA ────────────────────────────────────────────────────────────────

class _DesktopSellerCta extends StatelessWidget {
  final VoidCallback onPostItem;
  const _DesktopSellerCta({required this.onPostItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          const Icon(Icons.storefront_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Start Selling Today', style: AppTextStyles.titleMedium.copyWith(color: Colors.white)),
                Text('List your items and let the bidding begin', style: AppTextStyles.bodySmall.copyWith(color: Colors.white70)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onPostItem,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Post Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Admin card ────────────────────────────────────────────────────────────────

class _AdminCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: () => context.push('/admin'),
      backgroundColor: AppColors.primary.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Panel', style: AppTextStyles.titleSmall),
                  Text('Manage users and platform listings', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}

// ── My Listings section ───────────────────────────────────────────────────────

class _MyListingsSection extends StatelessWidget {
  final WidgetRef ref;
  final String userId;
  const _MyListingsSection({required this.ref, required this.userId});

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('My Listings', style: AppTextStyles.titleLarge),
            const Spacer(),
            TextButton(
              onPressed: () => context.push('/my-bids'),
              child: Text('View All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ref.watch(myListingsProvider(userId)).when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Text('Error: $e'),
          data: (auctions) {
            if (auctions.isEmpty) {
              return Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                ),
                child: const Center(child: Text('No listings yet.')),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemCount: auctions.length > 4 ? 4 : auctions.length,
              itemBuilder: (ctx, i) {
                final a = auctions[i];
                return HoverCard(
                  onTap: () => context.push('/auction/${a.id}'),
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                            image: a.imageUrl != null
                                ? DecorationImage(image: NetworkImage(a.imageUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: a.imageUrl == null ? Center(child: Text(a.imageEmoji, style: const TextStyle(fontSize: 38))) : null,
                        ),
                        const SizedBox(height: 8),
                        Text(a.title, style: AppTextStyles.titleSmall.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const Spacer(),
                        Text(_fmt(a.currentBid), style: AppTextStyles.priceSmall),
                        Text('${a.totalBids} bids', style: AppTextStyles.labelSmall),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
