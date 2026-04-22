import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';

final appwriteClientProvider = Provider<Client>((ref) {
  final client = Client()
      ..setEndpoint(AppConstants.appwriteEndpoint)
      ..setProject(AppConstants.appwriteProjectId);
  return client;
});

final appwriteAccountProvider = Provider<Account>((ref) {
  return Account(ref.watch(appwriteClientProvider));
});

final appwriteDatabaseProvider = Provider<Databases>((ref) {
  return Databases(ref.watch(appwriteClientProvider));
});
