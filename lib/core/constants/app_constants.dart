/// SnapBid — App-wide Constants
abstract class AppConstants {
  // ─── Appwrite ──────────────────────────────────────────────────────────────
  static const String appwriteEndpoint = 'https://nyc.cloud.appwrite.io/v1';
  static const String appwriteProjectId = '69e92d730021fae676bb';

  // ─── Database ─────────────────────────────────────────────────────────────
  static const String databaseId = 'snapbid_db';

  // Collections
  static const String auctionsCollection = 'auctions';
  static const String bidsCollection = 'bids';
  static const String watchlistCollection = 'watchlist';
  static const String messagesCollection = 'messages';

  // ─── Storage ──────────────────────────────────────────────────────────────
  static const String auctionImagesBucket = 'auction_images';
  static const String profileAvatarsBucket = 'profile_avatars';

  // ─── Spacing (8px grid) ───────────────────────────────────────────────────
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;

  // ─── Border Radius ────────────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusFull = 999.0;

  // ─── Animation Durations ─────────────────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ─── Glassmorphism ───────────────────────────────────────────────────────
  static const double glassBlur = 10.0;
  static const double glassOpacity = 0.70;
  static const double glassBorderOpacity = 0.30;

  // ─── App Info ─────────────────────────────────────────────────────────────
  static const String appName = 'SnapBid';
  static const String appTagline = 'Discover. Bid. Win.';
  static const String appSubtitle = 'Premium Auction Platform';
}
