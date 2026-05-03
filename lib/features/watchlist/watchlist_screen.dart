import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../auctions/models/auction_model.dart';
import 'controllers/watchlist_controller.dart';
import 'repositories/watchlist_repository.dart';
import '../auth/controllers/auth_controller.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistAsync = ref.watch(watchlistProvider);
    final user = ref.watch(authControllerProvider).value;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
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

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: watchlistAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (err, _) => Center(child: Text('Failed to load watchlist: $err')),
                data: (watchlist) => watchlist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.favorite_border_rounded, size: 64, color: AppColors.outline),
                            const SizedBox(height: 16),
                            Text('Your watchlist is empty', style: AppTextStyles.titleMedium),
                            const SizedBox(height: 8),
                            Text('Items you watch will appear here.', 
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      )
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

  String _formatCurrency(int value) {
    if (value >= 1000) return 'PKR ${(value / 1000).toStringAsFixed(1)}k';
    return 'PKR $value';
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppConstants.spaceMD),
      onTap: widget.onTap,
      child: Column(
        children: [
          Row(
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  image: widget.auction.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(widget.auction.imageUrl!),
                          fit: BoxFit.cover,
                        )
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
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      ),
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
                      userId: user.$id,
                      auctionId: widget.auction.id,
                      isCurrentlyWatching: _watching,
                    );
                    if (mounted) {
                      setState(() => _watching = !_watching);
                      if (!_watching) {
                        widget.onRemoved();
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                icon: Icon(
                  _watching ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: _watching ? AppColors.accent : AppColors.outline,
                  size: 22,
                ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Bid', style: AppTextStyles.labelSmall),
                  Text(_formatCurrency(widget.auction.currentBid), style: AppTextStyles.priceMedium),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Bids', style: AppTextStyles.labelSmall),
                  Text('${widget.auction.totalBids}', style: AppTextStyles.titleSmall),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _timerColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 13, color: _timerColor),
                    const SizedBox(width: 4),
                    Text(_timeLeft, style: AppTextStyles.labelMedium.copyWith(color: _timerColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
