// profile_state.dart
import '../../domain/models/user_profile_model.dart';

sealed class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileEmpty extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

abstract class ProfileEditState {}

class ProfileEditInitial extends ProfileEditState {}

class ProfileEditLoading extends ProfileEditState {}

class ProfileEditSuccess extends ProfileEditState {}

class ProfileEditFailure extends ProfileEditState {
  final String message;
  ProfileEditFailure(this.message);
}

