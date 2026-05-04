import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/home/home_screen.dart';
import '../features/browse/browse_screen.dart';
import '../features/details/auction_detail_screen.dart';
import '../features/watchlist/watchlist_screen.dart';
import '../features/messages/messages_screen.dart';
import '../features/messages/chat_window_screen.dart';
import '../features/bids/my_bids_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/profile/edit_profile_screen.dart';
import '../features/create_listing/create_listing_screen.dart';
import '../features/create_listing/select_category_screen.dart';
import '../features/create_listing/select_subcategory_screen.dart';
import '../features/create_listing/select_model_screen.dart';
import '../features/create_listing/property_details_screen.dart';
import '../features/create_listing/vehicle_details_screen.dart';
import '../features/create_listing/tech_details_screen.dart';
import '../core/data/category_data.dart';
import '../features/create_listing/edit_listing_screen.dart';
import '../features/main/main_shell.dart';
import '../features/seller_verification/seller_verification_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/admin/screens/manage_users_screen.dart';
import '../features/admin/screens/manage_auctions_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      // If auth is still loading, don't redirect yet
      if (authState.isLoading) return null;

      final bool loggedIn = authState.value != null;
      final bool loggingIn = state.matchedLocation == '/login' || 
                            state.matchedLocation == '/signup' || 
                            state.matchedLocation == '/onboarding' ||
                            state.matchedLocation == '/';

      // 1. If not logged in and not on an auth screen, go to onboarding
      if (!loggedIn && !loggingIn) return '/onboarding';

      // 2. If logged in and on an auth screen, go home
      if (loggedIn && loggingIn && state.matchedLocation != '/') return '/home';

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      // Main shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/browse',
            builder: (context, state) => const BrowseScreen(),
          ),
          GoRoute(
            path: '/watchlist',
            builder: (context, state) => const WatchlistScreen(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
        ],
      ),
      // Admin Panel Routes with dedicated Shell (Sidebar)
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardContent(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const ManageUsersScreen(),
          ),
          GoRoute(
            path: '/admin/auctions',
            builder: (context, state) => const ManageAuctionsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/auction/:id',
        builder: (context, state) => AuctionDetailScreen(
          auctionId: state.pathParameters['id'] ?? '',
        ),
      ),
      // Chat route
      GoRoute(
        path: '/chat/:auctionId',
        builder: (context, state) {
          final auctionId = state.pathParameters['auctionId'] ?? '';
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ChatWindowScreen(
            auctionId: auctionId,
            auctionTitle: extra['auctionTitle'] as String? ?? 'Auction',
            otherUserId: extra['otherUserId'] as String? ?? '',
            otherUserName: extra['otherUserName'] as String? ?? 'User',
            currentBid: extra['currentBid'] as String? ?? '',
            auctionImage: extra['auctionImage'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/my-bids',
        builder: (context, state) => const MyBidsScreen(),
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) => const SelectCategoryScreen(),
      ),
      GoRoute(
        path: '/create/subcategory',
        builder: (context, state) {
          final category = state.extra as AuctionCategory;
          return SelectSubCategoryScreen(category: category);
        },
      ),
      GoRoute(
        path: '/create/model',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SelectModelScreen(
            categoryName: extra['category'] as String,
            subCategory: extra['subCategory'] as SubCategory,
          );
        },
      ),
      GoRoute(
        path: '/create/property-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PropertyDetailsScreen(
            category: extra['category'] as String,
            subCategory: extra['subCategory'] as String,
          );
        },
      ),
      GoRoute(
        path: '/create/vehicle-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return VehicleDetailsScreen(
            category: extra['category'] as String,
            subCategory: extra['subCategory'] as String,
            model: extra['model'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/create/tech-details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return TechDetailsScreen(
            category: extra['category'] as String,
            subCategory: extra['subCategory'] as String,
            model: extra['model'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/create/details',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return CreateListingScreen(
            category: extra['category'] as String? ?? 'Other',
            subCategory: extra['subCategory'] as String?,
            model: extra['model'] as String?,
            propertyDetails: extra['propertyDetails'] as Map<String, String>?,
          );
        },
      ),
      GoRoute(
        path: '/edit-listing',
        builder: (context, state) {
          final auction = state.extra as dynamic;
          return EditListingScreen(auction: auction);
        },
      ),
      // Seller verification / KYC screen
      GoRoute(
        path: '/seller-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return SellerVerificationScreen(redirectPath: extra['redirectPath'] as String?);
        },
      ),
    ],
  );
});
