import 'package:flutter/material.dart';
import 'dart:async';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const ProductDetailsScreen({Key? key, this.product}) : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool _isBookmarked = false;
  Timer? _timer;
  Duration _timeRemaining = const Duration(hours: 12, minutes: 34, seconds: 56);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining.inSeconds > 0) {
        setState(() {
          _timeRemaining = Duration(seconds: _timeRemaining.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    // Use passed product data or dummy data
    final productTitle = widget.product?['title'] ?? 'Vintage Camera';
    final productDescription = widget.product?['description'] ??
        'A classic vintage camera in excellent working condition. A must-have for collectors and photography enthusiasts. This piece has been carefully maintained and comes with its original leather case.';
    final basePrice = widget.product?['basePrice'] ?? '\$500.00';
    final currentBid = widget.product?['currentBid'] ?? '\$750.00';
    final images = widget.product?['images'] ?? [
      'https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?w=400',
      'https://images.unsplash.com/photo-1606982772852-5160c3c64ad4?w=400',
      'https://images.unsplash.com/photo-1607462109225-6b64ae2dd3cb?w=400',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE0FBFC),
      body: Stack(
        children: [
          // Main content
          CustomScrollView(
            slivers: [
              // App bar
              SliverAppBar(
                backgroundColor: const Color(0xFFE0FBFC).withOpacity(0.8),
                elevation: 0,
                pinned: true,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF293241)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: const Color(0xFF293241),
                      ),
                      onPressed: () {
                        setState(() {
                          _isBookmarked = !_isBookmarked;
                        });
                      },
                    ),
                  ),
                ],
              ),
              // Image carousel
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 300,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Product details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        productTitle,
                        style: const TextStyle(
                          color: Color(0xFF293241),
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Text(
                        productDescription,
                        style: const TextStyle(
                          color: Color(0xFF3D5A80),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Price and bid info
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard('Base Price', basePrice),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoCard('Current Bid', currentBid),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Time remaining
                      _buildTimeRemainingCard(),
                      const SizedBox(height: 24),
                      // Seller info
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFF98C1D9),
                              child: const Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'AlexDoe',
                                    style: TextStyle(
                                      color: Color(0xFF293241),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: Color(0xFF98C1D9),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Verified Seller',
                                        style: TextStyle(
                                          color: Color(0xFF98C1D9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Handle message
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF98C1D9).withOpacity(0.2),
                                foregroundColor: const Color(0xFF98C1D9),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              icon: const Icon(Icons.message, size: 18),
                              label: const Text(
                                'Message',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE0FBFC).withOpacity(0.8),
                border: Border(
                  top: BorderSide(
                    color: const Color(0xFF98C1D9).withOpacity(0.3),
                  ),
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _showBidDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEE6C4D),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor: const Color(0xFFEE6C4D).withOpacity(0.3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Place Bid',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF98C1D9).withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF3D5A80),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF293241),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemainingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF98C1D9).withOpacity(0.5),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Time Remaining',
            style: TextStyle(
              color: Color(0xFF3D5A80),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDuration(_timeRemaining),
            style: const TextStyle(
              color: Color(0xFFEE6C4D),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showBidDialog() {
    final TextEditingController bidController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Place Your Bid'),
        content: TextField(
          controller: bidController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Bid Amount',
            prefixText: '\$',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle bid placement
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bid placed successfully!',
                    style: TextStyle(color: Color(0xFFE0FBFC)),
                  ),
                  backgroundColor: Color(0xFFEE6C4D),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE6C4D),
            ),
            child: const Text('Place Bid'),
          ),
        ],
      ),
    );
  }
}
