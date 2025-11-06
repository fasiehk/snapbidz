import 'package:flutter/material.dart';

class ChatWindowScreen extends StatefulWidget {
  final Map<String, dynamic>? conversation;

  const ChatWindowScreen({Key? key, this.conversation}) : super(key: key);

  @override
  State<ChatWindowScreen> createState() => _ChatWindowScreenState();
}

class _ChatWindowScreenState extends State<ChatWindowScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadDummyMessages();
  }

  void _loadDummyMessages() {
    _messages.addAll([
      {
        'text': 'Hello! I saw you\'re interested in the vintage camera. Is there anything specific you\'d like to know about it?',
        'isSender': false,
        'time': '10:43 AM',
        'isRead': true,
      },
      {
        'text': 'Hi Eleanor! Thanks for reaching out. Yes, I was wondering if you could tell me more about its condition and if it\'s fully functional.',
        'isSender': true,
        'time': '10:45 AM',
        'isRead': true,
      },
      {
        'text': 'Of course. It\'s in excellent condition for its age, with only minor cosmetic wear. I\'ve tested it recently, and all mechanical parts, including the shutter and film advance, are working perfectly.',
        'isSender': false,
        'time': '10:46 AM',
        'isRead': true,
      },
      {
        'text': 'That sounds great!',
        'isSender': true,
        'time': '10:48 AM',
        'isRead': false,
      },
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'text': _messageController.text.trim(),
        'isSender': true,
        'time': TimeOfDay.now().format(context),
        'isRead': false,
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerName = widget.conversation?['name'] ?? 'Eleanor Pena';
    final sellerAvatar = widget.conversation?['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100';

    return Scaffold(
      backgroundColor: const Color(0xFFE0FBFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3D5A80),
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE0FBFC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF98C1D9),
              backgroundImage: NetworkImage(sellerAvatar),
            ),
            const SizedBox(width: 12),
            Text(
              sellerName,
              style: const TextStyle(
                color: Color(0xFFE0FBFC),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFE0FBFC)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + 1, // +1 for date divider
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildDateDivider();
                }
                return _buildMessageBubble(_messages[index - 1]);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildDateDivider() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF98C1D9).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Today',
          style: TextStyle(
            color: Color(0xFF293241),
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isSender = message['isSender'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSender) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF98C1D9),
              backgroundImage: NetworkImage(
                widget.conversation?['avatar'] ?? 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSender ? const Color(0xFF3D5A80) : const Color(0xFF98C1D9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isSender ? 12 : 0),
                      bottomRight: Radius.circular(isSender ? 0 : 12),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isSender ? const Color(0xFFE0FBFC) : const Color(0xFF293241),
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message['time'],
                        style: const TextStyle(
                          color: Color(0xFF98C1D9),
                          fontSize: 12,
                        ),
                      ),
                      if (isSender) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.done_all,
                          size: 16,
                          color: message['isRead'] ? const Color(0xFFEE6C4D) : const Color(0xFF98C1D9),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF3D5A80).withOpacity(0.2),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF98C1D9).withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(color: Color(0xFF293241)),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: const TextStyle(color: Color(0xFF98C1D9)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFFEE6C4D),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFEE6C4D),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFE0FBFC)),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
