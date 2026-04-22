import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
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
}
