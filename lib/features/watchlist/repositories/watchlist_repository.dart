import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../auctions/models/auction_model.dart';
import '../../auctions/repositories/auction_repository.dart';

final watchlistRepositoryProvider = Provider<WatchlistRepository>((ref) {
  return WatchlistRepository(
    ref.watch(appwriteDatabaseProvider),
    ref.watch(auctionRepositoryProvider),
  );
});

class WatchlistRepository {
  final Databases _db;
  final AuctionRepository _auctionRepo;

  WatchlistRepository(this._db, this._auctionRepo);

  /// Toggle watchlist status for an auction
  Future<bool> toggleWatchlist({
    required String userId,
    required String auctionId,
    required bool isCurrentlyWatching,
  }) async {
    try {
      if (isCurrentlyWatching) {
        // Remove from watchlist
        final result = await _db.listDocuments(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.watchlistCollection,
          queries: [
            Query.equal('userId', userId),
            Query.equal('auctionId', auctionId),
          ],
        );
        
        if (result.documents.isNotEmpty) {
          await _db.deleteDocument(
            databaseId: AppConstants.databaseId,
            collectionId: AppConstants.watchlistCollection,
            documentId: result.documents.first.$id,
          );
        }
        return false;
      } else {
        // Add to watchlist
        await _db.createDocument(
          databaseId: AppConstants.databaseId,
          collectionId: AppConstants.watchlistCollection,
          documentId: ID.unique(),
          data: {
            'userId': userId,
            'auctionId': auctionId,
          },
        );
        return true;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Check if an auction is in user's watchlist
  Future<bool> isWatching(String userId, String auctionId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.watchlistCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('auctionId', auctionId),
        ],
      );
      return result.documents.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Get all auctions in user's watchlist
  Future<List<AuctionModel>> getWatchlist(String userId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.watchlistCollection,
        queries: [
          Query.equal('userId', userId),
        ],
      );

      if (result.documents.isEmpty) return [];

      final auctionIds = result.documents.map((d) => d.data['auctionId'] as String).toList();
      
      // Fetch auction details for these IDs
      // Note: Appwrite listDocuments with Query.equal('$id', list) has limits, but for watchlist it should be fine
      final auctions = await _auctionRepo.getAuctions(
        queries: [Query.equal('\$id', auctionIds)],
      );
      
      return auctions;
    } catch (e) {
      return [];
    }
  }
}
