import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../datasources/remote/profile_remote_datasource.dart';

class ProfileRepository {
  final ProfileLocalDatasource local;
  final ProfileRemoteDatasource remote;
  const ProfileRepository(
      this.local,
      this.remote
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

  Future<Either<Failure, UserProfileModel>> saveProfile(UserProfileModel profile) async {
    try {
      return Right(await local.saveLocalProfile(profile));
    } on StorageException catch(e) {
      return Left(StorageFailure(e.message));
    } on PostgrestException catch (e) {
      return Left(PostgresFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> syncProfile() async {
    final localProfile = await local.loadLocalProfile();
    if(localProfile == null) {
      return Right(null);
    }

    try {
      final remoteProfile = await remote.loadRemoteProfile();

      if (remoteProfile != null &&
          remoteProfile.updatedAt.isAfter(localProfile.updatedAt)) {
        // si le profil distant a été update après le profil local, on écrase le local avec le distant
        await local.saveLocalProfile(remoteProfile);
        return Right(unit);
      } else {
        // Le profil local est plus récent ou pas de distant → upload local
        await remote.uploadProfile(localProfile);

        final updatedProfile = localProfile.copyWith(
          syncStatus: 'SYNCED',
          updatedAt: DateTime.now(),
        );

        await local.saveLocalProfile(updatedProfile);
        return Right(unit);
      }
    } catch (e) {
      // si erreur: conservation du profil local en repassant en pending
      final pendingProfile = localProfile.copyWith(syncStatus: 'PENDING');
      await local.saveLocalProfile(pendingProfile);
      print(e.toString());

      return Left(UnknownFailure(e.toString()));
    }
  }
}