import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

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
              padding: const EdgeInsets.fromLTRB(AppConstants.spaceLG, AppConstants.spaceMD, AppConstants.spaceLG, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Your Watchlist', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Tracking ${AppDummyData.watchlist.length} high-value auctions',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── List ─────────────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                itemCount: AppDummyData.watchlist.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final item = AppDummyData.watchlist[i];
                  return _WatchlistCard(auction: item, onTap: () => context.push('/auction/${item.id}'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistCard extends StatefulWidget {
  final DummyAuction auction;
  final VoidCallback onTap;
  const _WatchlistCard({required this.auction, required this.onTap});

  @override
  State<_WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<_WatchlistCard> {
  bool _watching = true;

  Color get _timerColor {
    if (widget.auction.timeLeft.contains('h') && !widget.auction.timeLeft.contains('d')) {
      final h = int.tryParse(widget.auction.timeLeft.split('h')[0]) ?? 99;
      if (h <= 2) return AppColors.timerCoral;
      return AppColors.timerAmber;
    }
    return AppColors.timerGreen;
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
                ),
                child: Center(child: Text(widget.auction.imageEmoji, style: const TextStyle(fontSize: 36))),
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
                onPressed: () => setState(() => _watching = !_watching),
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
                  Text(widget.auction.currentBid, style: AppTextStyles.priceMedium),
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
                    Text(widget.auction.timeLeft, style: AppTextStyles.labelMedium.copyWith(color: _timerColor)),
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
