import 'package:get_it/get_it.dart';
import 'package:leodys/features/cards/services/scan_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/data/datasources/local/cards_local_datasource.dart';
import 'package:leodys/features/cards/data/datasources/remote/cards_remote_datasource.dart';
import 'package:leodys/features/cards/data/sync/cards_sync_manager.dart';
import 'package:leodys/features/cards/domain/usecases/delete_card_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/get_local_user_cards_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/save_new_card_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/upload_card_usecase.dart';

import 'domain/usecases/update_card_usecase.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // supabase
  getIt.registerLazySingleton<SupabaseClient>(
        () => Supabase.instance.client,
  );

  // remote datasource
  getIt.registerLazySingleton<CardsRemoteDatasource>(
        () => CardsRemoteDatasource(
      supabase: getIt<SupabaseClient>(),
    ),
  );

  // local datasource
  getIt.registerLazySingleton<CardsLocalDatasource>(
        () => CardsLocalDatasource(),
  );

  // scan service
  getIt.registerLazySingleton<ScanService>(
        () => ScanService(),
  );

  // repository
  getIt.registerLazySingleton<CardsRepository>(
        () => CardsRepository(
      getIt<CardsRemoteDatasource>(),
      getIt<CardsLocalDatasource>(),
    ),
  );

  // sync manager
  getIt.registerLazySingleton<CardSyncManager>(
        () => CardSyncManager(
      local: getIt<CardsLocalDatasource>(),
      remote: getIt<CardsRemoteDatasource>(),
    ),
  );

  // use cases
  getIt.registerLazySingleton<UploadCardUsecase>(
        () => UploadCardUsecase(
      getIt<CardsRepository>(),
    ),
  );

  getIt.registerLazySingleton<SaveNewCardUsecase>(
        () => SaveNewCardUsecase(
      getIt<CardsRepository>(),
      getIt<CardSyncManager>(),
    ),
  );

  getIt.registerLazySingleton<GetLocalUserCardsUsecase>(
        () => GetLocalUserCardsUsecase(
      getIt<CardsRepository>(),
      getIt<CardSyncManager>(),
    ),
  );

  getIt.registerLazySingleton<DeleteCardUsecase>(
        () => DeleteCardUsecase(
      getIt<CardsRepository>(),
      getIt<CardSyncManager>(),
    ),
  );

  getIt.registerLazySingleton<UpdateCardUsecase>(
        () => UpdateCardUsecase(
          getIt<CardsRepository>()
        ),
  );
}
