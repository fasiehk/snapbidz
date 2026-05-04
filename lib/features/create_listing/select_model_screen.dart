import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/category_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_background.dart';

class SelectModelScreen extends StatefulWidget {
  final String categoryName;
  final SubCategory subCategory;

  const SelectModelScreen({
    super.key,
    required this.categoryName,
    required this.subCategory,
  });

  @override
  State<SelectModelScreen> createState() => _SelectModelScreenState();
}

class _SelectModelScreenState extends State<SelectModelScreen> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredModels = [];

  @override
  void initState() {
    super.initState();
    _filteredModels = widget.subCategory.models ?? [];
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

  void _filterModels(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredModels = widget.subCategory.models ?? [];
      } else {
        _filteredModels = (widget.subCategory.models ?? [])
            .where((model) => model.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
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
                      child: Text(
                        widget.subCategory.name,
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
                          Text('Select Brand\nor Model', style: AppTextStyles.headlineLarge.copyWith(fontSize: 34, height: 1.1)),
                          const SizedBox(height: 12),
                          Text(
                            'Almost there! Pick the exact model to list.',
                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 24),
                          
                          // Search Bar
                          _GlassSearchBar(
                            controller: _searchController,
                            onChanged: _filterModels,
                            hint: 'Search brands...',
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
                            final model = _filteredModels[index];
                            return _AnimatedModelTile(
                              index: index,
                              controller: _staggerController,
                              model: model,
                              categoryName: widget.categoryName,
                              subCategoryName: widget.subCategory.name,
                            );
                          },
                          childCount: _filteredModels.length,
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
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────



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

class _AnimatedModelTile extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final String model;
  final String categoryName;
  final String subCategoryName;

  const _AnimatedModelTile({
    required this.index,
    required this.controller,
    required this.model,
    required this.categoryName,
    required this.subCategoryName,
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
              if (cat.contains('vehicle')) {
                context.push('/create/vehicle-details', extra: {
                  'category': categoryName,
                  'subCategory': subCategoryName,
                  'model': model,
                });
              } else if (cat.contains('mobile') || cat.contains('electronic') || cat.contains('computer')) {
                context.push('/create/tech-details', extra: {
                  'category': categoryName,
                  'subCategory': subCategoryName,
                  'model': model,
                });
              } else {
                context.push('/create/details', extra: {
                  'category': categoryName,
                  'subCategory': subCategoryName,
                  'model': model,
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
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_outlined, size: 20, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      model,
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

