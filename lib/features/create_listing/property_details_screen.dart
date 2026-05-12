import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_text_field.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final String category;
  final String subCategory;

  const PropertyDetailsScreen({
    super.key,
    required this.category,
    required this.subCategory,
  });

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final _areaController = TextEditingController();
  
  int _selectedBedrooms = 3;
  int _selectedBathrooms = 2;
  bool _isFurnished = false;
  String _constructionStatus = 'Ready'; // 'Ready' or 'Under Construction'

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
    _areaController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onContinue() {
    // Navigate to the final CreateListingScreen with the property details in extra or query params
    // For now, we'll pass them in a combined description or as separate fields if we update the model.
    // To keep it simple and consistent with existing flow, we'll pass them to CreateListingScreen.
    
    final propertyDetails = {
      'Area': '${_areaController.text} Marla',
      'Bedrooms': _selectedBedrooms.toString(),
      'Bathrooms': _selectedBathrooms.toString(),
      'Furnished': _isFurnished ? 'Yes' : 'No',
      'Status': _constructionStatus,
    };

    context.push('/create/details', extra: {
      'category': widget.category,
      'subCategory': widget.subCategory,
      'model': null, // Properties don't have "models" usually
      'propertyDetails': propertyDetails,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Mesh Gradient Background
          Positioned.fill(child: Container(color: const Color(0xFFF8F9FE))),
          Positioned(top: -100, right: -100, child: _BlurredCircle(color: AppColors.primary.withValues(alpha: 0.1), size: 400)),
          Positioned(bottom: -100, left: -100, child: _BlurredCircle(color: AppColors.secondary.withValues(alpha: 0.05), size: 400)),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SafeArea(
                child: Column(
                  children: [
                    // Premium AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _CircleIconButton(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => context.pop(),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  'Step 3 of 5',
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Property Details',
                                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    Expanded(
                      child: CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(24),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                _AnimatedSection(
                                  index: 0,
                                  controller: _staggerController,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Nearly there!', style: AppTextStyles.headlineLarge.copyWith(fontSize: 34)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Fill in the specific details for your ${widget.subCategory}.',
                                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Area Section
                                _AnimatedSection(
                                  index: 1,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader(Icons.square_foot_rounded, 'Total Area'),
                                        const SizedBox(height: 16),
                                        AppTextField(
                                          label: 'Area Size',
                                          hint: 'Enter area size',
                                          controller: _areaController,
                                          keyboardType: TextInputType.number,
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(right: 12, top: 14),
                                            child: Text('Marla', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Bedrooms & Bathrooms
                                _AnimatedSection(
                                  index: 2,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildSectionHeader(Icons.bed_rounded, 'Bedrooms'),
                                        const SizedBox(height: 12),
                                        _buildChipSelector(
                                          count: 6,
                                          selectedValue: _selectedBedrooms,
                                          onSelected: (val) => setState(() => _selectedBedrooms = val),
                                        ),
                                        const SizedBox(height: 24),
                                        _buildSectionHeader(Icons.bathtub_rounded, 'Bathrooms'),
                                        const SizedBox(height: 12),
                                        _buildChipSelector(
                                          count: 6,
                                          selectedValue: _selectedBathrooms,
                                          onSelected: (val) => setState(() => _selectedBathrooms = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Furnished & Status
                                _AnimatedSection(
                                  index: 3,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Furnished', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                                Text('Is the property move-in ready?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                                              ],
                                            ),
                                            Switch.adaptive(
                                              value: _isFurnished,
                                              activeColor: AppColors.primary,
                                              onChanged: (val) => setState(() => _isFurnished = val),
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.symmetric(vertical: 20),
                                          child: Divider(height: 1),
                                        ),
                                        Text('Construction Status', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _StatusCard(
                                                title: 'Ready',
                                                isSelected: _constructionStatus == 'Ready',
                                                onTap: () => setState(() => _constructionStatus = 'Ready'),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: _StatusCard(
                                                title: 'Under Construction',
                                                isSelected: _constructionStatus == 'Under Construction',
                                                onTap: () => setState(() => _constructionStatus = 'Under Construction'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                _AnimatedSection(
                                  index: 4,
                                  controller: _staggerController,
                                  child: _SubmitButton(
                                    title: 'Continue',
                                    onTap: _onContinue,
                                  ),
                                ),
                                const SizedBox(height: 40),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Text(title, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildChipSelector({required int count, required int selectedValue, required Function(int) onSelected}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(count, (index) {
          final value = index + 1;
          final isSelected = selectedValue == value;
          final label = value == count ? '$index+' : value.toString();

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => onSelected(value),
              selectedColor: AppColors.primary,
              labelStyle: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outlineVariant, width: 1),
              ),
            ),
          );
        }),
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
        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
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
        padding: const EdgeInsets.all(10),
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
      curve: Interval(index * 0.1, (index * 0.1) + 0.5, curve: Curves.easeOutBack),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusCard({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant, width: 2),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              color: isSelected ? AppColors.primary : AppColors.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _SubmitButton({required this.title, required this.onTap});

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
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
