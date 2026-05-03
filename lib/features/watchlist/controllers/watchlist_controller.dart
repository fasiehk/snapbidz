import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/watchlist_repository.dart';
import '../../auctions/models/auction_model.dart';
import '../../auth/controllers/auth_controller.dart';

final watchlistProvider = StreamProvider<List<AuctionModel>>((ref) async* {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) {
    yield [];
    return;
  }

  final repo = ref.watch(watchlistRepositoryProvider);
  
  // Initial fetch
  yield await repo.getWatchlist(user.$id);
  
  // We could add a RefreshIndicator or periodic polling if real-time is not critical for watchlist
  // Or just rely on manual refreshes for now.
});

final isWatchingProvider = FutureProvider.family<bool, String>((ref, auctionId) async {
  final user = ref.watch(authControllerProvider).value;
  if (user == null) return false;
  
  return ref.read(watchlistRepositoryProvider).isWatching(user.$id, auctionId);
});
