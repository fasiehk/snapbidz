class AuctionModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String imageEmoji;
  final String? imageUrl;
  final List<String> imageUrls;
  final int currentBid;
  final int totalBids;
  final String status;
  final DateTime endTime;
  final String sellerId;
  final String sellerName;

  AuctionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.description,
    required this.imageEmoji,
    this.imageUrl,
    this.imageUrls = const [],
    required this.currentBid,
    required this.totalBids,
    required this.status,
    required this.endTime,
    required this.sellerId,
    required this.sellerName,
  });

  factory AuctionModel.fromMap(Map<String, dynamic> map) {
    return AuctionModel(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      imageEmoji: map['imageEmoji'] ?? '📦',
      imageUrl: map['imageUrl'],
      imageUrls: map['imageUrls'] != null 
          ? List<String>.from(map['imageUrls']) 
          : (map['imageUrl'] != null ? [map['imageUrl']] : []),
      currentBid: map['currentBid']?.toInt() ?? 0,
      totalBids: map['totalBids']?.toInt() ?? 0,
      status: map['status'] ?? 'active',
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : DateTime.now().add(const Duration(days: 7)),
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'description': description,
      'imageEmoji': imageEmoji,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (imageUrls.isNotEmpty) 'imageUrls': imageUrls,
      'currentBid': currentBid,
      'totalBids': totalBids,
      'status': status,
      'endTime': endTime.toIso8601String(),
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }
}
