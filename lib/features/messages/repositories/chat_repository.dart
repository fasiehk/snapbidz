import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../models/chat_message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(appwriteDatabaseProvider),
    ref.watch(appwriteRealtimeProvider),
  );
});

const String _dbId = 'snapbid_db';
const String _colId = 'messages';

class ChatRepository {
  final Databases _db;
  final Realtime _realtime;

  ChatRepository(this._db, this._realtime);

  /// Send a message in an auction chat thread
  Future<ChatMessageModel> sendMessage({
    required String auctionId,
    required String auctionTitle,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String receiverName,
    required String text,
    String? auctionImage,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final doc = await _db.createDocument(
      databaseId: _dbId,
      collectionId: _colId,
      documentId: ID.unique(),
      data: {
        'auctionId': auctionId,
        'auctionTitle': auctionTitle,
        'auctionImage': auctionImage,
        'senderId': senderId,
        'senderName': senderName,
        'receiverId': receiverId,
        'receiverName': receiverName,
        'text': text,
        'isRead': false,
        'createdAt': now,
      },
    );
    final map = Map<String, dynamic>.from(doc.data);
    map['\$id'] = doc.$id;
    return ChatMessageModel.fromMap(map);
  }

  /// Fetch all messages for a given auction thread (paginated, oldest first)
  Future<List<ChatMessageModel>> getMessages(String auctionId) async {
    final result = await _db.listDocuments(
      databaseId: _dbId,
      collectionId: _colId,
      queries: [
        Query.equal('auctionId', auctionId),
        Query.orderAsc('\$createdAt'),
        Query.limit(100),
      ],
    );
    return result.documents.map((d) {
      final map = Map<String, dynamic>.from(d.data);
      map['\$id'] = d.$id;
      return ChatMessageModel.fromMap(map);
    }).toList();
  }

  /// Returns a Realtime subscription stream for a specific auction chat
  RealtimeSubscription subscribeToChat(String auctionId) {
    return _realtime.subscribe([
      'databases.$_dbId.collections.$_colId.documents',
    ]);
  }

  /// Mark a message as read
  Future<void> markAsRead(String messageId) async {
    try {
      await _db.updateDocument(
        databaseId: _dbId,
        collectionId: _colId,
        documentId: messageId,
        data: {'isRead': true},
      );
    } catch (_) {}
  }

  /// Get distinct conversation threads for a user (most recent first)
  Future<List<Map<String, dynamic>>> getConversationThreads(String userId) async {
    // Get messages where user is sender or receiver
    final sent = await _db.listDocuments(
      databaseId: _dbId,
      collectionId: _colId,
      queries: [
        Query.equal('senderId', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(200),
      ],
    );
    final received = await _db.listDocuments(
      databaseId: _dbId,
      collectionId: _colId,
      queries: [
        Query.equal('receiverId', userId),
        Query.orderDesc('\$createdAt'),
        Query.limit(200),
      ],
    );

    final allDocs = [...sent.documents, ...received.documents];
    // Deduplicate by thread (auctionId + otherUserId) – keep latest message per thread
    final Map<String, Map<String, dynamic>> threads = {};
    for (final doc in allDocs) {
      final aId = doc.data['auctionId'] as String;
      final senderId = doc.data['senderId'] as String;
      final receiverId = doc.data['receiverId'] as String;
      final otherId = senderId == userId ? receiverId : senderId;
      final threadKey = '${aId}_$otherId';
      
      if (!threads.containsKey(threadKey)) {
        final map = Map<String, dynamic>.from(doc.data);
        map['\$id'] = doc.$id;
        threads[threadKey] = map;
      }
    }
    // Sort by createdAt descending
    final sorted = threads.values.toList()
      ..sort((a, b) {
        final aTime = a['createdAt'] ?? a['\$createdAt'] ?? '';
        final bTime = b['createdAt'] ?? b['\$createdAt'] ?? '';
        return bTime.compareTo(aTime);
      });
    return sorted;
  }

  /// Get unread count for a specific user
  Future<int> getUnreadCount(String userId) async {
    try {
      final result = await _db.listDocuments(
        databaseId: _dbId,
        collectionId: _colId,
        queries: [
          Query.equal('receiverId', userId),
          Query.equal('isRead', false),
          Query.limit(100),
        ],
      );
      return result.total;
    } catch (_) {
      return 0;
    }
  }

  /// Subscribe to unread messages (for badge notifications)
  RealtimeSubscription subscribeToUnread() {
    return _realtime.subscribe([
      'databases.$_dbId.collections.$_colId.documents',
    ]);
  }
}
