import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      icon: Icons.gavel,
      title: 'Discover & Bid',
      description: 'Find unique items and place bids easily and securely from anywhere.',
    ),
    OnboardingPage(
      icon: Icons.notifications_active,
      title: 'Real-time Updates',
      description: 'Get instant notifications when you\'re outbid or when auctions are ending.',
    ),
    OnboardingPage(
      icon: Icons.verified_user,
      title: 'Safe & Secure',
      description: 'Your transactions are protected with industry-leading security measures.',
    ),
  ];

  void _onSkip() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      setState(() {
        _currentPage++;
      });
    } else {
      _onSkip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3D5A80),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _onSkip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: Color(0xFF98C1D9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
            
            // Main content - animated
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: _buildPage(_pages[_currentPage]),
              ),
            ),
            
            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE6C4D),
                    foregroundColor: const Color(0xFF293241),
                    elevation: 4,
                    shadowColor: const Color(0xFFEE6C4D).withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Column(
      key: ValueKey<int>(_currentPage),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon/Illustration
        Container(
          width: 280,
          height: 280,
          alignment: Alignment.center,
          child: Icon(
            page.icon,
            size: 140,
            color: const Color(0xFFE0FBFC),
            weight: 200,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Page indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: index == _currentPage ? 24 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: index == _currentPage
                    ? const Color(0xFFEE6C4D)
                    : const Color(0xFF98C1D9).withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Headline
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            page.title,
            style: const TextStyle(
              color: Color(0xFFE0FBFC),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Body text
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Text(
              page.description,
              style: const TextStyle(
                color: Color(0xFF98C1D9),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class OnboardingPage {
  final IconData icon;
  final String title;
  final String description;

  OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
