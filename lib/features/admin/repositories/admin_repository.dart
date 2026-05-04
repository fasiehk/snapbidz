import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/appwrite_providers.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.watch(appwriteDatabaseProvider));
});

class AdminRepository {
  final Databases _databases;

  AdminRepository(this._databases);

  /// Fetch global statistics for the dashboard
  Future<Map<String, dynamic>> getStats() async {
    try {
      final users = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.profilesCollection,
        queries: [Query.limit(1)],
      );

      final auctions = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        queries: [Query.limit(1), Query.notEqual('status', 'deleted')],
      );

      final bids = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.bidsCollection,
        queries: [Query.limit(1)],
      );

      return {
        'totalUsers': users.total,
        'activeAuctions': auctions.total,
        'totalBids': bids.total,
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Toggle user verification status
  Future<void> toggleUserVerification(String userId, bool isVerified) async {
    await _databases.updateDocument(
      databaseId: AppConstants.databaseId,
      collectionId: AppConstants.profilesCollection,
      documentId: userId,
      data: {'isVerified': isVerified},
    );
  }

  /// Block/Suspend user
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    await _databases.updateDocument(
      databaseId: AppConstants.databaseId,
      collectionId: AppConstants.profilesCollection,
      documentId: userId,
      data: {'isActive': isActive},
    );
  }

  /// Delete auction (admin override)
  Future<void> deleteAuction(String auctionId) async {
    await _databases.updateDocument(
      databaseId: AppConstants.databaseId,
      collectionId: AppConstants.auctionsCollection,
      documentId: auctionId,
      data: {'status': 'deleted'},
    );
  }
}
