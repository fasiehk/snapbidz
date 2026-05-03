import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'controllers/seller_verification_controller.dart';
import 'models/user_profile_model.dart';
import '../auth/controllers/auth_controller.dart';

class SellerVerificationScreen extends ConsumerStatefulWidget {
  final String? redirectPath;
  const SellerVerificationScreen({super.key, this.redirectPath});

  @override
  ConsumerState<SellerVerificationScreen> createState() =>
      _SellerVerificationScreenState();
}

class _SellerVerificationScreenState
    extends ConsumerState<SellerVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _fullNameCtrl = TextEditingController();
  final _cnicCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _allCategories = [
    'Watches & Jewelry',
    'Art & Collectibles',
    'Fashion & Accessories',
    'Electronics',
    'Real Estate',
    'Antiques',
    'Vehicles',
    'Sports & Outdoors',
  ];

  final Set<String> _selectedCategories = {};

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _cnicCtrl.dispose();
    _addressCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  String? _validateCnic(String? val) {
    if (val == null || val.isEmpty) return 'CNIC is required';
    // Pakistani CNIC: XXXXX-XXXXXXX-X
    final regex = RegExp(r'^\d{5}-\d{7}-\d$');
    if (!regex.hasMatch(val)) return 'Format: XXXXX-XXXXXXX-X';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one category.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isSubmitting = true);
    try {
      final profile = UserProfileModel(
        id: '',
        userId: user.$id,
        fullName: _fullNameCtrl.text.trim(),
        cnic: _cnicCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        preferredCategories: _selectedCategories.toList(),
      );
      await ref.read(sellerProfileProvider.notifier).submitProfile(profile);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(children: [
              Icon(Icons.verified_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Profile verified! You can now list items.'),
            ]),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (widget.redirectPath != null) {
          context.go(widget.redirectPath!);
        } else {
          context.go('/create');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFB91C1C)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFfcf8ff),
      body: Stack(
        children: [
          // Background blobs
          Positioned(
            top: -80,
            right: -80,
            child: _Blob(color: const Color(0xFF4648d4).withOpacity(0.12), size: 320),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: _Blob(color: const Color(0xFF7C3AED).withOpacity(0.08), size: 280),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: CustomScrollView(
                slivers: [
                  // AppBar
                  SliverAppBar(
                    backgroundColor: Colors.white.withOpacity(0.7),
                    pinned: true,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1b1b23)),
                      onPressed: () => context.pop(),
                    ),
                    flexibleSpace: ClipRRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    title: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF4648d4), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Seller Verification',
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1b1b23),
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Hero banner
                        _HeroBanner(),
                        const SizedBox(height: 24),

                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Full Name
                              _GlassPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionLabel(
                                      icon: Icons.person_rounded,
                                      label: 'Full Name',
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _fullNameCtrl,
                                      style: _inputTextStyle,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: _inputDec('e.g. Muhammad Ali Khan'),
                                      validator: (v) => (v == null || v.trim().isEmpty)
                                          ? 'Full name is required'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // CNIC
                              _GlassPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionLabel(
                                      icon: Icons.credit_card_rounded,
                                      label: 'CNIC Number',
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Pakistani National Identity Card (XXXXX-XXXXXXX-X)',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _cnicCtrl,
                                      style: _inputTextStyle,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [_CnicInputFormatter()],
                                      decoration: _inputDec('35202-1234567-8'),
                                      validator: _validateCnic,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Address
                              _GlassPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionLabel(
                                      icon: Icons.location_on_rounded,
                                      label: 'Address',
                                    ),
                                    const SizedBox(height: 10),
                                    TextFormField(
                                      controller: _addressCtrl,
                                      style: _inputTextStyle,
                                      maxLines: 3,
                                      decoration: _inputDec(
                                        'Street, City, Province, Pakistan',
                                      ),
                                      validator: (v) => (v == null || v.trim().length < 10)
                                          ? 'Please enter a full address (min 10 chars)'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Preferred Categories
                              _GlassPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _SectionLabel(
                                      icon: Icons.category_rounded,
                                      label: 'What will you sell?',
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Select at least one category',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: _allCategories.map((cat) {
                                        final selected =
                                            _selectedCategories.contains(cat);
                                        return GestureDetector(
                                          onTap: () => setState(() {
                                            if (selected) {
                                              _selectedCategories.remove(cat);
                                            } else {
                                              _selectedCategories.add(cat);
                                            }
                                          }),
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 200),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: selected
                                                  ? const Color(0xFF4648d4)
                                                  : Colors.white.withOpacity(0.6),
                                              borderRadius: BorderRadius.circular(30),
                                              border: Border.all(
                                                color: selected
                                                    ? const Color(0xFF4648d4)
                                                    : const Color(0xFFD1D5DB),
                                              ),
                                              boxShadow: selected
                                                  ? [
                                                      BoxShadow(
                                                        color: const Color(0xFF4648d4)
                                                            .withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      )
                                                    ]
                                                  : null,
                                            ),
                                            child: Text(
                                              cat,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                                color: selected
                                                    ? Colors.white
                                                    : const Color(0xFF374151),
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 28),

                              // Submit Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4648d4),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 8,
                                    shadowColor:
                                        const Color(0xFF4648d4).withOpacity(0.4),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.verified_rounded, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Verify & Continue to List',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _inputTextStyle => const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: Color(0xFF1b1b23),
      );

  InputDecoration _inputDec(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontFamily: 'Inter'),
      filled: true,
      fillColor: Colors.white.withOpacity(0.5),
      contentPadding: const EdgeInsets.all(14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4648d4), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4648d4), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4648d4).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'One-Time Seller Setup',
                  style: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Complete your profile to unlock listing & selling on SnapBid.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white70,
                    height: 1.4,
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

class _GlassPanel extends StatelessWidget {
  final Widget child;
  const _GlassPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4648d4)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

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

/// Auto-formats CNIC as user types: XXXXX-XXXXXXX-X
class _CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    String formatted = '';
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) formatted += '-';
      formatted += digits[i];
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
