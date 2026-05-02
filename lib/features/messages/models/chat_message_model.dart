class ChatMessageModel {
  final String id;
  final String auctionId;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String text;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.auctionId,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.text,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      id: map['\$id'] ?? '',
      auctionId: map['auctionId'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      text: map['text'] ?? '',
      isRead: map['isRead'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : (map['\$createdAt'] != null
              ? DateTime.tryParse(map['\$createdAt']) ?? DateTime.now()
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auctionId': auctionId,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'text': text,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// Represents a conversation thread (used by MessagesScreen)
class ConversationModel {
  final String auctionId;
  final String auctionTitle;
  final String otherUserId;
  final String otherUserName;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ConversationModel({
    required this.auctionId,
    required this.auctionTitle,
    required this.otherUserId,
    required this.otherUserName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });
}
