import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auctions/repositories/auction_repository.dart';
import '../../auctions/controllers/auction_controller.dart';
import '../controllers/admin_controller.dart';

class ManageAuctionsScreen extends ConsumerWidget {
  const ManageAuctionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auctionsAsync = ref.watch(allAuctionsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Auctions'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: auctionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (auctions) {
          final activeAuctions = auctions.where((a) => a.status != 'deleted').toList();
          
          if (activeAuctions.isEmpty) {
            return const Center(child: Text('No active auctions to manage.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spaceLG),
            itemCount: activeAuctions.length,
            itemBuilder: (context, index) {
              final auction = activeAuctions[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceMD),
                child: GlassCard(
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: auction.imageUrl != null 
                          ? DecorationImage(image: NetworkImage(auction.imageUrl!), fit: BoxFit.cover)
                          : null,
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      child: auction.imageUrl == null 
                        ? Center(child: Text(auction.imageEmoji, style: const TextStyle(fontSize: 24)))
                        : null,
                    ),
                    title: Text(auction.title, style: AppTextStyles.titleSmall),
                    subtitle: Text('by ${auction.sellerName} • PKR ${auction.currentBid}', style: AppTextStyles.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Auction?'),
                                content: const Text('This will hide the auction from all users.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true), 
                                    child: const Text('Delete', style: TextStyle(color: Colors.red))
                                  ),
                                ],
                              ),
                            );
                            
                            if (confirm == true) {
                              try {
                                await ref.read(adminControllerProvider.notifier).deleteAuction(auction.id);
                                ref.invalidate(allAuctionsProvider);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Auction deleted successfully.')));
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                                }
                              }
                            }
                          },
                          tooltip: 'Delete Auction',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
