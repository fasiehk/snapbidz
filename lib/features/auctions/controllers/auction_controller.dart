import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appwrite/appwrite.dart';
import '../models/auction_model.dart';
import '../repositories/auction_repository.dart';
import '../../bids/repositories/bid_repository.dart';
import '../../bids/models/bid_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/constants/app_constants.dart';

final trendingAuctionsProvider = StreamProvider<List<AuctionModel>>((ref) {
  final controller = StreamController<List<AuctionModel>>();
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;

  Future<void> fetch() async {
    try {
      final auctions = await repo.getAuctions(queries: [Query.limit(15), Query.orderDesc('totalBids')]);
      final filtered = user != null ? auctions.where((a) => a.sellerId != user.$id).take(5).toList() : auctions.take(5).toList();
      if (!controller.isClosed) controller.add(filtered);
    } catch (_) {}
  }

  fetch();

  final sub = repo.subscribeToAuctions();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.auctionsCollection}.documents'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

final recentAuctionsProvider = StreamProvider<List<AuctionModel>>((ref) {
  final controller = StreamController<List<AuctionModel>>();
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;

  Future<void> fetch() async {
    try {
      final auctions = await repo.getAuctions(queries: [Query.limit(15), Query.orderDesc('\$createdAt')]);
      final filtered = user != null ? auctions.where((a) => a.sellerId != user.$id).take(5).toList() : auctions.take(5).toList();
      if (!controller.isClosed) controller.add(filtered);
    } catch (_) {}
  }

  fetch();

  final sub = repo.subscribeToAuctions();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.auctionsCollection}.documents'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

final allAuctionsProvider = StreamProvider<List<AuctionModel>>((ref) {
  final controller = StreamController<List<AuctionModel>>();
  final repo = ref.watch(auctionRepositoryProvider);
  final user = ref.watch(authControllerProvider).value;

  Future<void> fetch() async {
    try {
      final auctions = await repo.getAuctions();
      final filtered = user != null ? auctions.where((a) => a.sellerId != user.$id).toList() : auctions;
      if (!controller.isClosed) controller.add(filtered);
    } catch (_) {}
  }

  fetch();

  final sub = repo.subscribeToAuctions();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.auctionsCollection}.documents'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

final auctionDetailProvider = StreamProvider.family<AuctionModel, String>((ref, id) {
  final controller = StreamController<AuctionModel>();
  final repo = ref.watch(auctionRepositoryProvider);

  Future<void> fetch() async {
    try {
      final auction = await repo.getAuctionById(id);
      if (!controller.isClosed) controller.add(auction);
    } catch (_) {}
  }

  fetch();

  final sub = repo.subscribeToAuctions();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('documents.$id'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

final myListingsProvider = StreamProvider.family<List<AuctionModel>, String>((ref, userId) {
  final controller = StreamController<List<AuctionModel>>();
  final repo = ref.watch(auctionRepositoryProvider);

  Future<void> fetch() async {
    try {
      final auctions = await repo.getAuctions(queries: [Query.equal('sellerId', userId), Query.orderDesc('\$createdAt')]);
      if (!controller.isClosed) controller.add(auctions);
    } catch (_) {}
  }

  fetch();

  final sub = repo.subscribeToAuctions();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.auctionsCollection}.documents'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
});

final myBiddedAuctionsProvider = StreamProvider.family<List<AuctionModel>, String>((ref, userId) {
  final controller = StreamController<List<AuctionModel>>();
  final bidRepo = ref.watch(bidRepositoryProvider);
  final auctionRepo = ref.watch(auctionRepositoryProvider);

  Future<void> fetch() async {
    try {
      final bids = await bidRepo.getBids(queries: [Query.equal('bidderId', userId)]);
      final auctionIds = bids.map((b) => b.auctionId).toSet().toList();
      if (auctionIds.isEmpty) {
        if (!controller.isClosed) controller.add([]);
        return;
      }
      final auctions = await auctionRepo.getAuctions(queries: [Query.equal('\$id', auctionIds)]);
      if (!controller.isClosed) controller.add(auctions);
    } catch (_) {}
  }

  fetch();

  final subBids = bidRepo.subscribeToBids();
  subBids.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.bidsCollection}.documents'))) {
      fetch();
    }
  });
  
  final subAuctions = auctionRepo.subscribeToAuctions();
  subAuctions.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.auctionsCollection}.documents'))) {
      fetch();
    }
  });

  ref.onDispose(() {
    subBids.close();
    subAuctions.close();
    controller.close();
  });

  return controller.stream;
});

final auctionBidsProvider = StreamProvider.family<List<BidModel>, String>((ref, auctionId) {
  final controller = StreamController<List<BidModel>>();
  final bidRepo = ref.watch(bidRepositoryProvider);

  Future<void> fetch() async {
    try {
      final bids = await bidRepo.getBids(queries: [
        Query.equal('auctionId', auctionId),
        Query.orderDesc('createdAt'),
      ]);
      if (!controller.isClosed) controller.add(bids);
    } catch (_) {}
  }

  fetch();

  final sub = bidRepo.subscribeToBids();
  sub.stream.listen((event) {
    if (event.events.any((e) => e.contains('collections.${AppConstants.bidsCollection}.documents'))) {
      final payload = event.payload;
      if (payload['auctionId'] == auctionId || !event.events.any((e) => e.contains('create'))) {
        fetch();
      }
    }
  });

  ref.onDispose(() {
    sub.close();
    controller.close();
  });

  return controller.stream;
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

  String formattedVolume = 'PKR 0';
  if (totalVolume >= 1000000) {
    formattedVolume = 'PKR ${(totalVolume / 1000000).toStringAsFixed(1)}M';
  } else if (totalVolume >= 1000) {
    formattedVolume = 'PKR ${(totalVolume / 1000).toStringAsFixed(1)}k';
  } else {
    formattedVolume = 'PKR ${totalVolume.toInt()}';
  }

  return {
    'listed': listedCount.toString(),
    'bids': bidsCount.toString(),
    'volume': formattedVolume,
    'rating': '4.9★',
  };
});
