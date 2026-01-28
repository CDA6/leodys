import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/user_profile_model.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import 'profile_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final SaveProfileUsecase saveProfileUsecase;

  ProfileEditCubit(this.saveProfileUsecase) : super(ProfileEditInitial());

  Future<void> saveProfile(UserProfileModel profile) async {
    emit(ProfileEditLoading());
    print(profile.toString());
    final result = await saveProfileUsecase.call(profile);

    result.fold(
          (failure) => emit(ProfileEditFailure(failure.message)),
          (_) => emit(ProfileEditSuccess()),
    );
  }
}
