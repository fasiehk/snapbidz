import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/glass_card.dart';

class ChatWindowScreen extends StatefulWidget {
  final String userId;
  const ChatWindowScreen({super.key, required this.userId});

  @override
  State<ChatWindowScreen> createState() => _ChatWindowScreenState();
}

class _ChatWindowScreenState extends State<ChatWindowScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Your bid for the 1964 Ferrari has been outbid. Current highest is \$156,000. Would you like to increase your bid?', isMe: false, time: '2:14 PM'),
    _ChatMessage(text: 'Thanks for the heads up! Yes, I\'d like to bid \$160,000 please.', isMe: true, time: '2:16 PM'),
    _ChatMessage(text: 'Great! Your bid of \$160,000 has been placed. You are now the highest bidder.', isMe: false, time: '2:17 PM'),
    _ChatMessage(text: 'Perfect. How much time is left on the auction?', isMe: true, time: '2:18 PM'),
    _ChatMessage(text: 'The auction closes in 2 hours and 14 minutes. Good luck! 🏆', isMe: false, time: '2:18 PM'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isMe: true, time: 'Just now'));
      _controller.clear();
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppConstants.animNormal,
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white.withAlpha(230),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Center(child: Text('AM', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark))),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Arthur Morgan', style: AppTextStyles.titleSmall),
                Text('Online', style: AppTextStyles.labelSmall.copyWith(color: AppColors.secondary, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Auction context card
          Container(
            margin: const EdgeInsets.all(AppConstants.spaceMD),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD, vertical: AppConstants.spaceSM),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    child: const Center(child: Text('🚗', style: TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: AppConstants.spaceSM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1964 Ferrari GTO', style: AppTextStyles.titleSmall.copyWith(fontSize: 13)),
                        Text('Current bid: \$156,000 • 2h 14m left', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 20),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMD),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _ChatBubble(message: _messages[i]),
            ),
          ),

          // Input
          Container(
            padding: EdgeInsets.fromLTRB(
              AppConstants.spaceMD, AppConstants.spaceSM,
              AppConstants.spaceMD, AppConstants.spaceSM + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(230),
              border: Border(top: BorderSide(color: AppColors.outlineVariant.withAlpha(60))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                      filled: true,
                      fillColor: AppColors.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.onPrimary, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment: message.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: message.isMe
                    ? const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary])
                    : null,
                color: message.isMe ? null : Colors.white.withAlpha(220),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isMe ? 16 : 4),
                  bottomRight: Radius.circular(message.isMe ? 4 : 16),
                ),
                border: message.isMe ? null : Border.all(color: AppColors.outlineVariant.withAlpha(80)),
                boxShadow: [
                  BoxShadow(color: AppColors.shadowLight, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: message.isMe ? AppColors.onPrimary : AppColors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(message.time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  const _ChatMessage({required this.text, required this.isMe, required this.time});
}
