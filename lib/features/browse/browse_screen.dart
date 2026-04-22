import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});
  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  int _selectedCategory = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceLG, AppConstants.spaceMD,
                AppConstants.spaceLG, 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Browse', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    '240+ active auctions',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppConstants.spaceMD),
                  // Search bar
                  TextField(
                    controller: _searchController,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search auctions, items, sellers…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
                      filled: true,
                      fillColor: Colors.white.withAlpha(200),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withAlpha(80)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withAlpha(80)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Category Filter ──────────────────────────────────────────────
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                itemCount: AppDummyData.categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final cat = AppDummyData.categories[i];
                  final isActive = _selectedCategory == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = i),
                    child: AnimatedContainer(
                      duration: AppConstants.animFast,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        border: Border.all(
                          color: isActive ? AppColors.primary : AppColors.outlineVariant.withAlpha(80),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(cat['emoji']!, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 5),
                          Text(
                            cat['label']!,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: isActive ? AppColors.onPrimary : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Grid ─────────────────────────────────────────────────────────
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: AppDummyData.browseItems.length,
                itemBuilder: (context, i) {
                  final item = AppDummyData.browseItems[i];
                  return _BrowseCard(auction: item, onTap: () => context.push('/auction/${item.id}'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrowseCard extends StatelessWidget {
  final DummyAuction auction;
  final VoidCallback onTap;
  const _BrowseCard({required this.auction, required this.onTap});

  Color get _timerColor {
    if (auction.timeLeft.contains('h') && !auction.timeLeft.contains('d')) {
      final h = int.tryParse(auction.timeLeft.split('h')[0]) ?? 99;
      if (h <= 2) return AppColors.timerCoral;
      return AppColors.timerAmber;
    }
    return AppColors.timerGreen;
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spaceSM + 4),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            ),
            child: Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 48))),
          ),
          const SizedBox(height: AppConstants.spaceSM),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Text(auction.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
          ),
          const SizedBox(height: 4),
          Text(auction.title, style: AppTextStyles.titleSmall.copyWith(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('Current Bid', style: AppTextStyles.labelSmall),
          Text(auction.currentBid, style: AppTextStyles.priceSmall),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: _timerColor.withAlpha(25),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined, size: 11, color: _timerColor),
                const SizedBox(width: 3),
                Text(auction.timeLeft, style: AppTextStyles.labelSmall.copyWith(color: _timerColor, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
