class BidModel {
  final String id;
  final String auctionId;
  final String bidderId;
  final String bidderName;
  final int amount;
  final DateTime timestamp;

  BidModel({
    required this.id,
    required this.auctionId,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.timestamp,
  });

  factory BidModel.fromMap(Map<String, dynamic> map) {
    return BidModel(
      id: map['\$id'] ?? '',
      auctionId: map['auctionId'] ?? '',
      bidderId: map['bidderId'] ?? '',
      bidderName: map['bidderName'] ?? '',
      amount: map['amount']?.toInt() ?? 0,
      timestamp: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'auctionId': auctionId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'createdAt': timestamp.toIso8601String(),
    };
  }
}
