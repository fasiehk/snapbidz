import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';
import '../auth/controllers/auth_controller.dart';
import '../../core/utils/snackbar_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
        SnackBarUtils.showSuccess(context, 'Profile updated successfully!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendVerification() async {
    try {
      await ref.read(authControllerProvider.notifier).sendEmailVerification();
      if (mounted) {
        SnackBarUtils.showInfo(context, 'Verification email sent! Please check your inbox.');
      }
    } catch (e) {
      if (mounted) {
        SnackBarUtils.showError(context, e.toString());
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await image.readAsBytes();
        await ref.read(authControllerProvider.notifier).updateProfilePicture(
          bytes: bytes,
          fileName: image.name,
        );
        if (mounted) SnackBarUtils.showSuccess(context, 'Profile picture updated!');
      } catch (e) {
        if (mounted) SnackBarUtils.showError(context, e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).deleteProfilePicture();
      if (mounted) SnackBarUtils.showSuccess(context, 'Profile picture removed!');
    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, e.toString());
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
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
                      child: ClipOval(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final user = ref.watch(authControllerProvider).value;
                            final picId = user?.prefs.data['profilePicId'] as String?;
                            final imageUrl = ref.read(authControllerProvider.notifier).getProfilePictureUrl(picId);
                            
                            if (imageUrl != null) {
                              return CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                errorWidget: (context, url, error) => const Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                              );
                            }
                            return const Center(
                              child: Icon(Icons.person_rounded, size: 50, color: AppColors.primary),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  // Delete option if image exists
                  Consumer(
                    builder: (context, ref, _) {
                      final user = ref.watch(authControllerProvider).value;
                      if (user?.prefs.data['profilePicId'] != null) {
                        return Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _deleteImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
            const SizedBox(height: AppConstants.spaceSM),
            
            // Email Verification Status
            Consumer(
              builder: (context, ref, _) {
                final user = ref.watch(authControllerProvider).value;
                final isVerified = user?.emailVerification ?? false;
                
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: (isVerified ? Colors.green : Colors.orange).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isVerified ? Icons.verified_rounded : Icons.warning_amber_rounded,
                        size: 18,
                        color: isVerified ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: AppConstants.spaceSM),
                      Text(
                        isVerified ? 'Email Verified' : 'Email Not Verified',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isVerified ? Colors.green : Colors.orange,
                        ),
                      ),
                      const Spacer(),
                      if (!isVerified)
                        TextButton(
                          onPressed: _sendVerification,
                          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          child: const Text('Verify Now'),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spaceXL),

            // ── Security ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security', style: AppTextStyles.titleMedium),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final email = _emailController.text.trim();
                        if (email.isNotEmpty) {
                          try {
                            await ref.read(authControllerProvider.notifier).forgotPassword(email);
                            if (mounted) SnackBarUtils.showInfo(context, 'Password reset email sent!');
                          } catch (e) {
                            if (mounted) SnackBarUtils.showError(context, e.toString());
                          }
                        }
                      },
                      child: const Text('Forgot Password?'),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _showPasswordFields = !_showPasswordFields),
                      child: Text(_showPasswordFields ? 'Cancel' : 'Change Password'),
                    ),
                  ],
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
