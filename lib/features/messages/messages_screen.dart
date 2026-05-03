import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../auth/controllers/auth_controller.dart';
import 'repositories/chat_repository.dart';

class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.value;

    if (user == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Text('Please log in to view messages.',
              style: AppTextStyles.bodyMedium),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceLG, AppConstants.spaceMD, AppConstants.spaceLG, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Messages', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    'Your auction conversations',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMD),

            // Conversations list
            Expanded(
              child: _ConversationsListView(userId: user.$id),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationsListView extends ConsumerStatefulWidget {
  final String userId;
  const _ConversationsListView({required this.userId});

  @override
  ConsumerState<_ConversationsListView> createState() =>
      _ConversationsListViewState();
}

class _ConversationsListViewState
    extends ConsumerState<_ConversationsListView> {
  List<Map<String, dynamic>>? _threads;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final threads = await ref
          .read(chatRepositoryProvider)
          .getConversationThreads(widget.userId);
      if (mounted) setState(() => _threads = threads);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.outline),
            const SizedBox(height: 8),
            Text('Failed to load messages', style: AppTextStyles.bodySmall),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final threads = _threads ?? [];

    if (threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.primaryFixed,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline_rounded,
                  size: 34, color: AppColors.primaryDark),
            ),
            const SizedBox(height: 16),
            Text('No conversations yet', style: AppTextStyles.titleSmall),
            const SizedBox(height: 6),
            Text(
              'Bid on an auction or message a seller\nto start a conversation.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
        itemCount: threads.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.outlineVariant.withAlpha(60)),
        itemBuilder: (context, i) {
          final thread = threads[i];
          final isMe = thread['senderId'] == widget.userId;
          final otherUserId =
              isMe ? thread['receiverId'] as String : thread['senderId'] as String;
          final otherUserName =
              isMe ? (thread['receiverName'] ?? 'User') as String : thread['senderName'] as String;
          final auctionId = thread['auctionId'] as String;
          final auctionTitle =
              (thread['auctionTitle'] as String?) ?? 'Auction';
          final lastText = thread['text'] as String? ?? '';
          final isRead = thread['isRead'] as bool? ?? true;
          final sentAt = thread['createdAt'] != null
              ? DateTime.tryParse(thread['createdAt'] as String)
              : null;
          final auctionImage = thread['auctionImage'] as String?;

          return _ConversationTile(
            otherUserName: otherUserName,
            auctionTitle: auctionTitle,
            auctionImage: auctionImage,
            lastMessage: isMe ? 'You: $lastText' : lastText,
            time: sentAt != null ? _formatTime(sentAt) : '',
            unread: (!isRead && !isMe) ? 1 : 0,
            onTap: () => context.push(
              '/chat/$auctionId',
              extra: {
                'auctionTitle': auctionTitle,
                'otherUserId': otherUserId,
                'otherUserName': otherUserName,
                'auctionImage': auctionImage,
              },
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return '${dt.day}/${dt.month}';
  }
}

class _ConversationTile extends StatelessWidget {
  final String otherUserName;
  final String auctionTitle;
  final String? auctionImage;
  final String lastMessage;
  final String time;
  final int unread;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.otherUserName,
    required this.auctionTitle,
    this.auctionImage,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  String get _initials {
    final parts = otherUserName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return otherUserName.isNotEmpty ? otherUserName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryFixed, AppColors.primaryFixedDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _initials,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ),
                ),
                if (unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppConstants.spaceMD),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: unread > 0
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        time,
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (auctionImage != null)
                        Container(
                          width: 16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            image: DecorationImage(
                              image: NetworkImage(auctionImage!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(right: 6),
                          child: Text('📦', style: TextStyle(fontSize: 10)),
                        ),
                      Expanded(
                        child: Text(
                          auctionTitle,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lastMessage,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: unread > 0
                          ? AppColors.onSurface
                          : AppColors.onSurfaceVariant,
                      fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$unread',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
