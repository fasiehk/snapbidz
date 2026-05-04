import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardContent extends ConsumerWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dashboard Overview', style: AppTextStyles.headlineSmall),
          const SizedBox(height: AppConstants.spaceXL),
          
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error loading stats: $e')),
            data: (stats) => Row(
              children: [
                Expanded(child: _buildStatCard('Total Users', '${stats['totalUsers']}', Icons.people, Colors.blue)),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(child: _buildStatCard('Active Auctions', '${stats['activeAuctions']}', Icons.gavel, Colors.orange)),
                const SizedBox(width: AppConstants.spaceMD),
                Expanded(child: _buildStatCard('Total Bids', '${stats['totalBids']}', Icons.trending_up, Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppConstants.spaceMD),
          Text(value, style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
