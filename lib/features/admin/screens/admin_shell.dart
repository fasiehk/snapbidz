import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/gradient_background.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Row(
          children: [
            if (!isMobile)
              _buildSidebar(context, location),
            Expanded(
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: child),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: isMobile ? Drawer(child: _buildSidebar(context, location)) : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width < 800)
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          Text('SnapBid Admin', style: AppTextStyles.titleLarge),
          const Spacer(),
          TextButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.exit_to_app_rounded),
            label: const Text('Exit to App'),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, String location) {
    return Container(
      width: 260,
      color: Colors.white.withOpacity(0.9),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _SidebarItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: location == '/admin',
            onTap: () => context.go('/admin'),
          ),
          _SidebarItem(
            icon: Icons.people_alt_rounded,
            label: 'Users',
            isSelected: location == '/admin/users',
            onTap: () => context.go('/admin/users'),
          ),
          _SidebarItem(
            icon: Icons.gavel_rounded,
            label: 'Auctions',
            isSelected: location == '/admin/auctions',
            onTap: () => context.go('/admin/auctions'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('v1.0.0 Stable', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: onTap,
    );
  }
}
