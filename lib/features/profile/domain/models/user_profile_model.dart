class UserProfileModel {
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatarPath; // chemin local
  final String? avatarUrl;  // chemin distant
  final DateTime updatedAt;
  final String syncStatus;

  // contructeur nommé
  UserProfileModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatarPath,
    this.avatarUrl,
    required this.updatedAt,
    required this.syncStatus,
  });

  // copyWith pour mise à jour
  UserProfileModel copyWith({
    String? userId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? avatarPath,
    String? avatarUrl,
    DateTime? updatedAt,
    String? syncStatus,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  @override
  String toString() {
    return 'UserProfileModel{userId: $userId, firstName: $firstName, lastName: $lastName, email: $email, phone: $phone, avatarPath: $avatarPath, avatarUrl: $avatarUrl, updatedAt: $updatedAt, syncStatus: $syncStatus}';
  }
}
