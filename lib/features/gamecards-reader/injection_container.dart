import 'package:get_it/get_it.dart';

import 'data/datasource/card_model_datasource.dart';
import 'data/repositories/card_detection_repository_impl.dart';

import 'domain/repositories/card_detection_repository.dart';
import 'domain/usecases/detect_cards_usecase.dart';

import 'presentation/viewmodels/gamecard_reader_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// DataSource / Service
  sl.registerLazySingleton<CardModelDatasource>(() => CardModelDatasource());

  /// Repository
  sl.registerLazySingleton<CardDetectionRepository>(
        () => CardDetectionRepositoryImpl(service: sl()),
  );

  /// UseCases
  sl.registerLazySingleton(() => DetectCardsUseCase(repository: sl()));

  /// ViewModels
  sl.registerFactory<GamecardReaderViewModel>(
        () => GamecardReaderViewModel(detectCardsUseCase: sl()),
  );

  /// Model IA
  await sl<CardDetectionRepository>().loadModel();
}