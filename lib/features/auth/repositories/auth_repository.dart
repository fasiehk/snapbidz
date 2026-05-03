import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:typed_data';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final account = ref.watch(appwriteAccountProvider);
  final storage = ref.watch(appwriteStorageProvider);
  final client = ref.watch(appwriteClientProvider);
  return AuthRepository(account, storage, Databases(client));
});

class AuthRepository {
  final Account _account;
  final Storage _storage;
  final Databases _databases;

  AuthRepository(this._account, this._storage, this._databases);

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
    final normalizedEmail = email.toLowerCase().trim();
    
    // 1. Preemptive Check: If already logged in, log out first to be safe
    try {
      final currentUser = await getCurrentUser();
      if (currentUser != null) {
        await logout();
      }
    } catch (_) {}

    try {
      // 2. Primary login attempt
      return await _account.createEmailPasswordSession(
        email: normalizedEmail,
        password: password,
      );
    } on AppwriteException catch (e) {
      // 3. Catch session conflict (409)
      if (e.code == 409 || e.message?.contains('session_already_exists') == true) {
        try {
          await _account.deleteSession(sessionId: 'current');
        } catch (_) {}
        
        return await _account.createEmailPasswordSession(
          email: normalizedEmail,
          password: password,
        );
      }
      rethrow;
    }
  }

  /// Register a new user
  Future<models.User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.toLowerCase().trim();
    // 1. Create the user
    final user = await _account.create(
      userId: ID.unique(),
      email: normalizedEmail,
      password: password,
      name: name,
    );
    
    // 2. Create Profile Document (for existence checks)
    try {
      await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.profilesCollection,
        documentId: user.$id,
        data: {
          'email': normalizedEmail,
          'userId': user.$id,
        },
      );
    } catch (e) {
      print('Profile creation error: $e');
    }

    // 3. Log them in immediately after creation
    await login(email: normalizedEmail, password: password);
    
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

  /// Update user display name
  Future<models.User> updateName(String name) async {
    return await _account.updateName(name: name);
  }

  /// Update user password
  Future<models.User> updatePassword({
    required String newPassword,
    required String oldPassword,
  }) async {
    return await _account.updatePassword(
      password: newPassword,
      oldPassword: oldPassword,
    );
  }

  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
      );
    } on AppwriteException catch (e) {
      final isSessionExists = e.code == 409 || 
          (e.message?.toLowerCase().contains('session already exists') ?? false) ||
          (e.message?.toLowerCase().contains('creation of session is prohibited') ?? false);

      if (isSessionExists) {
        try {
          await _account.deleteSession(sessionId: 'current');
        } catch (_) {}
        
        await _account.createOAuth2Session(
          provider: OAuthProvider.google,
        );
      } else {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Send password recovery email
  Future<void> forgotPassword(String email) async {
    try {
      final normalizedEmail = email.toLowerCase().trim();
      // 1. Manually check if user exists in profiles collection
      final result = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.profilesCollection,
        queries: [Query.equal('email', normalizedEmail)],
      );

      if (result.total == 0) {
        throw 'No account found with this email address.';
      }

      // 2. Request recovery
      await _account.createRecovery(
        email: normalizedEmail,
        url: 'https://snapbid.app/reset-password',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password using secret from email
  Future<void> resetPassword({
    required String userId,
    required String secret,
    required String password,
  }) async {
    await _account.updateRecovery(
      userId: userId,
      secret: secret,
      password: password,
    );
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    await _account.createVerification(
      url: 'https://snapbid.app/verify-email',
    );
  }

  /// Complete email verification
  Future<void> verifyEmail({
    required String userId,
    required String secret,
  }) async {
    await _account.updateVerification(
      userId: userId,
      secret: secret,
    );
  }

  // ─── Profile Picture ───────────────────────────────────────────────────────

  /// Upload and update profile picture
  Future<models.User> updateProfilePicture({
    required String userId,
    required Uint8List bytes,
    required String fileName,
  }) async {
    // 1. Delete old pic if exists
    final user = await _account.get();
    final oldPicId = user.prefs.data['profilePicId'] as String?;
    if (oldPicId != null) {
      try {
        await _storage.deleteFile(
          bucketId: AppConstants.profileAvatarsBucket,
          fileId: oldPicId,
        );
      } catch (_) {}
    }

    // 2. Upload new pic
    final file = await _storage.createFile(
      bucketId: AppConstants.profileAvatarsBucket,
      fileId: ID.unique(),
      file: InputFile.fromBytes(bytes: bytes, filename: fileName),
    );

    // 3. Update user prefs
    final currentPrefs = user.prefs.data;
    currentPrefs['profilePicId'] = file.$id;
    return await _account.updatePrefs(prefs: currentPrefs);
  }

  /// Delete profile picture
  Future<models.User> deleteProfilePicture() async {
    final user = await _account.get();
    final picId = user.prefs.data['profilePicId'] as String?;
    
    if (picId != null) {
      await _storage.deleteFile(
        bucketId: AppConstants.profileAvatarsBucket,
        fileId: picId,
      );
      
      final currentPrefs = user.prefs.data;
      currentPrefs.remove('profilePicId');
      return await _account.updatePrefs(prefs: currentPrefs);
    }
    return user;
  }

  /// Get profile picture URL
  String? getProfilePictureUrl(String? fileId) {
    if (fileId == null) return null;
    return '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.profileAvatarsBucket}/files/$fileId/view?project=${AppConstants.appwriteProjectId}';
  }
}
