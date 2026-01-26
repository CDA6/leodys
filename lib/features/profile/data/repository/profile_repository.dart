import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';

class ProfileRepository {
  final ProfileLocalDatasource local;
  // final ProfileRemoteDatasource remote;
  const ProfileRepository(
      this.local,
      // this.remote
      );

  Future<Either<Failure, UserProfileModel?>> loadProfile() async {
    try {
      final profile = await local.loadLocalProfile();

      // fichier inexistant = profil jamais créé
      if (profile == null) {
        return const Right(null);
      }

      return Right(profile);
    } on FileSystemException catch (e) {
      return Left(FileFailure(e.message));
    } on FormatException catch (e) {
      return Left(FormatFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, void>> saveProfile(UserProfileModel profile) async {
    return Right(await local.saveLocalProfile(profile));
  }
}