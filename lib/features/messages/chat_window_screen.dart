import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../auth/controllers/auth_controller.dart';
import 'models/chat_message_model.dart';
import 'repositories/chat_repository.dart';
import 'controllers/chat_controller.dart';

class ChatWindowScreen extends ConsumerStatefulWidget {
  final String auctionId;
  final String auctionTitle;
  final String otherUserId;
  final String otherUserName;
  final String currentBid;
  final String? auctionImage;

  const ChatWindowScreen({
    super.key,
    required this.auctionId,
    required this.auctionTitle,
    required this.otherUserId,
    required this.otherUserName,
    this.currentBid = '',
    this.auctionImage,
  });

  @override
  ConsumerState<ChatWindowScreen> createState() => _ChatWindowScreenState();
}

class _ChatWindowScreenState extends ConsumerState<ChatWindowScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        if (animated) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: AppConstants.animNormal,
            curve: Curves.easeOut,
          );
        } else {
          _scrollController.jumpTo(
            _scrollController.position.maxScrollExtent,
          );
        }
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    final user = ref.read(authControllerProvider).value;
    if (user == null) return;

    setState(() => _isSending = true);
    _controller.clear();

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            auctionId: widget.auctionId,
            auctionTitle: widget.auctionTitle,
            senderId: user.$id,
            senderName: user.name,
            receiverId: widget.otherUserId,
            receiverName: widget.otherUserName,
            text: text,
            auctionImage: widget.auctionImage,
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send: $e'), backgroundColor: AppColors.error),
        );
        _controller.text = text; // restore
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  String _avatarInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).value;
    final messagesAsync = ref.watch(chatMessagesProvider(widget.auctionId));

    // Auto-scroll when new messages arrive
    messagesAsync.whenData((_) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Auction context banner
          _AuctionContextBanner(
            auctionTitle: widget.auctionTitle,
            currentBid: widget.currentBid,
            auctionId: widget.auctionId,
            auctionImage: widget.auctionImage,
          ),

          // Messages
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.outline),
                    const SizedBox(height: 8),
                    Text('Could not load messages', style: AppTextStyles.bodySmall),
                  ],
                ),
              ),
              data: (messages) {
                final filteredMessages = messages.where((m) => 
                  (m.senderId == user?.$id && m.receiverId == widget.otherUserId) || 
                  (m.senderId == widget.otherUserId && m.receiverId == user?.$id)
                ).toList();

                if (filteredMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryFixed,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 30, color: AppColors.primaryDark),
                        ),
                        const SizedBox(height: 12),
                        Text('Start the conversation!',
                            style: AppTextStyles.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          'Say hello to ${widget.otherUserName}',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  );
                }

                // Mark received messages as read
                for (final msg in filteredMessages) {
                  if (msg.receiverId == user?.$id && !msg.isRead) {
                    ref.read(chatRepositoryProvider).markAsRead(msg.id);
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, i) {
                    final msg = filteredMessages[i];
                    final isMe = msg.senderId == user?.$id;
                    final showDate = i == 0 ||
                        !_sameDay(filteredMessages[i - 1].createdAt, msg.createdAt);
                    return Column(
                      children: [
                        if (showDate) _DateDivider(date: msg.createdAt),
                        _ChatBubble(message: msg, isMe: isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          _InputBar(
            controller: _controller,
            isSending: _isSending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  AppBar _buildAppBar() {
    final initials = _avatarInitials(widget.otherUserName);
    return AppBar(
      backgroundColor: Colors.white.withAlpha(230),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryDark, AppColors.primary],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.otherUserName, style: AppTextStyles.titleSmall),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Active now',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: const Color(0xFF10B981),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Auction Context Banner ────────────────────────────────────────────────────

class _AuctionContextBanner extends StatelessWidget {
  final String auctionTitle;
  final String currentBid;
  final String auctionId;
  final String? auctionImage;

  const _AuctionContextBanner({
    required this.auctionTitle,
    required this.currentBid,
    required this.auctionId,
    this.auctionImage,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/auction/$auctionId'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(200),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant.withAlpha(80)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryFixed,
                borderRadius: BorderRadius.circular(8),
                image: auctionImage != null
                    ? DecorationImage(
                        image: NetworkImage(auctionImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: auctionImage == null
                  ? const Center(child: Text('📦', style: TextStyle(fontSize: 22)))
                  : null,
            ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auctionTitle,
                  style: AppTextStyles.titleSmall.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (currentBid.isNotEmpty)
                  Text(
                    'Current bid: $currentBid',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.outline, size: 18),
        ],
      ),
    ),
  );
}
}

// ── Chat Bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isMe;
  const _ChatBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final time =
        '${message.createdAt.hour.toString().padLeft(2, '0')}:${message.createdAt.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isMe
                    ? const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                      )
                    : null,
                color: isMe ? null : Colors.white.withAlpha(220),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe
                    ? null
                    : Border.all(
                        color: AppColors.outlineVariant.withAlpha(80)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isMe ? AppColors.onPrimary : AppColors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.outline, fontSize: 10),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: message.isRead
                        ? AppColors.primary
                        : AppColors.outline,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Date Divider ──────────────────────────────────────────────────────────────

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  String _label() {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(
              child: Divider(color: AppColors.outlineVariant, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _label(),
              style: AppTextStyles.labelSmall
                  .copyWith(color: AppColors.outline, fontSize: 11),
            ),
          ),
          const Expanded(
              child: Divider(color: AppColors.outlineVariant, height: 1)),
        ],
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;
  const _InputBar(
      {required this.controller,
      required this.isSending,
      required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        border: Border(
            top: BorderSide(color: AppColors.outlineVariant.withAlpha(60))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyles.bodyMedium,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message…',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.outline),
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isSending ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isSending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded,
                      color: AppColors.onPrimary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
