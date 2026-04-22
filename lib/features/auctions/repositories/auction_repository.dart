import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../models/auction_model.dart';

final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  return AuctionRepository(ref.watch(appwriteDatabaseProvider));
});

class AuctionRepository {
  final Databases _databases;

  AuctionRepository(this._databases);

  Future<List<AuctionModel>> getAuctions({List<String>? queries}) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        queries: queries,
      );

      return response.documents
          .map((doc) => AuctionModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AuctionModel> getAuctionById(String id) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        documentId: id,
      );
      return AuctionModel.fromMap(doc.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<AuctionModel> createAuction(AuctionModel auction) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        documentId: ID.unique(),
        data: auction.toMap(),
      );
      return AuctionModel.fromMap(doc.data);
    } catch (e) {
      rethrow;
    }
  }
}
