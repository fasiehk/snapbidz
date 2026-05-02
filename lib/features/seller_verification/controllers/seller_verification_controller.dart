import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../repositories/seller_verification_repository.dart';

/// Holds the current user's seller profile (null = not yet loaded or doesn't exist)
final sellerProfileProvider =
    StateNotifierProvider<SellerProfileController, AsyncValue<UserProfileModel?>>((ref) {
  return SellerProfileController(ref.watch(sellerVerificationRepositoryProvider));
});

class SellerProfileController
    extends StateNotifier<AsyncValue<UserProfileModel?>> {
  final SellerVerificationRepository _repo;

  SellerProfileController(this._repo) : super(const AsyncValue.data(null));

  /// Load the profile for this userId (call once after login)
  Future<void> loadProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repo.getProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Submit a new seller profile
  Future<void> submitProfile(UserProfileModel profile) async {
    state = const AsyncValue.loading();
    try {
      final cnicExists = await _repo.checkCnicExists(profile.cnic);
      if (cnicExists) {
        throw Exception('A profile with this CNIC already exists.');
      }
      final created = await _repo.createProfile(profile);
      state = AsyncValue.data(created);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Check (without loading state) — returns true if profile is complete
  Future<bool> isProfileComplete(String userId) async {
    try {
      final profile = await _repo.getProfile(userId);
      return profile != null && profile.isComplete;
    } catch (_) {
      return false;
    }
  }
}
