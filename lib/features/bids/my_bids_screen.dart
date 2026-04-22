import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<DummyAuction> _filtered(String status) =>
      AppDummyData.myBids.where((a) => a.status == status).toList();

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
              child: Text('My Listings', style: AppTextStyles.headlineMedium),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Stats row ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
              child: GlassCard(
                padding: const EdgeInsets.all(AppConstants.spaceMD),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Stat(label: 'Active', value: '1', color: AppColors.timerAmber),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _Stat(label: 'Won', value: '1', color: AppColors.secondary),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _Stat(label: 'Lost', value: '1', color: AppColors.accent),
                    Container(width: 1, height: 36, color: AppColors.outlineVariant),
                    _Stat(label: 'Total Spent', value: '\$4.2k', color: AppColors.primary),
                  ],
                ),
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
                    Tab(text: 'Active'),
                    Tab(text: 'Won'),
                    Tab(text: 'Lost'),
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
                  _BidList(items: _filtered('active'), emptyMessage: 'No active bids'),
                  _BidList(items: _filtered('won'), emptyMessage: 'No won auctions yet'),
                  _BidList(items: _filtered('lost'), emptyMessage: 'No lost auctions'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.titleMedium.copyWith(color: color)),
        Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
      ],
    );
  }
}

class _BidList extends StatelessWidget {
  final List<DummyAuction> items;
  final String emptyMessage;
  const _BidList({required this.items, required this.emptyMessage});

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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _BidCard(auction: items[i]),
    );
  }
}

class _BidCard extends StatelessWidget {
  final DummyAuction auction;
  const _BidCard({required this.auction});

  Color get _statusColor => switch (auction.status) {
    'won' => AppColors.secondary,
    'lost' => AppColors.accent,
    _ => AppColors.timerAmber,
  };

  String get _statusLabel => switch (auction.status) {
    'won' => '🏆 Won',
    'lost' => '❌ Outbid',
    _ => '🔥 Active',
  };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
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
                ),
                child: Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 30))),
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
                            color: _statusColor.withAlpha(25),
                            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                          ),
                          child: Text(_statusLabel, style: AppTextStyles.labelSmall.copyWith(color: _statusColor, fontSize: 10)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(auction.subtitle, style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
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
              _InfoCell(label: 'Current Bid', value: auction.currentBid),
              _InfoCell(label: 'Total Bids', value: '${auction.totalBids}'),
              _InfoCell(label: 'Time', value: auction.timeLeft),
            ],
          ),
        ],
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
