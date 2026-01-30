import 'package:leodys/features/authentication/domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email});

  factory UserModel.fromSupabase(dynamic supabaseUser) {
    return UserModel(id: supabaseUser.id, email: supabaseUser.email);
  }
}
