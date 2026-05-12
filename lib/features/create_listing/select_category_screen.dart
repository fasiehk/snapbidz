import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/controllers/auth_controller.dart';
import '../../core/data/category_data.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/gradient_background.dart';

class SelectCategoryScreen extends ConsumerStatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  ConsumerState<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends ConsumerState<SelectCategoryScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _staggerController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _staggerController.forward();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final filteredCategories = CategoryData.categories.where((cat) {
      return cat.name.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Premium Header ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.close_rounded,
                        onTap: () => context.go('/home'),
                      ),
                      const Spacer(),
                      if (user != null) _UserAvatar(user: user),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sell on SnapBid',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'What are you\nlisting today?',
                        style: AppTextStyles.headlineLarge.copyWith(
                          fontSize: 34,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // ── Premium Search Bar ────────────────────────────────
                      _PremiumSearchBar(controller: _searchController),
                    ],
                  ),
                ),
              ),

              // ── Categories Grid ──────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = filteredCategories[index];
                      return _StaggeredCategoryTile(
                        category: category,
                        index: index,
                        totalItems: filteredCategories.length,
                        controller: _staggerController,
                        onTap: () {
                          if (category.subCategories != null && category.subCategories!.isNotEmpty) {
                            context.push('/create/subcategory', extra: category);
                          } else {
                            context.push('/create/details', extra: {
                              'category': category.name,
                              'subCategory': null
                            });
                          }
                        },
                      );
                    },
                    childCount: filteredCategories.length,
                  ),
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
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────



class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final dynamic user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final profileUrl = user.prefs.data['profileUrl'];
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: profileUrl != null
            ? Image.network(profileUrl, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryContainer,
                child: Center(
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _PremiumSearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _PremiumSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search categories...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 24),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}

class _StaggeredCategoryTile extends StatefulWidget {
  final AuctionCategory category;
  final int index;
  final int totalItems;
  final AnimationController controller;
  final VoidCallback onTap;

  const _StaggeredCategoryTile({
    required this.category,
    required this.index,
    required this.totalItems,
    required this.controller,
    required this.onTap,
  });

  @override
  State<_StaggeredCategoryTile> createState() => _StaggeredCategoryTileState();
}

class _StaggeredCategoryTileState extends State<_StaggeredCategoryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: widget.controller,
      curve: Interval(
        (widget.index / widget.totalItems) * 0.6,
        ((widget.index + 1) / widget.totalItems) * 0.6 + 0.4,
        curve: Curves.easeOutBack,
      ),
    );

    return ScaleTransition(
      scale: animation,
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isHovered = true),
          onTapUp: (_) => setState(() => _isHovered = false),
          onTapCancel: () => setState(() => _isHovered = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _isHovered ? 0.96 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.6),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Glass Orb Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primary.withValues(alpha: 0.05),
                              ],
                            ),
                          ),
                          child: Icon(
                            widget.category.icon,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.category.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

