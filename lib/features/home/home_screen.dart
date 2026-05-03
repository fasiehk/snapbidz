import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';
import '../auctions/controllers/auction_controller.dart';
import '../auctions/models/auction_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLG, AppConstants.spaceMD,
                  AppConstants.spaceLG, 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primary],
                        ),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                      ),
                      child: const Icon(Icons.gavel_rounded, color: AppColors.onPrimary, size: 20),
                    ),
                    const SizedBox(width: AppConstants.spaceSM),
                    Text('SnapBid', style: AppTextStyles.titleLarge),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_outlined),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withAlpha(180),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLG, AppConstants.spaceLG,
                  AppConstants.spaceLG, AppConstants.spaceSM,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Discover Rarity', style: AppTextStyles.headlineLarge),
                    const SizedBox(height: 4),
                    Text(
                      'Find extraordinary pieces from global collectors.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search Bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                child: GestureDetector(
                  onTap: () => context.go('/browse'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(200),
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                      border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppColors.outline, size: 20),
                        const SizedBox(width: 10),
                        Text('Search auctions…', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Categories ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceLG, AppConstants.spaceLG,
                      AppConstants.spaceLG, AppConstants.spaceSM,
                    ),
                    child: _SectionHeader(title: 'Categories', onSeeAll: () => context.go('/browse')),
                  ),
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                      itemCount: AppDummyData.categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = AppDummyData.categories[i];
                        final isActive = i == 0;
                        return _CategoryChip(
                          label: cat['label']!,
                          emoji: cat['emoji']!,
                          isActive: isActive,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // ── Trending Now ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceLG, AppConstants.spaceLG,
                      AppConstants.spaceLG, AppConstants.spaceSM,
                    ),
                    child: _SectionHeader(title: 'Trending Now 🔥', onSeeAll: () => context.go('/browse')),
                  ),
                  SizedBox(
                    height: 260,
                    child: ref.watch(trendingAuctionsProvider).when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                      error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
                      data: (trending) => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                        itemCount: trending.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final item = trending[i];
                          return _TrendingCard(auction: item, onTap: () => context.push('/auction/${item.id}'));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Recently Listed ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLG, AppConstants.spaceLG,
                  AppConstants.spaceLG, AppConstants.spaceSM,
                ),
                child: _SectionHeader(title: 'Recently Listed', onSeeAll: () => context.go('/browse')),
              ),
            ),
            SliverToBoxAdapter(
              child: ref.watch(recentAuctionsProvider).when(
                loading: () => const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
                error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
                data: (recent) => ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: recent.length,
                  itemBuilder: (context, i) {
                    final item = recent[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spaceLG,
                        vertical: 6,
                      ),
                      child: _RecentListingCard(auction: item, onTap: () => context.push('/auction/${item.id}')),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.spaceXL)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        icon: const Icon(Icons.add_rounded),
        label: Text('List Item', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary)),
        elevation: 4,
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const Spacer(),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  const _CategoryChip({required this.label, required this.emoji, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
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
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: isActive ? AppColors.onPrimary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  const _TrendingCard({required this.auction, required this.onTap});

  String _formatCurrency(int value) {
    if (value >= 1000) return 'PKR ${(value / 1000).toStringAsFixed(1)}k';
    return 'PKR $value';
  }

  Color get _timerColor {
    final diff = auction.endTime.difference(DateTime.now());
    if (diff.inHours < 1) return AppColors.timerCoral;
    if (diff.inHours <= 24) return AppColors.timerAmber;
    return AppColors.timerGreen;
  }
  
  String get _timeLeft {
    final diff = auction.endTime.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        width: 200,
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                image: auction.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(auction.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: auction.imageUrl == null
                  ? Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 52)))
                  : null,
            ),
            const SizedBox(height: AppConstants.spaceSM),
            // Category chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              ),
              child: Text(auction.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
            ),
            const SizedBox(height: 4),
            Text(auction.title, style: AppTextStyles.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
            const Spacer(),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Bid', style: AppTextStyles.labelSmall),
                    Text(_formatCurrency(auction.currentBid), style: AppTextStyles.priceSmall),
                  ],
                ),
                  Container(
                    width: 90,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _timerColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.timer_outlined, size: 12, color: _timerColor),
                            const SizedBox(width: 3),
                            Text(_timeLeft, style: AppTextStyles.labelSmall.copyWith(color: _timerColor)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 2),
                          builder: (context, val, _) => LinearProgressIndicator(
                            value: val * 0.7, // Simulated active progress
                            backgroundColor: _timerColor.withAlpha(50),
                            valueColor: AlwaysStoppedAnimation<Color>(_timerColor),
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentListingCard extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  const _RecentListingCard({required this.auction, required this.onTap});

  String _formatCurrency(int value) {
    if (value >= 1000) return 'PKR ${(value / 1000).toStringAsFixed(1)}k';
    return 'PKR $value';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primaryFixed,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              image: auction.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(auction.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: auction.imageUrl == null
                ? Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 30)))
                : null,
          ),
          const SizedBox(width: AppConstants.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auction.title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(auction.subtitle, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('Live Now', style: AppTextStyles.labelSmall.copyWith(color: AppColors.timerGreen)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 2),
                        builder: (context, val, _) => LinearProgressIndicator(
                          value: val * 0.6, // Simulated active progress
                          backgroundColor: AppColors.timerGreen.withAlpha(50),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.timerGreen),
                          minHeight: 3,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spaceSM),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(_formatCurrency(auction.currentBid), style: AppTextStyles.priceSmall),
              Text('${auction.totalBids} bids', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
