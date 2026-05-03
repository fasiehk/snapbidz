import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/data/category_data.dart';

class SelectModelScreen extends StatelessWidget {
  final String categoryName;
  final SubCategory subCategory;

  const SelectModelScreen({
    super.key,
    required this.categoryName,
    required this.subCategory,
  });

  @override
  Widget build(BuildContext context) {
    final models = subCategory.models ?? [];

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
                color: const Color(0xFF4648d4).withValues(alpha: 0.1),
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
                color: const Color(0xFF006c49).withValues(alpha: 0.05),
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
                          subCategory.name,
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
                    itemCount: models.length + 1,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Brand / Model',
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
                              'Step 3: Choose the specific brand or model',
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
                      
                      final model = models[index - 1];
                      return _buildModelTile(context, model);
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

  Widget _buildModelTile(BuildContext context, String model) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push('/create/details', extra: {
            'category': categoryName,
            'subCategory': subCategory.name,
            'model': model,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                model,
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
