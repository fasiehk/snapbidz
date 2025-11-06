import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_browse_screen.dart';
import 'screens/category_browsing_screen.dart';
import 'screens/watchlist_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/product_details_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_window_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await _verifyFirebaseSetup(); // quick sanity check (non-destructive)
  } catch (e, st) {
    debugPrint('Firebase init failed: $e');
    debugPrint('$st');
  }
  runApp(const SnapBidApp());
}

// Simple, non-destructive check to confirm Auth is wired up
Future<void> _verifyFirebaseSetup() async {
  final app = Firebase.app();
  debugPrint('Firebase app: ${app.name}, projectId: ${app.options.projectId}');
  final user = await FirebaseAuth.instance.authStateChanges().first;
  debugPrint('Firebase Auth ready. Current user: ${user?.uid ?? "none"}');
}

class SnapBidApp extends StatelessWidget {
  const SnapBidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapBid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFEE6C4D),
        scaffoldBackgroundColor: const Color(0xFF3D5A80),
        fontFamily: 'Work Sans',
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const HomeBrowseScreen(),
        '/categories': (context) => const CategoryBrowsingScreen(),
        '/watchlist': (context) => const WatchlistScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/product-details': (context) => const ProductDetailsScreen(),
        '/chat-list': (context) => const ChatListScreen(),
        '/chat-window': (context) => const ChatWindowScreen(),
      },
    );
  }
}

// Placeholder home screen
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   Future<void> _logout(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       if (context.mounted) {
//         Navigator.of(context).pushReplacementNamed('/login');
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error logging out: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       backgroundColor: const Color(0xFF3D5A80),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFEE6C4D),
//         title: const Text('SnapBid'),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//             onPressed: () => _logout(context),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'Welcome to SnapBid!',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFFE0FBFC),
//               ),
//             ),
//             const SizedBox(height: 20),
//             if (user != null)
//               Text(
//                 'Logged in as: ${user.email}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Color(0xFFE0FBFC),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
