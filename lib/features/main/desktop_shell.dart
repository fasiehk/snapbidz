import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/hover_card.dart';
import '../auth/controllers/auth_controller.dart';
import '../messages/controllers/chat_controller.dart';

/// Desktop sidebar navigation shell.
///
/// Rendered by [MainShell] when [AppBreakpoints.isDesktop] is true.
/// Provides a 240 px fixed-width sidebar with:
///   • SnapBid logo & branding
///   • Nav items with hover + active states
///   • Unread message badge
///   • "Post Auction" CTA
///   • User avatar + sign-out at the bottom
class DesktopShell extends ConsumerWidget {
  final Widget child;
  const DesktopShell({super.key, required this.child});

  static const _navItems = [
    _NavDef(icon: Icons.home_rounded,            label: 'Home',      path: '/home'),
    _NavDef(icon: Icons.search_rounded,          label: 'Browse',    path: '/browse'),
    _NavDef(icon: Icons.favorite_rounded,        label: 'Watchlist', path: '/watchlist'),
    _NavDef(icon: Icons.chat_bubble_rounded,     label: 'Messages',  path: '/messages'),
    _NavDef(icon: Icons.person_rounded,          label: 'Profile',   path: '/profile'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final unread   = ref.watch(unreadCountProvider);
    final user     = ref.watch(authControllerProvider).value;
    final userName = user?.name ?? 'SnapBid User';
    final initials = userName.isNotEmpty ? userName[0].toUpperCase() : 'S';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────────
          _Sidebar(
            location:  location,
            unread:    unread,
            userName:  userName,
            initials:  initials,
            isAdmin:   ref.read(authControllerProvider.notifier).isAdmin,
            onSignOut: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),

          // ── Content area ───────────────────────────────────────────────────
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── Sidebar widget ─────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String   location;
  final int      unread;
  final String   userName;
  final String   initials;
  final bool     isAdmin;
  final VoidCallback onSignOut;

  const _Sidebar({
    required this.location,
    required this.unread,
    required this.userName,
    required this.initials,
    required this.isAdmin,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppBreakpoints.sidebarWidth,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F35), Color(0xFF0F1628)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // ── Logo ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Text(
                  'SnapBid',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Platform label ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(
                'Live Auction Platform',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary.withOpacity(0.9),
                  fontSize: 10,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
          _sectionLabel('NAVIGATION'),
          const SizedBox(height: 6),

          // ── Nav items ────────────────────────────────────────────────────
          ...DesktopShell._navItems.map((nav) {
            final isSelected = location.startsWith(nav.path);
            final isMsgs     = nav.path == '/messages';
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: HoverNavItem(
                isSelected: isSelected,
                onTap: () => context.go(nav.path),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        nav.icon,
                        size: 20,
                        color: isSelected ? AppColors.primary : Colors.white60,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          nav.label,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isMsgs && unread > 0)
                        Container(
                          constraints: const BoxConstraints(minWidth: 20),
                          height: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Center(
                            child: Text(
                              unread > 99 ? '99+' : '$unread',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // ── Admin link ───────────────────────────────────────────────────
          if (isAdmin) ...[
            const SizedBox(height: 4),
            _sectionLabel('ADMIN'),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: HoverNavItem(
                isSelected: location.startsWith('/admin'),
                onTap: () => context.go('/admin'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 20,
                        color: location.startsWith('/admin')
                            ? AppColors.primary
                            : Colors.white60,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Admin Panel',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: location.startsWith('/admin')
                              ? Colors.white
                              : Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          const Spacer(),

          // ── Post Auction CTA ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HoverNavItem(
              onTap: () => context.push('/create'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Post Auction',
                      style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── User footer ──────────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Bidder',
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onSignOut,
                  tooltip: 'Sign Out',
                  icon: const Icon(Icons.logout_rounded, size: 16, color: Colors.white54),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.35),
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── Navigation definition ──────────────────────────────────────────────────────

class _NavDef {
  final IconData icon;
  final String   label;
  final String   path;
  const _NavDef({required this.icon, required this.label, required this.path});
}
