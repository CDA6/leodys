import 'package:get_it/get_it.dart';

import 'data/datasources/mlkit_ocr_datasource.dart';
import 'data/datasources/ocrspace_ocr_datasource.dart';
import 'data/repositories/ocr_repository_impl.dart';

import 'domain/repositories/ocr_repository.dart';
import 'domain/usecases/recognize_handwritten_text_usecase.dart';
import 'domain/usecases/recognize_printed_text_usecase.dart';

import 'presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'presentation/viewmodels/printed_text_viewmodel.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// DataSources
  sl.registerFactory<MLKitDataSource>(() => MLKitDataSourceImpl());

  sl.registerFactory<OCRSpaceDataSource>(() => OCRSpaceDataSourceImpl());

  /// Repository
  sl.registerLazySingleton<OcrRepository>(
        () => OcrRepositoryImpl(
      mlKitDataSource: sl(),
      ocrSpaceDataSource: sl(),
    ),
  );

  /// UseCases
  sl.registerLazySingleton(() => RecognizePrintedTextUseCase(sl()));
  sl.registerLazySingleton(() => RecognizeHandwrittenTextUseCase(sl()));

  /// ViewModels
  sl.registerLazySingleton<PrintedTextViewModel>(
        () => PrintedTextViewModel(recognizeTextUseCase: sl<RecognizePrintedTextUseCase>()),
  );

  sl.registerLazySingleton<HandwrittenTextViewModel>(
        () => HandwrittenTextViewModel(recognizeTextUseCase: sl<RecognizeHandwrittenTextUseCase>()),
  );
}