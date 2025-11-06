import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  String? _passwordMatchError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  void _validatePassword() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
    });
    _checkPasswordMatch();
  }

  void _checkPasswordMatch() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (confirmPassword.isNotEmpty && password != confirmPassword) {
      setState(() {
        _passwordMatchError = 'Passwords do not match';
      });
    } else {
      setState(() {
        _passwordMatchError = null;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUpPressed() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final email = _emailController.text.trim(); // your existing controller
      final password = _passwordController.text.trim(); // your existing controller

      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('Signed up uid=${cred.user?.uid}, email=${cred.user?.email}');

      if (!mounted) return;
      // Redirect to Home and clear back stack
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String msg = 'Sign up failed';
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This email is already in use.';
          break;
        case 'invalid-email':
          msg = 'Please enter a valid email.';
          break;
        case 'weak-password':
          msg = 'Password is too weak.';
          break;
        case 'operation-not-allowed':
          msg = 'Email/Password sign-in is disabled in Firebase Console.';
          break;
        default:
          msg = 'Auth error: ${e.code}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unexpected error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D5A80),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Text(
                      'Create Your SnapBid Account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE0FBFC),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start bidding in seconds.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF98C1D9),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Email Field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email address',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Create a password',
                      icon: _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      obscureText: _obscurePassword,
                      isPassword: true,
                      onVisibilityToggle: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Confirm Password Field
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      icon: _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      obscureText: _obscureConfirmPassword,
                      isPassword: true,
                      errorText: _passwordMatchError,
                      onVisibilityToggle: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password Requirements
                    Column(
                      children: [
                        _buildPasswordRequirement('8+ characters', _hasMinLength),
                        const SizedBox(height: 12),
                        _buildPasswordRequirement('1 uppercase letter', _hasUppercase),
                        const SizedBox(height: 12),
                        _buildPasswordRequirement('1 number', _hasNumber),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _onSignUpPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEE6C4D),
                          foregroundColor: const Color(0xFF293241),
                          elevation: 4,
                          shadowColor: const Color(0xFFEE6C4D).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF98C1D9).withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or sign up with',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF98C1D9),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFF98C1D9).withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Social Login Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildSocialButton('Google', Icons.email),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSocialButton('Apple', Icons.apple),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF98C1D9),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE0FBFC),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool isPassword = false,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onVisibilityToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF98C1D9),
            ),
          ),
        ),
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null 
                  ? Colors.red 
                  : const Color(0xFF98C1D9).withOpacity(0.5),
              width: errorText != null ? 2 : 1,
            ),
            color: const Color(0xFF293241).withOpacity(0.8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: const TextStyle(
                    color: Color(0xFFE0FBFC),
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Color(0xFF98C1D9),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: isPassword
                    ? GestureDetector(
                        onTap: onVisibilityToggle,
                        child: Icon(
                          icon,
                          color: const Color(0xFF98C1D9),
                          size: 24,
                        ),
                      )
                    : Icon(
                        icon,
                        color: const Color(0xFF98C1D9),
                        size: 24,
                      ),
              ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String text, bool isMet) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isMet ? const Color(0xFFEE6C4D) : Colors.transparent,
            border: Border.all(
              color: isMet ? const Color(0xFFEE6C4D) : const Color(0xFF98C1D9),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: isMet
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: Color(0xFF293241),
                )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF98C1D9),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton(String label, IconData icon) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: () {
          // Handle social login
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF3D5A80), // Match with background
          side: BorderSide(
            color: const Color(0xFF98C1D9).withOpacity(0.5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0xFFE0FBFC)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE0FBFC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
