import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/responsive/responsive_layout.dart';
import '../auctions/models/auction_model.dart';
import 'controllers/watchlist_controller.dart';
import 'repositories/watchlist_repository.dart';
import '../auth/controllers/auth_controller.dart';

/// Adaptive watchlist — mobile keeps original layout, desktop uses wider card grid.
class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveLayout(
      mobile:  (_) => _WatchlistMobile(),
      desktop: (_) => _WatchlistDesktop(),
    );
  }
}

// ── Mobile ─────────────────────────────────────────────────────────────────────

class _WatchlistMobile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.spaceLG, AppConstants.spaceMD, AppConstants.spaceLG, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Watchlist', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tracking ${watchlistAsync.value?.length ?? 0} high-value auctions',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMD),
            Expanded(
              child: watchlistAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (err, _) => Center(child: Text('Failed to load watchlist: $err')),
                data: (watchlist) => watchlist.isEmpty
                    ? _EmptyState()
                    : RefreshIndicator(
                        onRefresh: () async => ref.invalidate(watchlistProvider),
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                          itemCount: watchlist.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final item = watchlist[i];
                            return _WatchlistCard(
                              auction: item,
                              onTap: () => context.push('/auction/${item.id}'),
                              onRemoved: () => ref.invalidate(watchlistProvider),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Desktop ─────────────────────────────────────────────────────────────────────

class _WatchlistDesktop extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppBreakpoints.desktopPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your Watchlist', style: AppTextStyles.headlineMedium),
                    Text(
                      'Tracking ${watchlistAsync.value?.length ?? 0} high-value auctions',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 28),

            watchlistAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              error: (e, _) => Text('Error: $e'),
              data: (watchlist) {
                if (watchlist.isEmpty) return _EmptyState();
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: watchlist.length,
                  itemBuilder: (ctx, i) {
                    final item = watchlist[i];
                    return _DesktopWatchCard(
                      auction: item,
                      onTap: () => context.push('/auction/${item.id}'),
                      onRemoved: () => ref.invalidate(watchlistProvider),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.outline),
          const SizedBox(height: 16),
          Text('Your watchlist is empty', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Text('Items you watch will appear here.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}

// ── Mobile watchlist card (original) ──────────────────────────────────────────

class _WatchlistCard extends ConsumerStatefulWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  final VoidCallback onRemoved;
  const _WatchlistCard({required this.auction, required this.onTap, required this.onRemoved});

  @override
  ConsumerState<_WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends ConsumerState<_WatchlistCard> {
  bool _watching = true;

  Color get _timerColor {
    final diff = widget.auction.endTime.difference(DateTime.now());
    if (diff.inHours < 1) return AppColors.timerCoral;
    if (diff.inHours <= 24) return AppColors.timerAmber;
    return AppColors.timerGreen;
  }

  String get _timeLeft {
    final diff = widget.auction.endTime.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      onTap: widget.onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  image: widget.auction.imageUrl != null
                      ? DecorationImage(image: NetworkImage(widget.auction.imageUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: widget.auction.imageUrl == null
                    ? Center(child: Text(widget.auction.imageEmoji, style: const TextStyle(fontSize: 36)))
                    : null,
              ),
              const SizedBox(width: AppConstants.spaceMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withAlpha(25), borderRadius: BorderRadius.circular(AppConstants.radiusFull)),
                      child: Text(widget.auction.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
                    ),
                    const SizedBox(height: 4),
                    Text(widget.auction.title, style: AppTextStyles.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text(widget.auction.subtitle, style: AppTextStyles.bodySmall.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  final user = ref.read(authControllerProvider).value;
                  if (user == null) return;
                  try {
                    await ref.read(watchlistRepositoryProvider).toggleWatchlist(
                      userId: user.$id, auctionId: widget.auction.id, isCurrentlyWatching: _watching,
                    );
                    if (mounted) { setState(() => _watching = !_watching); if (!_watching) widget.onRemoved(); }
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                icon: Icon(_watching ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: _watching ? AppColors.accent : AppColors.outline, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(maxWidth: 32, maxHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSM),
          Divider(height: 1, color: AppColors.outlineVariant.withAlpha(80)),
          const SizedBox(height: AppConstants.spaceSM),
          Row(
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Bid', style: AppTextStyles.labelSmall),
                Text(_fmt(widget.auction.currentBid), style: AppTextStyles.priceMedium),
              ]),
              const Spacer(),
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('Bids', style: AppTextStyles.labelSmall),
                Text('${widget.auction.totalBids}', style: AppTextStyles.titleSmall),
              ]),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _timerColor.withAlpha(25), borderRadius: BorderRadius.circular(AppConstants.radiusFull)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer_outlined, size: 13, color: _timerColor),
                  const SizedBox(width: 4),
                  Text(_timeLeft, style: AppTextStyles.labelMedium.copyWith(color: _timerColor)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Desktop watchlist card ─────────────────────────────────────────────────────

class _DesktopWatchCard extends ConsumerStatefulWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  final VoidCallback onRemoved;
  const _DesktopWatchCard({required this.auction, required this.onTap, required this.onRemoved});

  @override
  ConsumerState<_DesktopWatchCard> createState() => _DesktopWatchCardState();
}

class _DesktopWatchCardState extends ConsumerState<_DesktopWatchCard> {
  bool _watching = true;

  Color get _timerColor {
    final diff = widget.auction.endTime.difference(DateTime.now());
    if (diff.inHours < 1) return AppColors.timerCoral;
    if (diff.inHours <= 24) return AppColors.timerAmber;
    return AppColors.timerGreen;
  }

  String get _timeLeft {
    final diff = widget.auction.endTime.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: widget.onTap,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                image: widget.auction.imageUrl != null
                    ? DecorationImage(image: NetworkImage(widget.auction.imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: widget.auction.imageUrl == null
                  ? Center(child: Text(widget.auction.imageEmoji, style: const TextStyle(fontSize: 38)))
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.auction.title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(_fmt(widget.auction.currentBid), style: AppTextStyles.priceSmall),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.timer_outlined, size: 12, color: _timerColor),
                    const SizedBox(width: 4),
                    Text(_timeLeft, style: AppTextStyles.labelSmall.copyWith(color: _timerColor)),
                    const SizedBox(width: 12),
                    Text('${widget.auction.totalBids} bids', style: AppTextStyles.labelSmall),
                  ]),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                final user = ref.read(authControllerProvider).value;
                if (user == null) return;
                await ref.read(watchlistRepositoryProvider).toggleWatchlist(
                  userId: user.$id, auctionId: widget.auction.id, isCurrentlyWatching: _watching,
                );
                if (mounted) { setState(() => _watching = !_watching); if (!_watching) widget.onRemoved(); }
              },
              icon: Icon(_watching ? Icons.favorite_rounded : Icons.favorite_outline_rounded, color: _watching ? AppColors.accent : AppColors.outline),
            ),
          ],
        ),
      ),
    );
  }
}
