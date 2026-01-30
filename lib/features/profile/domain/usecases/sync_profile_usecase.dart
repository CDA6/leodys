import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/profile/data/repository/profile_repository.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';

class SyncProfileUsecase with UseCaseMixin<void, UserProfileModel>{
  final ProfileRepository repository;
  const SyncProfileUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> execute(UserProfileModel profile) {
    return repository.syncProfile(profile);
  }

}