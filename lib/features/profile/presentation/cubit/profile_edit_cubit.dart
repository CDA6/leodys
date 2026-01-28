import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:leodys/features/profile/presentation/cubit/profile_cubit.dart';

import '../../domain/models/user_profile_model.dart';
import '../../domain/usecases/save_profile_usecase.dart';
import 'profile_state.dart';

class ProfileEditCubit extends Cubit<ProfileEditState> {
  final SaveProfileUsecase saveProfileUsecase;
  final ProfileCubit profileCubit;

  ProfileEditCubit(this.saveProfileUsecase, this.profileCubit) : super(ProfileEditInitial());

  Future<void> saveProfile(UserProfileModel profile) async {
    emit(ProfileEditLoading());
    final result = await saveProfileUsecase.call(profile);

    result.fold(
          (failure) => emit(ProfileEditFailure(failure.message)),
          (updatedProfile) {
            emit(ProfileEditSuccess());
            profileCubit.updateLocalProfile(profile);
      },
    );
  }
}
