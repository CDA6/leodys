import 'package:get_it/get_it.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/reader_viewmodel.dart';

import 'data/datasources/mlkit_ocr_datasource.dart';
import 'data/datasources/ocrspace_ocr_datasource.dart';
import 'data/repositories/ocr_repository_impl.dart';
import 'domain/repositories/ocr_repository.dart';
import 'domain/usecases/recognize_text_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ViewModel
  sl.registerFactory(
        () => ReaderViewModel(
      recognizeTextUseCase: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => RecognizeTextUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OcrRepository>(
        () => OcrRepositoryImpl(
      mlKitDataSource: sl(),
      ocrSpaceDataSource: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<MLKitDataSource>(
        () => MLKitDataSourceImpl(),
  );

  sl.registerLazySingleton<OCRSpaceDataSource>(
        () => OCRSpaceDataSourceImpl(),
  );
}