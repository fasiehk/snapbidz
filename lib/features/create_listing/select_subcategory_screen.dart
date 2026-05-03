import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/category_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class SelectSubCategoryScreen extends StatefulWidget {
  final AuctionCategory category;

  const SelectSubCategoryScreen({super.key, required this.category});

  @override
  State<SelectSubCategoryScreen> createState() => _SelectSubCategoryScreenState();
}

class _SelectSubCategoryScreenState extends State<SelectSubCategoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final TextEditingController _searchController = TextEditingController();
  List<SubCategory> _filteredSubCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredSubCategories = widget.category.subCategories ?? [];
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSubCategories = widget.category.subCategories ?? [];
      } else {
        _filteredSubCategories = (widget.category.subCategories ?? [])
            .where((sub) => sub.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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

          SafeArea(
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
                        child: Text(
                          widget.category.name,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance
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
                            Text('Select\nSubcategory', style: AppTextStyles.headlineLarge.copyWith(fontSize: 34, height: 1.1)),
                            const SizedBox(height: 12),
                            Text(
                              'Narrow down your listing to the right audience.',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),
                            
                            // Search Bar
                            _GlassSearchBar(
                              controller: _searchController,
                              onChanged: _filterSubCategories,
                              hint: 'Search in ${widget.category.name}...',
                            ),
                            const SizedBox(height: 32),
                          ]),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final subCategory = _filteredSubCategories[index];
                              return _AnimatedSubCategoryTile(
                                index: index,
                                controller: _staggerController,
                                subCategory: subCategory,
                                categoryName: widget.category.name,
                              );
                            },
                            childCount: _filteredSubCategories.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    ],
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

class _GlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hint;

  const _GlassSearchBar({required this.controller, required this.onChanged, required this.hint});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}

class _AnimatedSubCategoryTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final SubCategory subCategory;
  final String categoryName;

  const _AnimatedSubCategoryTile({
    required this.index,
    required this.controller,
    required this.subCategory,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(index * 0.05, (index * 0.05) + 0.4, curve: Curves.easeOutBack),
    );

    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(
            padding: EdgeInsets.zero,
            borderRadius: 16,
            onTap: () {
              final cat = categoryName.toLowerCase();
              if (cat.contains('property')) {
                context.push('/create/property-details', extra: {
                  'category': categoryName,
                  'subCategory': subCategory.name,
                });
              } else if (subCategory.models != null && subCategory.models!.isNotEmpty) {
                context.push('/create/model', extra: {
                  'category': categoryName,
                  'subCategory': subCategory,
                });
              } else if (cat.contains('vehicle')) {
                context.push('/create/vehicle-details', extra: {
                  'category': categoryName,
                  'subCategory': subCategory.name,
                  'model': null,
                });
              } else if (cat.contains('mobile') || cat.contains('electronic') || cat.contains('computer')) {
                context.push('/create/tech-details', extra: {
                  'category': categoryName,
                  'subCategory': subCategory.name,
                  'model': null,
                });
              } else {
                context.push('/create/details', extra: {
                  'category': categoryName,
                  'subCategory': subCategory.name,
                  'model': null,
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.layers_outlined, size: 20, color: AppColors.primary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      subCategory.name,
                      style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

