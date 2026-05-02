import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../models/user_profile_model.dart';

final sellerVerificationRepositoryProvider =
    Provider<SellerVerificationRepository>((ref) {
  return SellerVerificationRepository(ref.watch(appwriteDatabaseProvider));
});

const String _dbId = 'snapbid_db';
const String _colId = 'user_profiles';

class SellerVerificationRepository {
  final Databases _db;

  SellerVerificationRepository(this._db);

  /// Check if a user profile already exists for the given userId
  Future<UserProfileModel?> getProfile(String userId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: _colId,
        queries: [Query.equal('userId', userId), Query.limit(1)],
      );
      if (result.documents.isEmpty) return null;
      final doc = result.documents.first;
      final map = Map<String, dynamic>.from(doc.data);
      map['\$id'] = doc.$id;
      return UserProfileModel.fromMap(map);
    } on AppwriteException catch (e) {
      if (e.code == 404) return null;
      rethrow;
    }
  }

  /// Check if a user profile already exists with the given CNIC
  Future<bool> checkCnicExists(String cnic) async {
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: _colId,
        queries: [Query.equal('cnic', cnic), Query.limit(1)],
      );
      return result.documents.isNotEmpty;
    } on AppwriteException catch (e) {
      if (e.code == 404) return false;
      rethrow;
    }
  }

  /// Create a new seller profile
  Future<UserProfileModel> createProfile(UserProfileModel profile) async {
    final doc = await _db.createDocument(
      databaseId: _dbId,
      collectionId: _colId,
      documentId: ID.unique(),
      data: profile.toMap(),
    );
    final map = Map<String, dynamic>.from(doc.data);
    map['\$id'] = doc.$id;
    return UserProfileModel.fromMap(map);
  }
}
