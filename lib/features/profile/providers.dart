import 'package:get_it/get_it.dart';
import 'package:leodys/features/profile/data/datasources/local/profile_local_datasource.dart';
import 'package:leodys/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:leodys/features/profile/data/repository/profile_repository.dart';
import 'package:leodys/features/profile/domain/usecases/load_profile_usecase.dart';
import 'package:leodys/features/profile/domain/usecases/save_profile_usecase.dart';
import 'package:leodys/features/profile/domain/usecases/sync_profile_usecase.dart';
import 'package:leodys/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:leodys/features/profile/presentation/cubit/profile_edit_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final getIt = GetIt.instance;

Future<void> init() async {

  // local datasource
  getIt.registerLazySingleton<ProfileLocalDatasource>(
        () => ProfileLocalDatasource(),
  );

  // remote datasource
  getIt.registerLazySingleton<ProfileRemoteDatasource>(
        () => ProfileRemoteDatasource(
          supabase: getIt<SupabaseClient>(),
        ),
  );

  // repository
  getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepository(
          getIt<ProfileLocalDatasource>(),
          getIt<ProfileRemoteDatasource>()
        ),
  );

//   usecases
  getIt.registerLazySingleton<LoadProfileUsecase>(
        () => LoadProfileUsecase(),
  );

  getIt.registerLazySingleton<SaveProfileUsecase>(
        () => SaveProfileUsecase(),
  );

  getIt.registerLazySingleton<SyncProfileUsecase>(
        () => SyncProfileUsecase(
          repository: getIt<ProfileRepository>()
        ),
  );

  // cubit
  getIt.registerFactory<ProfileCubit>(
        () => ProfileCubit(
      getIt<LoadProfileUsecase>(),
    ),
  );

  getIt.registerFactory<ProfileEditCubit>(
      () => ProfileEditCubit(
        getIt<SaveProfileUsecase>(),
        getIt<ProfileCubit>()
      )
  );

}
