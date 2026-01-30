import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/providers.dart';
import 'package:leodys/features/profile/data/repository/profile_repository.dart';

import '../models/user_profile_model.dart';

class LoadProfileUsecase with UseCaseMixin<UserProfileModel?, void>{
  final ProfileRepository repository = getIt<ProfileRepository>();

  @override
  Future<Either<Failure, UserProfileModel?>> execute(void _) async {
    return await repository.loadProfile();
  }
}