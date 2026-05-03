import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../models/bid_model.dart';

final bidRepositoryProvider = Provider<BidRepository>((ref) {
  return BidRepository(
    ref.watch(appwriteDatabaseProvider),
    ref.watch(appwriteRealtimeProvider),
  );
});

class BidRepository {
  final Databases _databases;
  final Realtime _realtime;

  BidRepository(this._databases, this._realtime);

  Future<List<BidModel>> getBids({List<String>? queries}) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.bidsCollection,
        queries: queries,
      );

      return response.documents
          .map((doc) => BidModel.fromMap(doc.data))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<BidModel> placeBid(BidModel bid) async {
    try {
      final doc = await _databases.createDocument(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.bidsCollection,
        documentId: ID.unique(),
        data: bid.toMap(),
      );
      return BidModel.fromMap(doc.data);
    } catch (e) {
      rethrow;
    }
  }

  RealtimeSubscription subscribeToBids() {
    return _realtime.subscribe([
      'databases.${AppConstants.databaseId}.collections.${AppConstants.bidsCollection}.documents',
    ]);
  }
}
