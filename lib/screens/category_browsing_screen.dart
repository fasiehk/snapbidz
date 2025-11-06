import 'package:flutter/material.dart';

class CategoryBrowsingScreen extends StatefulWidget {
  const CategoryBrowsingScreen({Key? key}) : super(key: key);

  @override
  State<CategoryBrowsingScreen> createState() => _CategoryBrowsingScreenState();
}

class _CategoryBrowsingScreenState extends State<CategoryBrowsingScreen> {
  int _selectedIndex = 1; // Categories tab selected
  String _selectedCategory = 'Furniture';

  final List<String> _categories = [
    'Furniture',
    'Electronics',
    'Vehicles',
    'Fashion',
    'Home & Garden',
    'Collectibles',
  ];

  final List<Map<String, dynamic>> _items = [
    {
      'title': 'Vintage Leather Sofa',
      'bid': '\$550',
      'timeLeft': '2 days left',
      'image': 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
      'isFavorite': false,
    },
    {
      'title': 'Classic Wooden Chair',
      'bid': '\$120',
      'timeLeft': '12 hours left',
      'image': 'https://images.unsplash.com/photo-1503602642458-232111445657?w=400',
      'isFavorite': true,
    },
    {
      'title': 'Minimalist Desk',
      'bid': '\$250',
      'timeLeft': '1 day left',
      'image': 'https://images.unsplash.com/photo-1518455027359-f3f8164ba6bd?w=400',
      'isFavorite': false,
    },
    {
      'title': 'Retro Wall Clock',
      'bid': '\$80',
      'timeLeft': '5 hours left',
      'image': 'https://images.unsplash.com/photo-1563861826100-9cb868fdbe1c?w=400',
      'isFavorite': false,
    },
  ];

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        // Already on categories, do nothing
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/chat-list');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0FBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF293241)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Categories',
          style: TextStyle(
            color: Color(0xFF293241),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF293241)),
            onPressed: () {
              // Handle search
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFF98C1D9),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Category chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: FilterChip(
                      label: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF293241),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      backgroundColor: const Color(0xFF98C1D9),
                      selectedColor: const Color(0xFFEE6C4D),
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            color: Colors.white,
            height: 1,
            child: Container(color: const Color(0xFF98C1D9)),
          ),
          // Product grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68, // Changed from 0.75 to give more height
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return _buildProductCard(item, index);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Handle list item
        },
        backgroundColor: const Color(0xFFEE6C4D),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'List an Item',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: const Color(0xFF98C1D9).withOpacity(0.5)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFFEE6C4D),
          unselectedItemColor: const Color(0xFF3D5A80),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.style_outlined),
              activeIcon: Icon(Icons.style),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-details',
          arguments: item,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with favorite button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      item['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF98C1D9),
                          child: const Icon(Icons.image, size: 50, color: Colors.white),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _items[index]['isFavorite'] = !_items[index]['isFavorite'];
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: item['isFavorite'] ? const Color(0xFFEE6C4D) : const Color(0xFF293241),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Product details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10), // Reduced from 12 to 10
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['title'],
                      style: const TextStyle(
                        color: Color(0xFF293241),
                        fontSize: 14, // Reduced from 16 to 14
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Text(
                      'Current Bid: ${item['bid']}',
                      style: const TextStyle(
                        color: Color(0xFFEE6C4D),
                        fontSize: 13, // Reduced from 14 to 13
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2), // Kept at 2
                    Text(
                      item['timeLeft'],
                      style: const TextStyle(
                        color: Color(0xFF98C1D9),
                        fontSize: 11, // Reduced from 12 to 11
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
