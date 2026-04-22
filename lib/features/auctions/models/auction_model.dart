class AuctionModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String description;
  final String imageEmoji;
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
      'currentBid': currentBid,
      'totalBids': totalBids,
      'status': status,
      'endTime': endTime.toIso8601String(),
      'sellerId': sellerId,
      'sellerName': sellerName,
    };
  }
}
