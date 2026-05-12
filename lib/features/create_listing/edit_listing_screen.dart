import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auctions/models/auction_model.dart';
import '../auctions/controllers/auction_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_background.dart';
import '../auctions/repositories/auction_repository.dart';
import '../../core/utils/snackbar_utils.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  final AuctionModel auction;
  const EditListingScreen({super.key, required this.auction});

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _startingPriceController;
  String? _selectedCategory;
  bool _isLoading = false;

  final List<String> _categories = ['Watches & Jewelry', 'Art & Collectibles', 'Fashion & Accessories', 'Electronics', 'Real Estate'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.auction.title);
    _descriptionController = TextEditingController(text: widget.auction.description);
    _startingPriceController = TextEditingController(text: widget.auction.currentBid.toString());
    _selectedCategory = widget.auction.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    super.dispose();
  }

  Future<void> _updateListing() async {
    if (_titleController.text.isEmpty || _startingPriceController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final updatedData = {
        'title': _titleController.text,
        'category': _selectedCategory,
        'subtitle': _selectedCategory,
        'description': _descriptionController.text,
        'currentBid': int.tryParse(_startingPriceController.text) ?? widget.auction.currentBid,
      };

      await ref.read(auctionRepositoryProvider).updateAuction(widget.auction.id, updatedData);

      ref.invalidate(recentAuctionsProvider);
      ref.invalidate(trendingAuctionsProvider);
      ref.invalidate(myListingsProvider(widget.auction.sellerId));
      ref.invalidate(auctionDetailProvider(widget.auction.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Listing updated successfully!'),
            backgroundColor: const Color(0xFF006c49),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
                      onPressed: () => context.pop(),
                    ),
                    title: Text('Edit Listing', style: AppTextStyles.titleLarge),
                    centerTitle: true,
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: AppConstants.spaceLG),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        GlassCard(
                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.edit_note_outlined, 'Item Basics'),
                              const SizedBox(height: AppConstants.spaceLG),
                              AppTextField(
                                label: 'Listing Title',
                                hint: 'e.g. Rare 1964 Vintage Chronograph',
                                controller: _titleController,
                              ),
                              const SizedBox(height: AppConstants.spaceMD),
                              _buildInputLabel('Category'),
                              const SizedBox(height: AppConstants.spaceSM),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedCategory,
                                    dropdownColor: Colors.white.withOpacity(0.9),
                                    hint: Text('Select a category', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)),
                                    isExpanded: true,
                                    icon: const Icon(Icons.expand_more_rounded, color: AppColors.outline),
                                    items: _categories.map((c) => DropdownMenuItem(
                                      value: c, 
                                      child: Text(c, style: AppTextStyles.bodyMedium)
                                    )).toList(),
                                    onChanged: (v) => setState(() => _selectedCategory = v),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceLG),
                        GlassCard(
                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.description_outlined, 'Description'),
                              const SizedBox(height: AppConstants.spaceMD),
                              AppTextField(
                                label: 'Item Details',
                                hint: 'Describe your item in detail...',
                                controller: _descriptionController,
                                maxLines: 5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceLG),
                        GlassCard(
                          padding: const EdgeInsets.all(AppConstants.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.payments_outlined, 'Auction Settings'),
                              const SizedBox(height: AppConstants.spaceLG),
                              AppTextField(
                                label: 'Starting Price (PKR)',
                                hint: '0.00',
                                controller: _startingPriceController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Center(
                                    widthFactor: 1.0,
                                    child: Text('PKR ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.outline)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceXXL),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateListing,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusMD)),
                              elevation: 0,
                            ),
                            child: _isLoading 
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  ) 
                                : Text('Save Changes', style: AppTextStyles.labelLarge.copyWith(color: Colors.white, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceXXL),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Text(
      label,
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant),
    );
  }
}
