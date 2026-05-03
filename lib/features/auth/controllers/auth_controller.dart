import 'dart:typed_data';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<models.User?>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<models.User?>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.loading()) {
    checkSession();
  }

  /// Checks if the user is already logged in on startup
  Future<void> checkSession() async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Login with email and password
  Future<void> login(String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.login(email: email, password: password);
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Login failed', st);
      rethrow; // Rethrow so the UI can catch and show a snackbar
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Register a new user
  Future<void> register(String name, String email, String password) async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.register(name: name, email: email, password: password);
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Registration failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Update display name
  Future<void> updateDisplayName(String name) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.updateName(name);
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Update failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update password
  Future<void> updatePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    try {
      state = const AsyncValue.loading();
      final user = await _authRepository.updatePassword(
        newPassword: newPassword,
        oldPassword: oldPassword,
      );
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Password update failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.signInWithGoogle();
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Google login failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      // We don't set loading state for the whole user object here
      // as it's a background process that doesn't change current login status
      await _authRepository.forgotPassword(email);
    } on AppwriteException catch (e, st) {
      rethrow;
    } catch (e, st) {
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String userId,
    required String secret,
    required String password,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.resetPassword(
        userId: userId,
        secret: secret,
        password: password,
      );
      // After reset, we might want to log them in or just go to login screen
      state = const AsyncValue.data(null);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Password reset failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
    } on AppwriteException catch (e, st) {
      rethrow;
    } catch (e, st) {
      rethrow;
    }
  }

  /// Complete email verification
  Future<void> verifyEmail({
    required String userId,
    required String secret,
  }) async {
    try {
      state = const AsyncValue.loading();
      await _authRepository.verifyEmail(userId: userId, secret: secret);
      final user = await _authRepository.getCurrentUser();
      state = AsyncValue.data(user);
    } on AppwriteException catch (e, st) {
      state = AsyncValue.error(e.message ?? 'Verification failed', st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Update profile picture
  Future<void> updateProfilePicture({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final user = state.value;
      if (user == null) return;
      
      state = const AsyncValue.loading();
      final updatedUser = await _authRepository.updateProfilePicture(
        userId: user.$id,
        bytes: bytes,
        fileName: fileName,
      );
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Delete profile picture
  Future<void> deleteProfilePicture() async {
    try {
      state = const AsyncValue.loading();
      final updatedUser = await _authRepository.deleteProfilePicture();
      state = AsyncValue.data(updatedUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Get profile picture URL
  String? getProfilePictureUrl(String? fileId) {
    return _authRepository.getProfilePictureUrl(fileId);
  }
}
