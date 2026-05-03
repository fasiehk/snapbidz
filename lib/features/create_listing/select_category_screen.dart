import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/controllers/auth_controller.dart';
import '../../core/data/category_data.dart';

class SelectCategoryScreen extends ConsumerWidget {
  const SelectCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).value;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              Color(0xFFfff1f2), // Light pinkish
              Color(0xFFfcf8ff), // Surface color
              Color(0xFFe0e7ff), // Light blueish
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.go('/home'),
                              child: const Icon(Icons.arrow_back, color: Color(0xFF4648d4)),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'All Categories',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4648d4),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        if (user != null)
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF6063ee), width: 2),
                              image: user.prefs.data.containsKey('profileUrl')
                                  ? DecorationImage(
                                      image: NetworkImage(user.prefs.data['profileUrl']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: !user.prefs.data.containsKey('profileUrl')
                                ? Center(
                                    child: Text(
                                      user.name.substring(0, 1).toUpperCase(),
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6063ee)),
                                    ),
                                  )
                                : null,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: TextField(
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16, color: Color(0xFF1b1b23)),
                              decoration: const InputDecoration(
                                hintText: 'Search categories to sell...',
                                hintStyle: TextStyle(color: Color(0xFF767586), fontFamily: 'Inter'),
                                prefixIcon: Icon(Icons.search, color: Color(0xFF767586)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      const Text(
                        'What are you selling?',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1b1b23),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select a category to start your listing',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF464554),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                        ),
                        itemCount: CategoryData.categories.length,
                        itemBuilder: (context, index) {
                          final category = CategoryData.categories[index];
                          return _buildCategoryCard(context, category);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, AuctionCategory category) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (category.subCategories != null && category.subCategories!.isNotEmpty) {
            context.push('/create/subcategory', extra: category);
          } else {
            context.push('/create/details', extra: {'category': category.name, 'subCategory': null});
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Color(0xFFe1e0ff), // primary-fixed
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category.icon,
                        color: const Color(0xFF4648d4),
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1b1b23),
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
