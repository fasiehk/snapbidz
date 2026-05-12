import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_breakpoints.dart';
import '../../core/widgets/gradient_background.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'controllers/auth_controller.dart';
import '../../core/utils/snackbar_utils.dart';

/// Login Screen — auto-centers form on desktop, compact on mobile.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    try {
      await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = AppBreakpoints.isDesktop(context);

    final formContent = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppConstants.spaceXL),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: const Icon(Icons.gavel_rounded, color: AppColors.onPrimary, size: 24),
              ),
              const SizedBox(width: AppConstants.spaceMD),
              Text('SnapBid', style: AppTextStyles.headlineSmall),
            ],
          ),
          const SizedBox(height: AppConstants.spaceXXL),
          Text('Welcome back', style: AppTextStyles.headlineLarge),
          const SizedBox(height: AppConstants.spaceSM),
          Text('Sign in to continue bidding', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(height: AppConstants.spaceXL),
          GlassCard(
            child: Column(
              children: [
                AppTextField(
                  label: 'Email Address',
                  hint: 'you@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.outline),
                  validator: (v) => v != null && v.contains('@') ? null : 'Enter a valid email',
                ),
                const SizedBox(height: AppConstants.spaceMD),
                AppTextField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.outline),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v != null && v.length >= 6 ? null : 'Min 6 characters',
                ),
                const SizedBox(height: AppConstants.spaceSM),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty) {
                        try {
                          await ref.read(authControllerProvider.notifier).forgotPassword(_emailController.text.trim());
                          if (mounted) SnackBarUtils.showInfo(context, 'Password reset email sent!');
                        } catch (e) {
                          if (mounted) SnackBarUtils.showError(context, e.toString());
                        }
                      } else {
                        SnackBarUtils.showError(context, 'Please enter your email first.');
                      }
                    },
                    child: Text('Forgot Password?', style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: AppConstants.spaceMD),
                PrimaryButton(
                  label: 'Sign In',
                  isLoading: ref.watch(authControllerProvider).isLoading,
                  onPressed: _handleLogin,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLG),
          Row(children: [
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              child: Text('or', style: AppTextStyles.labelSmall),
            ),
            const Expanded(child: Divider(color: AppColors.outlineVariant)),
          ]),
          const SizedBox(height: AppConstants.spaceLG),
          SecondaryButton(
            label: 'Continue with Google',
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).signInWithGoogle();
                if (mounted) context.go('/home');
              } catch (e) {
                if (mounted) SnackBarUtils.showError(context, e.toString());
              }
            },
          ),
          const SizedBox(height: AppConstants.spaceXL),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ", style: AppTextStyles.bodySmall),
              GestureDetector(
                onTap: () => context.go('/signup'),
                child: Text('Create Account', style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: isDesktop
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG, vertical: 32),
                    child: formContent,
                  ),
                ),
              )
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppConstants.spaceLG),
                  child: formContent,
                ),
              ),
      ),
    );
  }
}
