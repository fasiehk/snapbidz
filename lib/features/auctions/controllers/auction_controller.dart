import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../models/auction_model.dart';
import '../repositories/auction_repository.dart';
import '../../bids/repositories/bid_repository.dart';
import '../../bids/models/bid_model.dart';
import '../../auth/controllers/auth_controller.dart';

final trendingAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final auctions = await repo.getAuctions(queries: [Query.limit(15), Query.orderDesc('totalBids')]);
  if (user != null) {
    return auctions.where((a) => a.sellerId != user.$id).take(5).toList();
  }
  return auctions.take(5).toList();
});

final recentAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final auctions = await repo.getAuctions(queries: [Query.limit(15), Query.orderDesc('\$createdAt')]);
  if (user != null) {
    return auctions.where((a) => a.sellerId != user.$id).take(5).toList();
  }
  return auctions.take(5).toList();
});

final allAuctionsProvider = FutureProvider<List<AuctionModel>>((ref) async {
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;
  final auctions = await repo.getAuctions();
  if (user != null) {
    return auctions.where((a) => a.sellerId != user.$id).toList();
  }
  return auctions;
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

final profileStatsProvider = FutureProvider.family<Map<String, String>, String>((ref, userId) async {
  final listings = await ref.watch(myListingsProvider(userId).future);
  final biddedAuctions = await ref.watch(myBiddedAuctionsProvider(userId).future);

  final listedCount = listings.length;
  final bidsCount = biddedAuctions.length;
  
  double totalVolume = 0;
  for (var auction in listings) {
    totalVolume += auction.currentBid;
  }

  String formattedVolume = '\$0';
  if (totalVolume >= 1000000) {
    formattedVolume = '\$${(totalVolume / 1000000).toStringAsFixed(1)}M';
  } else if (totalVolume >= 1000) {
    formattedVolume = '\$${(totalVolume / 1000).toStringAsFixed(1)}k';
  } else {
    formattedVolume = '\$${totalVolume.toInt()}';
  }

  return {
    'listed': listedCount.toString(),
    'bids': bidsCount.toString(),
    'volume': formattedVolume,
    'rating': '4.9★',
  };
});
