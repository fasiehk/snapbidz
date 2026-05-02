class UserProfileModel {
  final String id;
  final String userId;
  final String fullName;
  final String cnic;
  final String address;
  final List<String> preferredCategories;
  final bool isVerified;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.cnic,
    required this.address,
    required this.preferredCategories,
    this.isVerified = false,
    this.createdAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      fullName: map['fullName'] ?? '',
      cnic: map['cnic'] ?? '',
      address: map['address'] ?? '',
      preferredCategories: map['preferredCategories'] != null
          ? List<String>.from(map['preferredCategories'])
          : [],
      isVerified: map['isVerified'] ?? false,
      createdAt: map['\$createdAt'] != null
          ? DateTime.tryParse(map['\$createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'cnic': cnic,
      'address': address,
      'preferredCategories': preferredCategories,
      'isVerified': isVerified,
    };
  }

  /// True when all required fields are filled
  bool get isComplete =>
      fullName.isNotEmpty &&
      cnic.isNotEmpty &&
      address.isNotEmpty &&
      preferredCategories.isNotEmpty;
}
