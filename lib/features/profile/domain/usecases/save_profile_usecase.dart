import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/providers.dart';
import 'package:leodys/features/profile/data/repository/profile_repository.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';

class SaveProfileUsecase with UseCaseMixin<dynamic, UserProfileModel>{
  final ProfileRepository repository = getIt<ProfileRepository>();

  @override
  Future<Either<Failure, dynamic>> execute(UserProfileModel profile) {
    return repository.saveProfile(profile);
  }
  
}