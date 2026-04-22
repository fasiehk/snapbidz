import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../models/auction_model.dart';
import '../repositories/auction_repository.dart';

final trendingAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  return repo.getAuctions(queries: [Query.limit(5), Query.orderDesc('totalBids')]);
});

final recentAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  return repo.getAuctions(queries: [Query.limit(5), Query.orderDesc('\$createdAt')]);
});

final allAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  return repo.getAuctions();
});

final auctionDetailProvider = FutureProvider.family<AuctionModel, String>((ref, id) async {
  final repo = ref.watch(auctionRepositoryProvider);
  return repo.getAuctionById(id);
});
