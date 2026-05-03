import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/category_data.dart';

class SelectSubCategoryScreen extends StatelessWidget {
  final AuctionCategory category;

  const SelectSubCategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfcf8ff),
      body: Stack(
        children: [
          // Decorative Blobs
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
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: const Color(0xFF006c49).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // AppBar area
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1b1b23)),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: Text(
                          category.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4648d4),
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for back button
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24.0),
                    itemCount: category.subCategories!.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Subcategory',
                              style: TextStyle(
                                fontFamily: 'Manrope',
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1b1b23),
                                letterSpacing: -0.01,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Step 2: Choose a more specific category',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: Color(0xFF464554),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }
                      
                      final subCategory = category.subCategories![index - 1];
                      return _buildSubCategoryTile(context, subCategory);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubCategoryTile(BuildContext context, SubCategory subCategory) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (subCategory.models != null && subCategory.models!.isNotEmpty) {
            context.push('/create/model', extra: {
              'category': category.name,
              'subCategory': subCategory,
            });
          } else {
            context.push('/create/details', extra: {
              'category': category.name, 
              'subCategory': subCategory.name,
              'model': null,
            });
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subCategory.name,
                style: const TextStyle(
                  fontFamily: 'Manrope',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1b1b23),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF4648d4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
