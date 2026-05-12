import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_breakpoints.dart';
import '../../../core/data/category_data.dart';
import '../../../core/widgets/hover_card.dart';
import '../../../core/responsive/adaptive_padding.dart';
import '../../auctions/controllers/auction_controller.dart';
import '../../auctions/models/auction_model.dart';

/// Desktop browse — filter sidebar left + 4-column grid right.
class BrowseDesktop extends ConsumerStatefulWidget {
  const BrowseDesktop({super.key});

  @override
  ConsumerState<BrowseDesktop> createState() => _BrowseDesktopState();
}

class _BrowseDesktopState extends ConsumerState<BrowseDesktop> {
  int _selectedCategory = 0;
  String _searchQuery = '';
  String _sortBy = 'Newest';
  final _searchCtrl = TextEditingController();

  static const _sortOptions = ['Newest', 'Ending Soon', 'Price ↑', 'Price ↓', 'Most Bids'];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AuctionModel> _filter(List<AuctionModel> all) {
    final catFilter = _selectedCategory == 0 ? null : CategoryData.categories[_selectedCategory - 1].name;
    var list = all.where((a) {
      final matchCat = catFilter == null || a.category == catFilter;
      final matchQ = _searchQuery.isEmpty || a.title.toLowerCase().contains(_searchQuery);
      return matchCat && matchQ;
    }).toList();

    switch (_sortBy) {
      case 'Ending Soon':
        list.sort((a, b) => a.endTime.compareTo(b.endTime));
        break;
      case 'Price ↑':
        list.sort((a, b) => a.currentBid.compareTo(b.currentBid));
        break;
      case 'Price ↓':
        list.sort((a, b) => b.currentBid.compareTo(a.currentBid));
        break;
      case 'Most Bids':
        list.sort((a, b) => b.totalBids.compareTo(a.totalBids));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter sidebar ─────────────────────────────────────────────
          _FilterSidebar(
            selectedCategory: _selectedCategory,
            onCategoryChanged: (i) => setState(() => _selectedCategory = i),
          ),

          // ── Main content ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
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
                          Text('Browse Auctions', style: AppTextStyles.headlineMedium),
                          Text('240+ active listings', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                      const Spacer(),
                      // Search bar
                      SizedBox(
                        width: 300,
                        child: TextField(
                          controller: _searchCtrl,
                          style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search auctions…',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline, fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.outline),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                              borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                              borderSide: BorderSide(color: AppColors.outlineVariant.withOpacity(0.4)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                              borderSide: const BorderSide(color: AppColors.primary, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sort dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isDense: true,
                            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                            items: _sortOptions.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
                            onChanged: (v) => setState(() => _sortBy = v!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Grid
                  ref.watch(allAuctionsProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (e, _) => Text('Error: $e'),
                    data: (all) {
                      final items = _filter(all);
                      if (items.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(60),
                            child: Text('No auctions match your filters.'),
                          ),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length,
                        itemBuilder: (ctx, i) => _DesktopAuctionCard(
                          auction: items[i],
                          onTap: () => context.push('/auction/${items[i].id}'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter sidebar ─────────────────────────────────────────────────────────────

class _FilterSidebar extends StatelessWidget {
  final int selectedCategory;
  final ValueChanged<int> onCategoryChanged;
  const _FilterSidebar({required this.selectedCategory, required this.onCategoryChanged});

  @override
  Widget build(BuildContext context) {
    final allCategories = [
      const AuctionCategory(name: 'All', icon: Icons.category_rounded),
      ...CategoryData.categories,
    ];

    return Container(
      width: 220,
      constraints: const BoxConstraints(minHeight: double.infinity),
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('FILTERS', style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          Text('Categories', style: AppTextStyles.titleSmall),
          const SizedBox(height: 10),
          ...allCategories.asMap().entries.map((e) {
            final i = e.key;
            final cat = e.value;
            final isSelected = selectedCategory == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: InkWell(
                onTap: () => onCategoryChanged(i),
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                child: AnimatedContainer(
                  duration: AppConstants.animFast,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Row(
                    children: [
                      Icon(cat.icon, size: 17, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text(
                        cat.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Desktop auction card ───────────────────────────────────────────────────────

class _DesktopAuctionCard extends StatelessWidget {
  final AuctionModel auction;
  final VoidCallback onTap;
  const _DesktopAuctionCard({required this.auction, required this.onTap});

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

  String _fmt(int v) => v >= 1000 ? 'PKR ${(v / 1000).toStringAsFixed(1)}k' : 'PKR $v';

  @override
  Widget build(BuildContext context) {
    return HoverCard(
      onTap: onTap,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                image: auction.imageUrl != null
                    ? DecorationImage(image: NetworkImage(auction.imageUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: auction.imageUrl == null
                  ? Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 52)))
                  : null,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(auction.category, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontSize: 10)),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _timerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 10, color: _timerColor),
                      const SizedBox(width: 3),
                      Text(_timeLeft, style: AppTextStyles.labelSmall.copyWith(color: _timerColor, fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(auction.title,
                style: AppTextStyles.titleSmall.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const Spacer(),
            Text('Current Bid', style: AppTextStyles.labelSmall),
            Row(
              children: [
                Text(_fmt(auction.currentBid), style: AppTextStyles.priceSmall),
                const Spacer(),
                Text('${auction.totalBids} bids', style: AppTextStyles.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
