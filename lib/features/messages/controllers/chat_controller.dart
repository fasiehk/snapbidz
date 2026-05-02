import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message_model.dart';
import '../repositories/chat_repository.dart';

/// Provides real-time stream of messages for a given auctionId
final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageModel>, String>((ref, auctionId) {
  final controller = StreamController<List<ChatMessageModel>>();
  final repo = ref.watch(chatRepositoryProvider);

  // Load initial messages
  repo.getMessages(auctionId).then((msgs) {
    if (!controller.isClosed) controller.add(msgs);
  });

  // Subscribe to realtime updates
  final subscription = repo.subscribeToChat(auctionId);
  subscription.stream.listen((event) async {
    if (event.events.any((e) =>
        e.contains('databases.snapbid_db.collections.messages.documents'))) {
      // Check if this event belongs to our auctionId
      final data = event.payload;
      if (data['auctionId'] == auctionId) {
        // Re-fetch full list to keep ordering correct
        try {
          final msgs = await repo.getMessages(auctionId);
          if (!controller.isClosed) controller.add(msgs);
        } catch (_) {}
      }
    }
  });

  ref.onDispose(() {
    subscription.close();
    controller.close();
  });

  return controller.stream;
});

/// Provides unread message count for the current user
final unreadCountProvider =
    StateNotifierProvider<UnreadCountNotifier, int>((ref) {
  return UnreadCountNotifier(ref.watch(chatRepositoryProvider));
});

class UnreadCountNotifier extends StateNotifier<int> {
  final ChatRepository _repo;
  StreamSubscription? _sub;

  UnreadCountNotifier(this._repo) : super(0);

  void start(String userId) {
    // Initial load
    _repo.getUnreadCount(userId).then((count) {
      if (mounted) state = count;
    });

    // Subscribe to realtime for live badge updates
    final subscription = _repo.subscribeToUnread();
    _sub = subscription.stream.listen((event) {
      if (event.events.any((e) => e.contains('messages.documents'))) {
        _repo.getUnreadCount(userId).then((count) {
          if (mounted) state = count;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
