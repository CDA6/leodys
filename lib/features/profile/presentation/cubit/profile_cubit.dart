import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/user_profile_model.dart';
import '../../domain/usecases/load_profile_usecase.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final LoadProfileUsecase loadProfileUsecase;

  ProfileCubit(this.loadProfileUsecase) : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final result = await loadProfileUsecase.call(null);

    result.fold(
          (failure) {
        emit(ProfileError(failure.message));
      },
          (profile) {
        if (profile == null) {
          emit(ProfileEmpty());
        } else {
          emit(ProfileLoaded(profile));
        }
      },
    );
  }

  void updateLocalProfile(UserProfileModel profile) {
    emit(ProfileLoaded(profile));
  }
}
