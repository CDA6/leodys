import 'package:leodys/features/authentication/domain/entities/user.dart';

class UserProfileModel {
  final String id;
  final String firstname;
  final String lastname;
  final String email;
  final String phone;
  final String? avatarLocalPath;
  final String? avatarRemotePath;
  final DateTime updatedAt;
  final String syncStatus;

  UserProfileModel(this.id, this.firstname, this.lastname, this.email,
      this.phone, this.avatarLocalPath, this.avatarRemotePath, this.updatedAt,
      this.syncStatus);
}