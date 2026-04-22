import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/appwrite_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(appwriteAccountProvider));
});

class AuthRepository {
  final Account _account;

  AuthRepository(this._account);

  /// Get currently logged in user. Returns null if not logged in.
  Future<models.User?> getCurrentUser() async {
    try {
      return await _account.get();
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        return null; // Not logged in
      }
      rethrow;
    } catch (_) {
      return null;
    }
  }

  /// Login with email and password
  Future<models.Session> login({
    required String email,
    required String password,
  }) async {
    return await _account.createEmailPasswordSession(
      email: email,
      password: password,
    );
  }

  /// Register a new user
  Future<models.User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // 1. Create the user
    final user = await _account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: name,
    );
    
    // 2. Log them in immediately after creation
    await login(email: email, password: password);
    
    return user;
  }

  /// Logout the current user
  Future<void> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (_) {
      // Ignore errors if session is already gone
    }
  }
}
