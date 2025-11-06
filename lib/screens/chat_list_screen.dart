import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 2; // Changed from no index to 2

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Liam Gallery',
      'message': 'Hey! The bidding ends in 1 hour. Just wanted to...',
      'time': '10:45 AM',
      'unreadCount': 2,
      'isUnread': true,
      'avatar': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100',
    },
    {
      'name': 'Sarah Vintage',
      'message': 'Okay, sounds good! I\'ll send it out tomorrow.',
      'time': 'Yesterday',
      'unreadCount': 0,
      'isUnread': false,
      'avatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
    },
    {
      'name': 'Antique Finds',
      'message': 'Is the antique vase still available?',
      'time': 'Mon',
      'unreadCount': 1,
      'isUnread': true,
      'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
    },
    {
      'name': 'Emily White',
      'message': 'Perfect, thank you!',
      'time': 'Oct 28',
      'unreadCount': 0,
      'isUnread': false,
      'avatar': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100',
    },
    {
      'name': 'Retro Hub',
      'message': 'Sure, I can ship it to your address.',
      'time': 'Oct 25',
      'unreadCount': 0,
      'isUnread': false,
      'avatar': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/categories');
        break;
      case 2:
        // Already on chat, do nothing
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
        backgroundColor: const Color(0xFF3D5A80),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF98C1D9)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Color(0xFFE0FBFC),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF98C1D9)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFFE0FBFC)),
              decoration: InputDecoration(
                hintText: 'Search by seller or item',
                hintStyle: const TextStyle(color: Color(0xFF98C1D9)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF98C1D9)),
                filled: true,
                fillColor: const Color(0xFF293241).withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildChatItem(conversation);
        },
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

  Widget _buildChatItem(Map<String, dynamic> conversation) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/chat-window',
          arguments: conversation,
        );
      },
      child: Container(
        color: const Color(0xFFE0FBFC),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF98C1D9),
              backgroundImage: NetworkImage(conversation['avatar']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    conversation['name'],
                    style: const TextStyle(
                      color: Color(0xFF293241),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation['message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: conversation['isUnread']
                          ? const Color(0xFF3D5A80)
                          : const Color(0xFF98C1D9),
                      fontSize: 14,
                      fontWeight: conversation['isUnread']
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  conversation['time'],
                  style: TextStyle(
                    color: conversation['isUnread']
                        ? const Color(0xFF3D5A80)
                        : const Color(0xFF98C1D9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                if (conversation['unreadCount'] > 0)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEE6C4D),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${conversation['unreadCount']}',
                        style: const TextStyle(
                          color: Color(0xFFE0FBFC),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                else if (conversation['isUnread'])
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEE6C4D),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
