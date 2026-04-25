import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';
import '../auctions/controllers/auction_controller.dart';
import '../auctions/models/auction_model.dart';
import '../auth/controllers/auth_controller.dart';

class MyBidsScreen extends ConsumerStatefulWidget {
  const MyBidsScreen({super.key});

  @override
  ConsumerState<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends ConsumerState<MyBidsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text('My Bids & Listings', style: AppTextStyles.headlineMedium),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Tabs ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(180),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                  border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelStyle: AppTextStyles.labelMedium,
                  unselectedLabelStyle: AppTextStyles.labelMedium,
                  labelColor: AppColors.onPrimary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM - 2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'My Listings'),
                    Tab(text: 'My Bids'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // My Listings
                  user == null 
                    ? const Center(child: Text('Please login to view listings'))
                    : ref.watch(myListingsProvider(user.$id)).when(
                        data: (listings) => _DynamicListingList(items: listings, emptyMessage: 'You haven\'t posted any listings yet.', isMyListing: true),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Error: $e')),
                      ),
                  // My Bids
                  user == null 
                    ? const Center(child: Text('Please login to view your bids'))
                    : ref.watch(myBiddedAuctionsProvider(user.$id)).when(
                        data: (auctions) => _DynamicListingList(items: auctions, emptyMessage: 'You haven\'t bid on anything yet.', isMyListing: false),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, st) => Center(child: Text('Error: $e')),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DynamicListingList extends StatelessWidget {
  final List<AuctionModel> items;
  final String emptyMessage;
  final bool isMyListing;
  const _DynamicListingList({required this.items, required this.emptyMessage, required this.isMyListing});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 52)),
            const SizedBox(height: AppConstants.spaceMD),
            Text(emptyMessage, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceMD),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _DynamicListingCard(auction: items[i], isMyListing: isMyListing),
    );
  }
}

class _DynamicListingCard extends StatelessWidget {
  final AuctionModel auction;
  final bool isMyListing;
  const _DynamicListingCard({required this.auction, required this.isMyListing});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!isMyListing) {
          context.push('/auction/${auction.id}');
          return;
        }
        // Show options: View Details or Edit
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (context) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Manage Listing', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.visibility, color: AppColors.primary),
                    title: const Text('View Listing'),
                    onTap: () {
                      context.pop();
                      context.push('/auction/${auction.id}');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit, color: AppColors.primary),
                    title: const Text('Edit Details'),
                    onTap: () {
                      context.pop();
                      context.push('/edit-listing', extra: auction);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(AppConstants.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    image: auction.imageUrl != null
                        ? DecorationImage(image: NetworkImage(auction.imageUrl!), fit: BoxFit.cover)
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
                      Row(
                        children: [
                          Expanded(child: Text(auction.title, style: AppTextStyles.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withAlpha(25),
                              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                            ),
                            child: Text(auction.status, style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontSize: 10)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(auction.category, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSM),
            Divider(height: 1, color: AppColors.outlineVariant.withAlpha(80)),
            const SizedBox(height: AppConstants.spaceSM),
            Row(
              children: [
                _InfoCell(label: 'Current Bid', value: '\$${auction.currentBid}'),
                _InfoCell(label: 'Total Bids', value: '${auction.totalBids}'),
                _InfoCell(
                  label: 'Ends', 
                  value: '${auction.endTime.day}/${auction.endTime.month}/${auction.endTime.year}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}



class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
          Text(value, style: AppTextStyles.titleSmall),
        ],
      ),
    );
  }
}
