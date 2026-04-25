import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../models/auction_model.dart';
import '../repositories/auction_repository.dart';
import '../../bids/repositories/bid_repository.dart';
import '../../bids/models/bid_model.dart';

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

final myListingsProvider = FutureProvider.family<List<AuctionModel>, String>((ref, userId) async {
  final repo = ref.watch(auctionRepositoryProvider);
  return repo.getAuctions(queries: [Query.equal('sellerId', userId), Query.orderDesc('\$createdAt')]);
});

final myBiddedAuctionsProvider = FutureProvider.family<List<AuctionModel>, String>((ref, userId) async {
  final bidRepo = ref.watch(bidRepositoryProvider);
  final auctionRepo = ref.watch(auctionRepositoryProvider);
  
  // 1. Fetch all bids by this user
  final bids = await bidRepo.getBids(queries: [Query.equal('bidderId', userId)]);
  
  // 2. Get unique auction IDs
  final auctionIds = bids.map((b) => b.auctionId).toSet().toList();
  
  if (auctionIds.isEmpty) return [];

  // 3. Fetch those auctions
  final auctions = await auctionRepo.getAuctions(queries: [Query.equal('\$id', auctionIds)]);
  return auctions;
});

final auctionBidsProvider = FutureProvider.family<List<BidModel>, String>((ref, auctionId) async {
  final bidRepo = ref.watch(bidRepositoryProvider);
  return bidRepo.getBids(queries: [
    Query.equal('auctionId', auctionId),
    Query.orderDesc('createdAt'),
  ]);
});
