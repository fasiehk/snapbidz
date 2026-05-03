import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auctions/models/auction_model.dart';
import '../auctions/repositories/auction_repository.dart';
import '../auctions/controllers/auction_controller.dart';

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
      ref.invalidate(myListingsProvider);
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

  Widget _buildGlassPanel({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4648d4), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1b1b23),
          ),
        ),
      ],
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF464554),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF767586), fontFamily: 'Inter'),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfcf8ff),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF4648d4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.white.withOpacity(0.7),
                  pinned: true,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1b1b23)),
                    onPressed: () => context.pop(),
                  ),
                  title: const Text(
                    'Edit Listing',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF4648d4),
                    ),
                  ),
                  centerTitle: true,
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildGlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.edit_note_outlined, 'Item Basics'),
                            const SizedBox(height: 24),
                            _buildInputLabel('Listing Title'),
                            TextField(
                              controller: _titleController,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF1b1b23)),
                              decoration: _inputDecoration('e.g. Rare 1964 Vintage Chronograph'),
                            ),
                            const SizedBox(height: 16),
                            _buildInputLabel('Category'),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white.withOpacity(0.4)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedCategory,
                                  hint: const Text('Select a category', style: TextStyle(color: Color(0xFF767586), fontFamily: 'Inter')),
                                  isExpanded: true,
                                  icon: const Icon(Icons.expand_more_rounded, color: Color(0xFF767586)),
                                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF1b1b23))))).toList(),
                                  onChanged: (v) => setState(() => _selectedCategory = v),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildGlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.description_outlined, 'Description'),
                            const SizedBox(height: 16),
                            _buildInputLabel('Item Details'),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 5,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF1b1b23)),
                              decoration: _inputDecoration('Describe your item in detail...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildGlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(Icons.payments_outlined, 'Auction Settings'),
                            const SizedBox(height: 24),
                            _buildInputLabel('Starting Price (PKR)'),
                            TextField(
                              controller: _startingPriceController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF1b1b23)),
                              decoration: _inputDecoration('0.00', prefixIcon: const Padding(
                                padding: EdgeInsets.only(left: 16.0, right: 8.0),
                                child: Text('PKR ', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF767586))),
                              )).copyWith(prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateListing,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4648d4),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 8,
                          ),
                          child: _isLoading 
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                ) 
                              : const Text('Save Changes', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
