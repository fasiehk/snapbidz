import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_text_field.dart';

class TechDetailsScreen extends StatefulWidget {
  final String category;
  final String subCategory;
  final String? model;

  const TechDetailsScreen({
    super.key,
    required this.category,
    required this.subCategory,
    this.model,
  });

  @override
  State<TechDetailsScreen> createState() => _TechDetailsScreenState();
}

class _TechDetailsScreenState extends State<TechDetailsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _staggerController;
  final _storageController = TextEditingController();
  final _ramController = TextEditingController();
  
  String _condition = 'Used';
  bool _hasWarranty = false;

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
    _storageController.dispose();
    _ramController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final techDetails = {
      if (_storageController.text.isNotEmpty) 'Storage': _storageController.text,
      if (_ramController.text.isNotEmpty) 'RAM': _ramController.text,
      'Condition': _condition,
      'Warranty': _hasWarranty ? 'Yes' : 'No',
      if (widget.model != null) 'Model': widget.model!,
    };

    context.push('/create/details', extra: {
      'category': widget.category,
      'subCategory': widget.subCategory,
      'model': widget.model,
      'propertyDetails': techDetails,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFFF8F9FE))),
          Positioned(top: -100, left: -100, child: _BlurredCircle(color: AppColors.secondary.withValues(alpha: 0.1), size: 400)),
          
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          _CircleIconButton(icon: Icons.arrow_back_rounded, onTap: () => context.pop()),
                          Expanded(
                            child: Column(
                              children: [
                                Text('Step 4 of 5', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                Text('Technical Specs', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800)),
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
                                      Text('Tech Specs', style: AppTextStyles.headlineLarge.copyWith(fontSize: 34)),
                                      const SizedBox(height: 8),
                                      Text('Specify the technical configuration of your ${widget.model ?? widget.subCategory}.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Storage & RAM
                                _AnimatedSection(
                                  index: 1,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        AppTextField(
                                          label: 'Storage Capacity',
                                          hint: 'e.g. 256GB, 1TB',
                                          controller: _storageController,
                                          prefixIcon: const Icon(Icons.storage_rounded, size: 20),
                                        ),
                                        const SizedBox(height: 20),
                                        AppTextField(
                                          label: 'RAM',
                                          hint: 'e.g. 8GB, 16GB',
                                          controller: _ramController,
                                          prefixIcon: const Icon(Icons.memory_rounded, size: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Condition
                                _AnimatedSection(
                                  index: 2,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildLabel('Condition'),
                                        const SizedBox(height: 12),
                                        _buildSegmentedControl(
                                          options: ['New', 'Open Box', 'Used', 'Refurbished'],
                                          selected: _condition,
                                          onChanged: (val) => setState(() => _condition = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Warranty
                                _AnimatedSection(
                                  index: 3,
                                  controller: _staggerController,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildLabel('Under Warranty'),
                                            Text('Does it have a valid warranty?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                                          ],
                                        ),
                                        Switch.adaptive(
                                          value: _hasWarranty,
                                          activeColor: AppColors.primary,
                                          onChanged: (val) => setState(() => _hasWarranty = val),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 40),

                                _AnimatedSection(
                                  index: 4,
                                  controller: _staggerController,
                                  child: _SubmitButton(title: 'Continue', onTap: _onContinue),
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

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildSegmentedControl({required List<String> options, required String selected, required Function(String) onChanged}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onChanged(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant),
            ),
            child: Text(
              opt,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final Color color;
  final double size;
  const _BlurredCircle({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle), child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)));
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)), child: Icon(icon, size: 20, color: AppColors.onSurface)));
}

class _AnimatedSection extends StatelessWidget {
  final int index;
  final AnimationController controller;
  final Widget child;
  const _AnimatedSection({required this.index, required this.controller, required this.child});
  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(parent: controller, curve: Interval(index * 0.1, (index * 0.1) + 0.5, curve: Curves.easeOutBack));
    return FadeTransition(opacity: animation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation), child: child));
  }
}

class _SubmitButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const _SubmitButton({required this.title, required this.onTap});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, height: 60, decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary])), child: ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)), const SizedBox(width: 12), const Icon(Icons.arrow_forward_rounded, color: Colors.white)])));
}
