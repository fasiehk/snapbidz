import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/admin_repository.dart';

final adminStatsProvider = FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).getStats();
});

final adminControllerProvider = StateNotifierProvider<AdminController, bool>((ref) {
  return AdminController(ref.watch(adminRepositoryProvider));
});

class AdminController extends StateNotifier<bool> {
  final AdminRepository _adminRepository;
  AdminController(this._adminRepository) : super(false);

  Future<void> toggleVerification(String userId, bool currentStatus) async {
    state = true;
    try {
      await _adminRepository.toggleUserVerification(userId, !currentStatus);
    } finally {
      state = false;
    }
  }

  Future<void> toggleUserStatus(String userId, bool newStatus) async {
    state = true;
    try {
      await _adminRepository.toggleUserStatus(userId, newStatus);
    } finally {
      state = false;
    }
  }

  Future<void> deleteAuction(String auctionId) async {
    state = true;
    try {
      await _adminRepository.deleteAuction(auctionId);
    } finally {
      state = false;
    }
  }
}
