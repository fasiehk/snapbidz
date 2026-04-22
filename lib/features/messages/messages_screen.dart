import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/data/dummy_data.dart';
import '../../core/widgets/glass_card.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(AppConstants.spaceLG, AppConstants.spaceMD, AppConstants.spaceLG, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Messages', style: AppTextStyles.headlineMedium),
                  const SizedBox(height: 4),
                  Text('5 conversations', style: AppTextStyles.bodySmall.copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppConstants.spaceMD),
                  // Search
                  TextField(
                    style: AppTextStyles.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search messages…',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.outline),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.outline),
                      filled: true,
                      fillColor: Colors.white.withAlpha(200),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withAlpha(80)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withAlpha(80)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceMD),

            // ── Message List ─────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLG),
                itemCount: AppDummyData.messages.length,
                separatorBuilder: (_, __) => Divider(height: 1, color: AppColors.outlineVariant.withAlpha(60)),
                itemBuilder: (context, i) {
                  final msg = AppDummyData.messages[i];
                  return _MessageTile(message: msg, onTap: () => context.push('/chat/${msg.id}'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  final DummyMessage message;
  final VoidCallback onTap;
  const _MessageTile({required this.message, required this.onTap});

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
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryFixed, AppColors.primaryFixedDim],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      message.avatar,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark),
                    ),
                  ),
                ),
                if (message.unread > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
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
                          message.name,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: message.unread > 0 ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(message.time, style: AppTextStyles.labelSmall.copyWith(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.preview,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: message.unread > 0 ? AppColors.onSurface : AppColors.onSurfaceVariant,
                      fontWeight: message.unread > 0 ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (message.unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    '${message.unread}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onPrimary),
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
