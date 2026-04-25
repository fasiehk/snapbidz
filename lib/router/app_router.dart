import 'package:flutter/material.dart';
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
import '../features/create_listing/create_listing_screen.dart';
import '../features/create_listing/edit_listing_screen.dart';
import '../features/main/main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
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
      ],
    ),
    GoRoute(
      path: '/auction/:id',
      builder: (context, state) => AuctionDetailScreen(
        auctionId: state.pathParameters['id'] ?? '',
      ),
    ),
    GoRoute(
      path: '/chat/:userId',
      builder: (context, state) => ChatWindowScreen(
        userId: state.pathParameters['userId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/my-bids',
      builder: (context, state) => const MyBidsScreen(),
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingScreen(),
    ),
    GoRoute(
      path: '/edit-listing',
      builder: (context, state) {
        final auction = state.extra as dynamic; // Cast to AuctionModel in builder
        return EditListingScreen(auction: auction);
      },
    ),
  ],
);
