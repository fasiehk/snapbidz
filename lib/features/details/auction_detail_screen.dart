import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../auctions/controllers/auction_controller.dart';
import '../auctions/models/auction_model.dart';
import '../auctions/repositories/auction_repository.dart';
import '../auth/controllers/auth_controller.dart';
import '../bids/repositories/bid_repository.dart';
import '../bids/models/bid_model.dart';
import '../seller_verification/controllers/seller_verification_controller.dart';

class AuctionDetailScreen extends ConsumerStatefulWidget {
  final String auctionId;
  const AuctionDetailScreen({super.key, required this.auctionId});

  @override
  ConsumerState<AuctionDetailScreen> createState() => _AuctionDetailScreenState();
}

class _AuctionDetailScreenState extends ConsumerState<AuctionDetailScreen> {
  bool _isWatched = false;
  int _currentImageIndex = 0;
  late TextEditingController _bidController;

  @override
  void initState() {
    super.initState();
    _bidController = TextEditingController();
  }

  @override
  void dispose() {
    _bidController.dispose();
    super.dispose();
  }

  String _formatCurrency(int value) {
    if (value >= 1000) return '\$${(value / 1000).toStringAsFixed(1)}k';
    return '\$$value';
  }
  
  String _timeLeft(DateTime endTime) {
    final diff = endTime.difference(DateTime.now());
    if (diff.inDays > 0) return '${diff.inDays}d ${diff.inHours % 24}h';
    return '${diff.inHours}h ${diff.inMinutes % 60}m';
  }

  String _timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  void _messageSeller(AuctionModel auction) {
    final user = ref.read(authControllerProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to message the seller.')),
      );
      return;
    }
    // Don't allow sellers to message themselves
    if (user.$id == auction.sellerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own listing.')),
      );
      return;
    }
    context.push(
      '/chat/${auction.id}',
      extra: {
        'auctionTitle': auction.title,
        'otherUserId': auction.sellerId,
        'otherUserName': auction.sellerName,
        'currentBid': '\$${auction.currentBid}',
      },
    );
  }

  void _showBidDialog(AuctionModel auction) {
    _bidController.text = (auction.currentBid + 100).toString();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BidBottomSheet(
        currentBid: '\$${auction.currentBid}',
        controller: _bidController,
        onPlace: () async {
          final amount = int.tryParse(_bidController.text) ?? 0;
          if (amount <= auction.currentBid) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bid must be higher than current bid.')));
            return;
          }
          
          final user = ref.read(authControllerProvider).value;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login to place a bid.')));
            return;
          }

          // ── Buyer profile completeness check ─────────────────────────────
          final isComplete = await ref
              .read(sellerProfileProvider.notifier)
              .isProfileComplete(user.$id);
          if (!isComplete) {
            if (context.mounted) {
              Navigator.pop(context);
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  title: const Row(children: [
                    Icon(Icons.person_off_rounded,
                        color: AppColors.accent, size: 22),
                    SizedBox(width: 8),
                    Text('Profile Incomplete'),
                  ]),
                  content: const Text(
                      'You need to complete your profile before placing a bid. It only takes a minute!'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/seller-verify', extra: {'redirectPath': '/auction/${auction.id}'});
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: const Text('Complete Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            }
            return;
          }

          try {
            final bidRepo = ref.read(bidRepositoryProvider);
            final auctionRepo = ref.read(auctionRepositoryProvider);
            
            final bid = BidModel(
              id: '',
              auctionId: auction.id,
              bidderId: user.$id,
              bidderName: user.name,
              amount: amount,
              timestamp: DateTime.now(),
            );
            
            await bidRepo.placeBid(bid);
            
            // Fetch all bids for this auction to calculate the new highest bid
            final allBids = await bidRepo.getBids(queries: [
              Query.equal('auctionId', auction.id),
              Query.orderDesc('amount'),
            ]);
            
            final newHighestBid = allBids.isNotEmpty ? allBids.first.amount : amount;
            final newTotalBids = allBids.length;
            
            await auctionRepo.updateAuction(auction.id, {
              'currentBid': newHighestBid,
              'totalBids': newTotalBids,
            });
            
            ref.invalidate(auctionDetailProvider(auction.id));
            ref.invalidate(auctionBidsProvider(auction.id));
            ref.invalidate(myBiddedAuctionsProvider(user.$id));
            
            // Invalidate seller's listings to reflect the new bid
            ref.invalidate(myListingsProvider(auction.sellerId));
            
            // Invalidate global auction providers to update listings across the app
            ref.invalidate(allAuctionsProvider);
            ref.invalidate(recentAuctionsProvider);
            ref.invalidate(trendingAuctionsProvider);
            
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('🎉 Bid placed successfully!'),
                  backgroundColor: AppColors.secondary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error placing bid: $e')));
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auctionAsync = ref.watch(auctionDetailProvider(widget.auctionId));
    final bidsAsync = ref.watch(auctionBidsProvider(widget.auctionId));

    // Calculate display values at build level for access in bottomNavigationBar
    int displayCurrentBid = 0;
    if (auctionAsync.hasValue && bidsAsync.hasValue) {
      final auction = auctionAsync.value!;
      final bids = bidsAsync.value ?? [];
      final displayCurrentBid = bids.isNotEmpty ? bids.map((b) => b.amount).reduce((a, b) => a > b ? a : b) : auction.currentBid;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: auctionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
        data: (auction) {
          // Recalculate inside data callback for use in the body
          final bids = bidsAsync.value ?? [];
          final actualHighestBid = bids.isNotEmpty ? bids.map((b) => b.amount).reduce((a, b) => a > b ? a : b) : auction.currentBid;
          final actualTotalBids = bids.length;
          
          final bodyDisplayCurrentBid = actualHighestBid;
          final bodyDisplayTotalBids = actualTotalBids;
          
          return CustomScrollView(
            slivers: [
              // ── Hero Image ───────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.primaryFixed,
                leading: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(220),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                  ),
                ),
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _isWatched = !_isWatched),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isWatched ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: _isWatched ? AppColors.accent : AppColors.onSurface,
                        size: 22,
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: auction.imageUrls.isNotEmpty
                      ? Stack(
                          children: [
                            PageView.builder(
                              itemCount: auction.imageUrls.length,
                              onPageChanged: (idx) => setState(() => _currentImageIndex = idx),
                              itemBuilder: (context, index) {
                                return Image.network(
                                  auction.imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            ),
                            if (auction.imageUrls.length > 1)
                              Positioned(
                                bottom: 16,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    auction.imageUrls.length,
                                    (index) => Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 4),
                                      width: _currentImageIndex == index ? 12 : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryFixed,
                            image: auction.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(auction.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: auction.imageUrl == null
                              ? Center(
                                  child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 100)),
                                )
                              : null,
                        ),
                ),
              ),

              // ── Content ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spaceLG),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category + title
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        ),
                        child: Text(auction.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                      ),
                      const SizedBox(height: AppConstants.spaceSM),
                      Text(auction.title, style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(
                        auction.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant),
                      ),

                      const SizedBox(height: AppConstants.spaceMD),

                      // Seller row
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryFixed,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                auction.sellerName.isNotEmpty ? auction.sellerName.substring(0, 1) : 'S',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auction.sellerName, style: AppTextStyles.titleSmall),
                              Text('Verified Seller • 4.9 ★', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: AppConstants.spaceLG),

                      // Bid stats card
                      GlassCard(
                        padding: const EdgeInsets.all(AppConstants.spaceMD),
                        child: Row(
                          children: [
                            _StatBox(label: 'Current Bid', value: _formatCurrency(bodyDisplayCurrentBid), valueStyle: AppTextStyles.priceLarge),
                            const SizedBox(width: 1),
                            Container(width: 1, height: 48, color: AppColors.outlineVariant),
                            const SizedBox(width: 1),
                            _StatBox(label: 'Time Left', value: _timeLeft(auction.endTime), valueStyle: AppTextStyles.headlineSmall.copyWith(color: AppColors.timerAmber)),
                            const SizedBox(width: 1),
                            Container(width: 1, height: 48, color: AppColors.outlineVariant),
                            const SizedBox(width: 1),
                            _StatBox(label: 'Total Bids', value: '$bodyDisplayTotalBids', valueStyle: AppTextStyles.headlineSmall),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceLG),

                      // Description
                      Text('Description', style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppConstants.spaceSM),
                      GlassCard(
                        padding: const EdgeInsets.all(AppConstants.spaceMD),
                        child: Text(
                          auction.description,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant, height: 1.7),
                        ),
                      ),

                      const SizedBox(height: AppConstants.spaceLG),

                      // Recent Bids
                      Text('Recent Bids', style: AppTextStyles.titleMedium),
                      const SizedBox(height: AppConstants.spaceSM),
                      ref.watch(auctionBidsProvider(auction.id)).when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error loading bids: $e')),
                        data: (bids) {
                          if (bids.isEmpty) {
                            return GlassCard(
                              padding: const EdgeInsets.all(AppConstants.spaceMD),
                              child: Center(
                                child: Text('No bids yet. Be the first!', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                              ),
                            );
                          }
                          return GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
                            child: Column(
                              children: bids.asMap().entries.map((e) {
                                final bid = e.value;
                                final isFirst = e.key == 0;
                                return Column(
                                  children: [
                                    if (e.key > 0) Divider(height: 1, color: AppColors.outlineVariant.withAlpha(80)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: isFirst ? AppColors.primary : AppColors.primaryFixed,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                bid.bidderName.isNotEmpty ? bid.bidderName.substring(0, 1).toUpperCase() : 'U',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: isFirst ? AppColors.onPrimary : AppColors.primaryDark,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(bid.bidderName, style: AppTextStyles.titleSmall.copyWith(fontSize: 13)),
                                                    if (isFirst) ...[
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.secondary.withAlpha(25),
                                                          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                                                        ),
                                                        child: Text('Leading', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontSize: 9)),
                                                      ),
                                                    ]
                                                  ],
                                                ),
                                                Text(_timeAgo(bid.timestamp), style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                                              ],
                                            ),
                                          ),
                                          Text(_formatCurrency(bid.amount), style: AppTextStyles.priceSmall),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 100), // bottom padding for FAB
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: auctionAsync.hasValue ? Container(
        padding: EdgeInsets.fromLTRB(
          AppConstants.spaceLG, AppConstants.spaceMD,
          AppConstants.spaceLG, AppConstants.spaceMD + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(230),
          border: Border(top: BorderSide(color: AppColors.outlineVariant.withAlpha(60))),
        ),
        child: Builder(builder: (context) {
          final auction = auctionAsync.value!;
          final user = ref.watch(authControllerProvider).value;
          final isSeller = user != null && user.$id == auction.sellerId;

          if (isSeller) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: AppConstants.spaceSM),
                Text('This is your listing', style: AppTextStyles.titleMedium.copyWith(color: AppColors.primary)),
              ],
            );
          }

          return Row(
            children: [
              // Message Seller button
              Padding(
                padding: const EdgeInsets.only(right: AppConstants.spaceSM),
                child: OutlinedButton.icon(
                  onPressed: () => _messageSeller(auction),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Chat'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Minimum next bid', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                    Text('\$${displayCurrentBid + 100}', style: AppTextStyles.priceMedium),
                  ],
                ),
              ),
              const SizedBox(width: AppConstants.spaceMD),
              SizedBox(
                height: 52,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 14, offset: const Offset(0, 6))],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () => _showBidDialog(auction),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    icon: const Icon(Icons.gavel_rounded, size: 20),
                    label: Text('Place Bid', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary, fontSize: 16)),
                  ),
                ),
              ),
            ],
          );
        }),
      ) : const SizedBox.shrink(),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle valueStyle;
  const _StatBox({required this.label, required this.value, required this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(value, style: valueStyle, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _BidBottomSheet extends StatelessWidget {
  final String currentBid;
  final TextEditingController controller;
  final VoidCallback onPlace;
  const _BidBottomSheet({required this.currentBid, required this.controller, required this.onPlace});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.outlineVariant, borderRadius: BorderRadius.circular(AppConstants.radiusFull))),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          Text('Place Your Bid', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 4),
          Text('Current bid: $currentBid', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppConstants.spaceLG),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.priceLarge,
            decoration: InputDecoration(
              labelText: 'Your Bid (USD)',
              prefixText: '\$',
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
              ),
              child: ElevatedButton(
                onPressed: onPlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: AppColors.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusSM)),
                ),
                child: Text('Confirm Bid', style: AppTextStyles.labelLarge.copyWith(color: AppColors.onPrimary, fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
