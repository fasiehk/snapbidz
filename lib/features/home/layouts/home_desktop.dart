import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/data/category_data.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/hover_card.dart';
import '../../../core/responsive/adaptive_padding.dart';
import '../../auctions/controllers/auction_controller.dart';
import '../../auctions/models/auction_model.dart';

/// Desktop/web home screen.
///
/// Layout:
///   ┌──────────────────────────────────────────────────────────┐
///   │  Header bar (logo hidden — sidebar handles it)           │
///   │  Hero gradient banner  + quick-stat cards                │
///   │  Category chips row                                      │
///   │  Two-column section:                                     │
///   │    Left (2/3)  → Trending Now  (horizontal scroll)       │
///   │    Right (1/3) → Live Stats panel                        │
///   │  4-column "Recently Listed" grid                         │
///   └──────────────────────────────────────────────────────────┘
class HomeDesktop extends ConsumerWidget {
  const HomeDesktop({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        child: DesktopContentBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppBreakpoints.desktopPadding,
              vertical: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Page header ───────────────────────────────────────────
                _PageHeader(),
                const SizedBox(height: 28),

                // ── Hero banner ───────────────────────────────────────────
                _HeroBanner(),
                const SizedBox(height: 28),

                // ── Stat chips ────────────────────────────────────────────
                _StatRow(ref: ref),
                const SizedBox(height: 28),

                // ── Category filter ───────────────────────────────────────
                _DesktopCategoryRow(),
                const SizedBox(height: 28),

                // ── Two-column section: Trending + Live Stats ─────────────
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: _TrendingSection(ref: ref),
                      ),
                      const SizedBox(width: 24),
                      SizedBox(
                        width: 280,
                        child: _LiveStatsPanel(ref: ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── Recently Listed grid ──────────────────────────────────
                _RecentSection(ref: ref),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Page header ───────────────────────────────────────────────────────────────

class _PageHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discover Rarity', style: AppTextStyles.headlineLarge.copyWith(fontSize: 28)),
            Text(
              'Find extraordinary pieces from global collectors.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const Spacer(),
        // Search bar
        Container(
          width: 320,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)],
          ),
          child: GestureDetector(
            onTap: () => Navigator.of(context, rootNavigator: true)
                .pushNamed('/browse'),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, color: AppColors.outline, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Search auctions…',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
          ),
        ),
      ],
    );
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F35), AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Positioned(
            right: 60,
            bottom: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
                      child: Text(
                        '🔥 Live Auctions',
                        style: AppTextStyles.labelSmall.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bid. Win. Own.',
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exclusive items from verified sellers across Pakistan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => context.go('/browse'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Browse All Auctions',
                              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.gavel_rounded, size: 100, color: Colors.white12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat Row ──────────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final WidgetRef ref;
  const _StatRow({required this.ref});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('240+', 'Live Auctions', Icons.gavel_rounded, AppColors.primary),
      ('1.2k', 'Active Bidders', Icons.people_rounded, AppColors.secondary),
      ('PKR 4M+', 'Volume Today', Icons.trending_up_rounded, AppColors.timerGreen),
      ('98%', 'Satisfaction', Icons.star_rounded, AppColors.timerAmber),
    ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: s == stats.last ? 0 : 16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusLG),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: s.$4.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    ),
                    child: Icon(s.$3, color: s.$4, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.$1, style: AppTextStyles.titleMedium.copyWith(color: AppColors.onSurface)),
                      Text(s.$2, style: AppTextStyles.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Desktop category row ──────────────────────────────────────────────────────

class _DesktopCategoryRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: CategoryData.categories.map((cat) {
        return GestureDetector(
          onTap: () => context.go('/browse'),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: AppConstants.animFast,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat.icon, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(cat.name, style: AppTextStyles.labelMedium),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Trending section ──────────────────────────────────────────────────────────

class _TrendingSection extends StatelessWidget {
  final WidgetRef ref;
  const _TrendingSection({required this.ref});

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Trending Now 🔥', style: AppTextStyles.titleLarge),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/browse'),
              child: Text('See All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ref.watch(trendingAuctionsProvider).when(
          loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
          error: (e, _) => Text('Error: $e'),
          data: (items) => SizedBox(
            height: 240,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final item = items[i];
                final diff = item.endTime.difference(DateTime.now());
                final timerColor = diff.inHours < 1
                    ? AppColors.timerCoral
                    : diff.inHours <= 24
                        ? AppColors.timerAmber
                        : AppColors.timerGreen;

                return HoverCard(
                  onTap: () => context.push('/auction/${item.id}'),
                  backgroundColor: Colors.white,
                  child: SizedBox(
                    width: 200,
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
                              image: item.imageUrl != null
                                  ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: item.imageUrl == null
                                ? Center(child: Text(item.imageEmoji, style: const TextStyle(fontSize: 42)))
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(item.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
                          ),
                          const SizedBox(height: 4),
                          Text(item.title, style: AppTextStyles.titleSmall.copyWith(fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const Spacer(),
                          Text(_fmt(item.currentBid), style: AppTextStyles.priceSmall),
                          Row(
                            children: [
                              Icon(Icons.timer_outlined, size: 11, color: timerColor),
                              const SizedBox(width: 3),
                              Text(
                                diff.inDays > 0 ? '${diff.inDays}d ${diff.inHours % 24}h' : '${diff.inHours}h ${diff.inMinutes % 60}m',
                                style: AppTextStyles.labelSmall.copyWith(color: timerColor, fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Live stats panel ──────────────────────────────────────────────────────────

class _LiveStatsPanel extends StatelessWidget {
  final WidgetRef ref;
  const _LiveStatsPanel({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Activity', style: AppTextStyles.titleMedium),
          const SizedBox(height: 4),
          Text('Live updates', style: AppTextStyles.labelSmall.copyWith(color: AppColors.timerGreen)),
          const SizedBox(height: 20),
          ...[
            ('New listings today', '42', Icons.add_circle_outline),
            ('Bids placed today', '318', Icons.gavel_rounded),
            ('Auctions ending soon', '17', Icons.timer_outlined),
            ('Verified sellers', '95', Icons.verified_rounded),
          ].map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Icon(item.$3, size: 18, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.$1, style: AppTextStyles.bodySmall)),
                    Text(item.$2, style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary)),
                  ],
                ),
              )),
          const Divider(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/browse'),
              icon: const Icon(Icons.search_rounded, size: 16),
              label: const Text('Browse All'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Recent section ────────────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  final WidgetRef ref;
  const _RecentSection({required this.ref});

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Recently Listed', style: AppTextStyles.titleLarge),
            const Spacer(),
            TextButton(
              onPressed: () => context.go('/browse'),
              child: Text('See All', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ref.watch(recentAuctionsProvider).when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (e, _) => Text('Error: $e'),
          data: (items) => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              final diff = item.endTime.difference(DateTime.now());
              final timerColor = diff.inHours < 1
                  ? AppColors.timerCoral
                  : diff.inHours <= 24
                      ? AppColors.timerAmber
                      : AppColors.timerGreen;

              return HoverCard(
                onTap: () => context.push('/auction/${item.id}'),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: AppColors.primaryFixed,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          image: item.imageUrl != null
                              ? DecorationImage(image: NetworkImage(item.imageUrl!), fit: BoxFit.cover)
                              : null,
                        ),
                        child: item.imageUrl == null
                            ? Center(child: Text(item.imageEmoji, style: const TextStyle(fontSize: 46)))
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(item.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
                      ),
                      const SizedBox(height: 4),
                      Text(item.title, style: AppTextStyles.titleSmall.copyWith(fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const Spacer(),
                      Text('Current Bid', style: AppTextStyles.labelSmall),
                      Text(_fmt(item.currentBid), style: AppTextStyles.priceSmall),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 11, color: timerColor),
                          const SizedBox(width: 3),
                          Text(
                            diff.inDays > 0 ? '${diff.inDays}d' : '${diff.inHours}h ${diff.inMinutes % 60}m',
                            style: AppTextStyles.labelSmall.copyWith(color: timerColor, fontSize: 10),
                          ),
                          const Spacer(),
                          Text('${item.totalBids} bids', style: AppTextStyles.labelSmall.copyWith(fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
