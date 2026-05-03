import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/controllers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _oldPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  
  bool _isLoading = false;
  bool _showPasswordFields = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).value;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      // 1. Update Name if changed
      if (_nameController.text.trim() != user.name) {
        await ref.read(authControllerProvider.notifier).updateDisplayName(_nameController.text.trim());
      }

      // 2. Update Password if requested
      if (_showPasswordFields && _newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw 'Passwords do not match';
        }
        if (_oldPasswordController.text.isEmpty) {
          throw 'Current password is required to set a new one';
        }
        
        await ref.read(authControllerProvider.notifier).updatePassword(
          newPassword: _newPasswordController.text,
          oldPassword: _oldPasswordController.text,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.secondary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTextStyles.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spaceLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile Photo ─────────────────────────────────────────────
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // ── Basic Info ────────────────────────────────────────────────
            Text('Basic Information', style: AppTextStyles.titleMedium),
            const SizedBox(height: AppConstants.spaceMD),
            
            _buildTextField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: AppConstants.spaceMD),
            
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email_outlined,
              enabled: false, // Appwrite email update requires verification flow
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // ── Security ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security', style: AppTextStyles.titleMedium),
                TextButton(
                  onPressed: () => setState(() => _showPasswordFields = !_showPasswordFields),
                  child: Text(_showPasswordFields ? 'Cancel' : 'Change Password'),
                ),
              ],
            ),
            
            if (_showPasswordFields) ...[
              const SizedBox(height: AppConstants.spaceMD),
              _buildTextField(
                controller: _oldPasswordController,
                label: 'Current Password',
                icon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: AppConstants.spaceMD),
              _buildTextField(
                controller: _newPasswordController,
                label: 'New Password',
                icon: Icons.lock_reset_rounded,
                isPassword: true,
              ),
              const SizedBox(height: AppConstants.spaceMD),
              _buildTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                icon: Icons.lock_clock_outlined,
                isPassword: true,
              ),
            ],
            
            const SizedBox(height: AppConstants.spaceXXL),

            // ── Save Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLG)),
                  elevation: 0,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    bool isPassword = false,
  }) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: isPassword,
        style: AppTextStyles.bodyMedium.copyWith(
          color: enabled ? AppColors.onSurface : AppColors.onSurfaceVariant,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.outline),
          prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
        ),
      ),
    );
  }
}
