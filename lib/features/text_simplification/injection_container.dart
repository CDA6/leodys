import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:leodys/features/text_simplification/data/datasources/text_simplification_local_datasource.dart';
import 'package:leodys/features/text_simplification/data/datasources/text_simplification_remote_datasource.dart';
import 'package:leodys/features/text_simplification/data/repositories/text_simplification_repository_impl.dart';
import 'package:leodys/features/text_simplification/domain/repositories/text_simplification_repository.dart';
import 'package:leodys/features/text_simplification/domain/usecases/delete_simplification_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/get_all_simplifications_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/save_simplification_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/simplify_text_usecase.dart';
import 'package:leodys/features/text_simplification/presentation/viewmodels/text_simplification_viewmodel.dart';
import 'package:leodys/features/vocal_chat/data/services/openrouter_service.dart';
import 'package:leodys/features/vocal_chat/injection_container.dart' as vocal_chat;
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

/// Initialise les dependances de la feature text_simplification.
///
/// Note: Cette feature reutilise le [OpenRouterService] enregistre dans vocal_chat.
/// Assurez-vous que vocal_chat.init() est appele avant text_simplification.init().
Future<void> init() async {
  /// Data Sources
  final box = await Hive.openBox('text_simplifications');
  sl.registerLazySingleton<TextSimplificationLocalDataSource>(
    () => TextSimplificationLocalDataSourceImpl(box),
  );

  sl.registerLazySingleton<TextSimplificationRemoteDataSource>(
    () => TextSimplificationRemoteDataSourceImpl(Supabase.instance.client),
  );

  /// Repository - singleton (depend de OpenRouterService et des DataSources)
  sl.registerLazySingleton<TextSimplificationRepository>(
    () => TextSimplificationRepositoryImpl(
      openRouterService: vocal_chat.sl<OpenRouterService>(),
      localDataSource: sl<TextSimplificationLocalDataSource>(),
      remoteDataSource: sl<TextSimplificationRemoteDataSource>(),
    ),
  );

  /// UseCases - singleton (depend de TextSimplificationRepository)
  sl.registerLazySingleton<SimplifyTextUseCase>(
    () => SimplifyTextUseCase(sl<TextSimplificationRepository>()),
  );
  sl.registerLazySingleton<GetAllSimplificationsUseCase>(
    () => GetAllSimplificationsUseCase(sl<TextSimplificationRepository>()),
  );
  sl.registerLazySingleton<SaveSimplificationUseCase>(
    () => SaveSimplificationUseCase(sl<TextSimplificationRepository>()),
  );
  sl.registerLazySingleton<DeleteSimplificationUseCase>(
    () => DeleteSimplificationUseCase(sl<TextSimplificationRepository>()),
  );

  /// ViewModel - factory (nouvelle instance a chaque fois)
  sl.registerFactory<TextSimplificationViewModel>(
    () => TextSimplificationViewModel(
      simplifyTextUseCase: sl<SimplifyTextUseCase>(),
      getAllUseCase: sl<GetAllSimplificationsUseCase>(),
      saveUseCase: sl<SaveSimplificationUseCase>(),
      deleteUseCase: sl<DeleteSimplificationUseCase>(),
    ),
  );
}
