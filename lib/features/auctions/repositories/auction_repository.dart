import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../models/auction_model.dart';

final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  return AuctionRepository(
    ref.watch(appwriteDatabaseProvider),
    ref.watch(appwriteStorageProvider),
    ref.watch(appwriteRealtimeProvider),
  );
});

class AuctionRepository {
  final Databases _databases;
  final Storage _storage;
  final Realtime _realtime;

  AuctionRepository(this._databases, this._storage, this._realtime);

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

  Future<AuctionModel> updateAuction(String id, Map<String, dynamic> data) async {
    try {
      final doc = await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        documentId: id,
        data: data,
      );
      return AuctionModel.fromMap(doc.data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAuction(String id) async {
    try {
      await _databases.updateDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.auctionsCollection,
        documentId: id,
        data: {'status': 'deleted'},
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<String> uploadImage(List<int> bytes, String filename) async {
    try {
      final file = await _storage.createFile(
        bucketId: AppConstants.auctionImagesBucket,
        fileId: ID.unique(),
        file: InputFile.fromBytes(bytes: bytes, filename: filename),
      );
      return '${AppConstants.appwriteEndpoint}/storage/buckets/${AppConstants.auctionImagesBucket}/files/${file.$id}/view?project=${AppConstants.appwriteProjectId}';
    } catch (e) {
      rethrow;
    }
  }

  RealtimeSubscription subscribeToAuctions() {
    return _realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.auctionsCollection}.documents',
    ]);
  }
}
