import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/usecase_mixin.dart';
import 'package:leodys/features/cards/providers.dart';
import 'package:leodys/features/profile/data/repository/profile_repository.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:leodys/features/profile/domain/usecases/sync_profile_usecase.dart';

class SaveProfileUsecase with UseCaseMixin<dynamic, UserProfileModel>{
  final ProfileRepository repository = getIt<ProfileRepository>();
  final SyncProfileUsecase syncManager = getIt<SyncProfileUsecase>();

  @override
  Future<Either<Failure, UserProfileModel>> execute(UserProfileModel profile) async {
    final result = await repository.saveProfile(profile);
    await syncManager.call(profile);
    return result;
  }
  
}