import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/providers/appwrite_providers.dart';
import '../controllers/admin_controller.dart';
import 'package:appwrite/appwrite.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      setState(() => _isLoading = true);
      final client = ref.read(appwriteClientProvider);
      final databases = Databases(client);
      
      final response = await databases.listDocuments(
        databaseId: AppConstants.databaseId,
        collectionId: AppConstants.profilesCollection,
        queries: [Query.orderDesc('\$createdAt')],
      );

      setState(() {
        _users = response.documents.map((d) => d.data).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error fetching users: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Users'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spaceLG),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              final isVerified = user['isVerified'] == true;
              final isSuspended = user['isActive'] == false;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.spaceMD),
                child: GlassCard(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(user['name']?[0] ?? 'U', style: const TextStyle(color: AppColors.primary)),
                    ),
                    title: Row(
                      children: [
                        Text(user['name'] ?? 'Unknown', style: AppTextStyles.titleSmall),
                        if (isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blue, size: 14),
                        ],
                      ],
                    ),
                    subtitle: Text(user['email'] ?? 'No email', style: AppTextStyles.bodySmall),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            isVerified ? Icons.verified_user_rounded : Icons.shield_outlined,
                            color: isVerified ? Colors.green : Colors.blue,
                          ),
                          onPressed: () async {
                            await ref.read(adminControllerProvider.notifier).toggleVerification(user['userId'], isVerified);
                            _fetchUsers();
                          },
                          tooltip: 'Verify User',
                        ),
                        IconButton(
                          icon: Icon(
                            isSuspended ? Icons.lock_rounded : Icons.block_flipped,
                            color: isSuspended ? Colors.orange : Colors.red,
                          ),
                          onPressed: () async {
                            await ref.read(adminControllerProvider.notifier).toggleUserStatus(user['userId'], !isSuspended);
                            _fetchUsers();
                          },
                          tooltip: 'Suspend User',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }
}
