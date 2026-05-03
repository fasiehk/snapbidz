import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auctions/models/auction_model.dart';
import '../auctions/repositories/auction_repository.dart';
import '../auctions/controllers/auction_controller.dart';
import '../auth/controllers/auth_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/utils/snackbar_utils.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  final String category;
  final String? subCategory;
  final String? model;
  final Map<String, String>? propertyDetails;

  const CreateListingScreen({
    super.key,
    required this.category,
    this.subCategory,
    this.model,
    this.propertyDetails,
  });

  @override
  ConsumerState<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> with TickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _startingPriceController = TextEditingController();
  DateTime? _selectedEndTime;
  bool _isLoading = false;
  bool _acceptedTerms = false;
  
  late AnimationController _staggerController;
  final _picker = ImagePicker();
  List<XFile> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _startingPriceController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _pickEndTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null && mounted) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          _selectedEndTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          if (_selectedImages.length + images.length > 10) {
            _selectedImages.addAll(images.take(10 - _selectedImages.length));
            _showSnackBar('Maximum 10 images allowed.');
          } else {
            _selectedImages.addAll(images);
          }
        });
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error picking images: $e');
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (isError) {
      SnackBarUtils.showError(context, message);
    } else {
      SnackBarUtils.showSuccess(context, message);
    }
  }

  Future<void> _publishListing() async {
    if (_titleController.text.isEmpty || _startingPriceController.text.isEmpty) {
      _showSnackBar('Please fill all required fields.');
      return;
    }
    if (_selectedEndTime == null) {
      _showSnackBar('Please select an auction end time.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showSnackBar('Please select at least one photo.');
      return;
    }
    if (!_acceptedTerms) {
      _showSnackBar('Please accept the terms to continue.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = ref.read(authControllerProvider).value;
      if (user == null) throw Exception('Not logged in');

      // ── Email Verification Check ─────────────────────────────────────
      if (!user.emailVerification) {
        setState(() => _isLoading = false);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(children: [
                Icon(Icons.mark_email_unread_rounded, color: AppColors.accent, size: 22),
                SizedBox(width: 8),
                Text('Email Not Verified'),
              ]),
              content: const Text('You must verify your email address before you can post a listing.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/profile/edit');
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  child: const Text('Go to Profile', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
        return;
      }

      List<String> uploadedUrls = [];
      for (var img in _selectedImages) {
        final bytes = await img.readAsBytes();
        final url = await ref.read(auctionRepositoryProvider).uploadImage(bytes, img.name);
        uploadedUrls.add(url);
      }

      String finalDescription = _descriptionController.text.isNotEmpty ? _descriptionController.text : 'No description provided.';
      
      if (widget.propertyDetails != null) {
        final specs = widget.propertyDetails!.entries.map((e) => '${e.key}: ${e.value}').join('\n');
        finalDescription = 'SPECIFICATIONS:\n$specs\n\nDETAILS:\n$finalDescription';
      }

      final auction = AuctionModel(
        id: '',
        createdAt: DateTime.now(),
        title: _titleController.text,
        subtitle: widget.subCategory ?? widget.category,
        category: widget.category,
        subCategory: widget.subCategory,
        description: finalDescription,
        imageEmoji: '📦',
        imageUrl: uploadedUrls.isNotEmpty ? uploadedUrls.first : null,
        imageUrls: uploadedUrls,
        currentBid: int.tryParse(_startingPriceController.text) ?? 0,
        totalBids: 0,
        status: 'active',
        endTime: _selectedEndTime!,
        sellerId: user.$id,
        sellerName: user.name,
      );

      await ref.read(auctionRepositoryProvider).createAuction(auction);

      ref.invalidate(allAuctionsProvider);
      ref.invalidate(recentAuctionsProvider);
      ref.invalidate(trendingAuctionsProvider);

      if (mounted) {
        SnackBarUtils.showSuccess(context, '🎉 Listing published successfully!');
        context.go('/home');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mesh Gradient Background
          Positioned.fill(child: Container(color: const Color(0xFFF8F9FE))),
          Positioned(top: -100, left: -100, child: _BlurredCircle(color: AppColors.primary.withValues(alpha: 0.12), size: 400)),
          Positioned(bottom: -50, right: -50, child: _BlurredCircle(color: AppColors.accent.withValues(alpha: 0.08), size: 350)),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _CircleIconButton(
                      icon: Icons.close_rounded,
                      onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                    ),
                  ),
                  title: Text('Create Listing', style: AppTextStyles.titleLarge),
                  centerTitle: true,
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _AnimatedSection(
                        index: 0,
                        controller: _staggerController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Post an Item', style: AppTextStyles.headlineLarge.copyWith(fontSize: 34)),
                            const SizedBox(height: 8),
                            Text(
                              'Showcase your item to thousands of bidders globally.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Photos Section
                      _AnimatedSection(
                        index: 1,
                        controller: _staggerController,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSectionHeader(Icons.photo_library_outlined, 'Photos'),
                                  Text(
                                    '${_selectedImages.length}/10',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (_selectedImages.isEmpty)
                                _EmptyPhotoPlaceholder(onTap: _pickImages)
                              else
                                _PhotoGrid(
                                  images: _selectedImages,
                                  onAdd: _pickImages,
                                  onRemove: _removeImage,
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (widget.propertyDetails != null) ...[
                        _AnimatedSection(
                          index: 2,
                          controller: _staggerController,
                          child: GlassCard(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader(Icons.inventory_2_outlined, 'Property Specifications'),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: widget.propertyDetails!.entries.map((e) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${e.key}: ',
                                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant),
                                          ),
                                          Text(
                                            e.value,
                                            style: AppTextStyles.labelSmall.copyWith(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Basics Section
                      _AnimatedSection(
                        index: 2,
                        controller: _staggerController,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.edit_note_rounded, 'Item Basics'),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Listing Title',
                                hint: 'e.g. Rare 1964 Vintage Chronograph',
                                controller: _titleController,
                              ),
                              const SizedBox(height: 20),
                              _CategoryBreadcrumb(
                                category: widget.category,
                                subCategory: widget.subCategory,
                                model: widget.model,
                                onChange: () => context.pop(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description Section
                      _AnimatedSection(
                        index: 3,
                        controller: _staggerController,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.description_outlined, 'Description'),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Item Details',
                                hint: 'Describe the condition, history, and unique features...',
                                controller: _descriptionController,
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Pricing & Time Section
                      _AnimatedSection(
                        index: 4,
                        controller: _staggerController,
                        child: GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionHeader(Icons.payments_outlined, 'Auction Info'),
                              const SizedBox(height: 20),
                              AppTextField(
                                label: 'Starting Price (PKR)',
                                hint: '0.00',
                                controller: _startingPriceController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                              ),
                              const SizedBox(height: 20),
                              _EndTimePicker(
                                selectedTime: _selectedEndTime,
                                onTap: _pickEndTime,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Final Submission
                      _AnimatedSection(
                        index: 5,
                        controller: _staggerController,
                        child: Column(
                          children: [
                            _TermsCheckbox(
                              value: _acceptedTerms,
                              onChanged: (v) => setState(() => _acceptedTerms = v!),
                            ),
                            const SizedBox(height: 24),
                            _SubmitButton(
                              isLoading: _isLoading,
                              onPressed: _publishListing,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          
          if (_isLoading) _GlobalLoadingOverlay(),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurredCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }
}

class _AnimatedSection extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;

  const _AnimatedSection({required this.index, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(index * 0.1, (index * 0.1) + 0.5, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

class _EmptyPhotoPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyPhotoPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.1), width: 1.5, style: BorderStyle.solid),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text('Add photos of your item', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
            Text('Up to 10 images allowed', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<XFile> images;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const _PhotoGrid({required this.images, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Image
        Stack(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: kIsWeb ? NetworkImage(images.first.path) : FileImage(File(images.first.path)) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: _SmallRemoveButton(onTap: () => onRemove(0)),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                child: const Text('Cover Photo', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        if (images.length > 1 || images.length < 10) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length < 10 ? images.length : images.length,
              itemBuilder: (context, index) {
                if (index == images.length - 1 && images.length < 10) {
                  return _AddMorePhotosButton(onTap: onAdd);
                }
                if (index == 0) return const SizedBox.shrink(); // Skip cover photo
                
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: kIsWeb ? NetworkImage(images[index].path) : FileImage(File(images[index].path)) as ImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: _SmallRemoveButton(onTap: () => onRemove(index), isSmall: true),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ]
      ],
    );
  }
}

class _SmallRemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSmall;
  const _SmallRemoveButton({required this.onTap, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isSmall ? 4 : 6),
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(Icons.close_rounded, size: isSmall ? 12 : 16, color: AppColors.error),
      ),
    );
  }
}

class _AddMorePhotosButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddMorePhotosButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: const Icon(Icons.add_rounded, color: AppColors.primary),
      ),
    );
  }
}

class _CategoryBreadcrumb extends StatelessWidget {
  final String category;
  final String? subCategory;
  final String? model;
  final VoidCallback onChange;

  const _CategoryBreadcrumb({required this.category, this.subCategory, this.model, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  [category, if (subCategory != null) subCategory!, if (model != null) model!].join('  ›  '),
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 13, color: AppColors.primary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onChange,
                child: Text(
                  'Change',
                  style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EndTimePicker extends StatelessWidget {
  final DateTime? selectedTime;
  final VoidCallback onTap;

  const _EndTimePicker({required this.selectedTime, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Auction End Time', style: AppTextStyles.labelMedium.copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary.withValues(alpha: 0.6)),
                const SizedBox(width: 12),
                Text(
                  selectedTime == null
                      ? 'Select date and time'
                      : '${selectedTime!.day}/${selectedTime!.month}/${selectedTime!.year} at ${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: selectedTime == null ? AppColors.outline : AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.outline),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _TermsCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        const Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: AppColors.onSurfaceVariant, height: 1.4),
                children: [
                  TextSpan(text: 'SnapBid Terms', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  TextSpan(text: ' and confirm this listing follows all safety guidelines.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Publish Listing', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 12),
                  const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}

class _GlobalLoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: const Center(
          child: GlassCard(
            width: 100,
            height: 100,
            padding: EdgeInsets.zero,
            child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
      ),
    );
  }
}

