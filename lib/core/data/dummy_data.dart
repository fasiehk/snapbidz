/// Centralised dummy data — matches exact content from Google Stitch designs.
/// Swap these out when Appwrite backend is connected.
library;

class DummyAuction {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String currentBid;
  final String timeLeft;
  final int totalBids;
  final String imageEmoji;
  final bool isWatched;
  final String status; // 'active' | 'won' | 'lost'

  const DummyAuction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.currentBid,
    required this.timeLeft,
    required this.totalBids,
    required this.imageEmoji,
    this.isWatched = false,
    this.status = 'active',
  });
}

class DummyMessage {
  final String id;
  final String name;
  final String avatar;
  final String preview;
  final String time;
  final int unread;

  const DummyMessage({
    required this.id,
    required this.name,
    required this.avatar,
    required this.preview,
    required this.time,
    this.unread = 0,
  });
}

class DummyBid {
  final String bidder;
  final String amount;
  final String time;

  const DummyBid({
    required this.bidder,
    required this.amount,
    required this.time,
  });
}

abstract class AppDummyData {
  // ── Trending Auctions (Home) ───────────────────────────────────────────────
  static const List<DummyAuction> trending = [
    DummyAuction(
      id: '1',
      title: 'Patek Philippe Nautilus 5711',
      subtitle: 'Ref. 5711/1A-010 Blue Dial',
      category: 'Timepieces',
      currentBid: '\$142,000',
      timeLeft: '2h 14m',
      totalBids: 34,
      imageEmoji: '⌚',
      isWatched: true,
    ),
    DummyAuction(
      id: '2',
      title: 'Rare Nike Mag \'Back to the Future\'',
      subtitle: '2011 Edition — Size US 9',
      category: 'Collectibles',
      currentBid: '\$28,500',
      timeLeft: '5h 42m',
      totalBids: 18,
      imageEmoji: '👟',
    ),
    DummyAuction(
      id: '3',
      title: '1967 Mustang GT Fastback',
      subtitle: 'Original V8, Fully Restored',
      category: 'Automotive',
      currentBid: '\$156,000',
      timeLeft: '1d 3h',
      totalBids: 12,
      imageEmoji: '🚗',
    ),
  ];

  // ── Recently Listed (Home) ─────────────────────────────────────────────────
  static const List<DummyAuction> recentlyListed = [
    DummyAuction(
      id: '4',
      title: 'Hermès Birkin 25 Togo',
      subtitle: 'Gold Hardware — Etoupe',
      category: 'Bags',
      currentBid: '\$22,400',
      timeLeft: '3d 12h',
      totalBids: 9,
      imageEmoji: '👜',
    ),
    DummyAuction(
      id: '5',
      title: 'Abstract Vision Series #4',
      subtitle: 'Oil on Canvas — Signed',
      category: 'Fine Art',
      currentBid: '\$8,900',
      timeLeft: '2d 8h',
      totalBids: 6,
      imageEmoji: '🎨',
    ),
    DummyAuction(
      id: '6',
      title: 'Leica M3 Single Stroke',
      subtitle: '1954 — Chrome, Excellent Cond.',
      category: 'Collectibles',
      currentBid: '\$4,200',
      timeLeft: '4d 2h',
      totalBids: 4,
      imageEmoji: '📷',
    ),
  ];

  // ── Browse Grid ────────────────────────────────────────────────────────────
  static const List<DummyAuction> browseItems = [
    DummyAuction(
      id: '1',
      title: 'Patek Philippe Nautilus',
      subtitle: 'Timepieces',
      category: 'Timepieces',
      currentBid: '\$84,200',
      timeLeft: '2h 14m',
      totalBids: 34,
      imageEmoji: '⌚',
    ),
    DummyAuction(
      id: '7',
      title: 'Azure Reflections',
      subtitle: 'Fine Art',
      category: 'Fine Art',
      currentBid: '\$12,500',
      timeLeft: '3d 5h',
      totalBids: 11,
      imageEmoji: '🖼️',
    ),
    DummyAuction(
      id: '8',
      title: '2ct Diamond Solitaire',
      subtitle: 'Jewelry',
      category: 'Jewelry',
      currentBid: '\$18,900',
      timeLeft: '1d 8h',
      totalBids: 22,
      imageEmoji: '💎',
    ),
    DummyAuction(
      id: '3',
      title: 'Taycan Turbo S',
      subtitle: 'Automotive',
      category: 'Automotive',
      currentBid: '\$156k',
      timeLeft: '6h 20m',
      totalBids: 8,
      imageEmoji: '🚗',
    ),
    DummyAuction(
      id: '9',
      title: 'Royal Oak Offshore',
      subtitle: 'Timepieces',
      category: 'Timepieces',
      currentBid: '\$32,000',
      timeLeft: '4h 10m',
      totalBids: 15,
      imageEmoji: '⌚',
    ),
    DummyAuction(
      id: '10',
      title: 'Vintage Leica M6',
      subtitle: 'Collectibles',
      category: 'Collectibles',
      currentBid: '\$5,800',
      timeLeft: '2d 14h',
      totalBids: 7,
      imageEmoji: '📷',
    ),
  ];

  // ── Watchlist ──────────────────────────────────────────────────────────────
  static const List<DummyAuction> watchlist = [
    DummyAuction(
      id: '1',
      title: 'Patek Philippe Nautilus',
      subtitle: 'Ref. 5711/1A-010 Blue Dial',
      category: 'Timepieces',
      currentBid: '\$142,500',
      timeLeft: '2h 14m',
      totalBids: 34,
      imageEmoji: '⌚',
      isWatched: true,
    ),
    DummyAuction(
      id: '11',
      title: 'Azure Horizon No. 4',
      subtitle: 'Oil on Canvas — 2023',
      category: 'Fine Art',
      currentBid: '\$12,500',
      timeLeft: '1d 6h',
      totalBids: 11,
      imageEmoji: '🖼️',
      isWatched: true,
    ),
    DummyAuction(
      id: '12',
      title: '1st Ed. Vintage Classics',
      subtitle: 'Hand-bound in goatskin leather',
      category: 'Books',
      currentBid: '\$3,200',
      timeLeft: '3d 2h',
      totalBids: 5,
      imageEmoji: '📚',
      isWatched: true,
    ),
    DummyAuction(
      id: '13',
      title: '1967 GT Fastback',
      subtitle: 'Original V8, Fully Restored',
      category: 'Automotive',
      currentBid: '\$89,000',
      timeLeft: '5h 30m',
      totalBids: 9,
      imageEmoji: '🚗',
      isWatched: true,
    ),
  ];

  // ── My Bids / My Listings ──────────────────────────────────────────────────
  static const List<DummyAuction> myBids = [
    DummyAuction(
      id: '1',
      title: 'Patek Philippe Nautilus',
      subtitle: 'Ref. 5711/1A-010 Blue Dial',
      category: 'Timepieces',
      currentBid: '\$142,500',
      timeLeft: '2h 14m',
      totalBids: 34,
      imageEmoji: '⌚',
      status: 'active',
    ),
    DummyAuction(
      id: '14',
      title: 'Abstract Sculptural Ring',
      subtitle: 'Limited Edition Sterling Silver',
      category: 'Jewelry',
      currentBid: '\$4,200',
      timeLeft: 'Ended',
      totalBids: 128,
      imageEmoji: '💍',
      status: 'won',
    ),
    DummyAuction(
      id: '15',
      title: '19th Century First Edition',
      subtitle: 'Hand-bound in goatskin leather',
      category: 'Books',
      currentBid: '\$8,750',
      timeLeft: 'Ended',
      totalBids: 89,
      imageEmoji: '📚',
      status: 'lost',
    ),
  ];

  // ── Messages ───────────────────────────────────────────────────────────────
  static const List<DummyMessage> messages = [
    DummyMessage(
      id: '1',
      name: 'Arthur Morgan',
      avatar: 'AM',
      preview: 'Your bid for the \'1964 Ferrari\' has been outbid. Would you like to increase...',
      time: '2m ago',
      unread: 2,
    ),
    DummyMessage(
      id: '2',
      name: 'Jane Doe',
      avatar: 'JD',
      preview: 'The authentication certificate has been uploaded to your portal.',
      time: '15m ago',
      unread: 1,
    ),
    DummyMessage(
      id: '3',
      name: 'Lux Support',
      avatar: 'LS',
      preview: 'How was your experience with the recent auction?',
      time: '1h ago',
    ),
    DummyMessage(
      id: '4',
      name: 'Robert King',
      avatar: 'RK',
      preview: 'I\'m interested in the rare stamp collection. Is the reserve met?',
      time: '3h ago',
    ),
    DummyMessage(
      id: '5',
      name: 'Sarah White',
      avatar: 'SW',
      preview: 'Congratulations on winning the \'Emerald Necklace\'!',
      time: '1d ago',
    ),
  ];

  // ── Bid History (Detail page) ──────────────────────────────────────────────
  static const List<DummyBid> bidHistory = [
    DummyBid(bidder: 'Alexandra V.', amount: '\$142,000', time: '2 min ago'),
    DummyBid(bidder: 'Marcus T.', amount: '\$138,500', time: '8 min ago'),
    DummyBid(bidder: 'Sophia R.', amount: '\$135,000', time: '15 min ago'),
    DummyBid(bidder: 'James W.', amount: '\$130,000', time: '32 min ago'),
    DummyBid(bidder: 'Elena K.', amount: '\$125,000', time: '1h ago'),
  ];

  // ── Categories ────────────────────────────────────────────────────────────
  static const List<Map<String, String>> categories = [
    {'label': 'All', 'emoji': '✨'},
    {'label': 'Timepieces', 'emoji': '⌚'},
    {'label': 'Jewelry', 'emoji': '💎'},
    {'label': 'Fine Art', 'emoji': '🎨'},
    {'label': 'Automotive', 'emoji': '🚗'},
    {'label': 'Collectibles', 'emoji': '🏆'},
    {'label': 'Books', 'emoji': '📚'},
    {'label': 'Fashion', 'emoji': '👜'},
  ];
}
