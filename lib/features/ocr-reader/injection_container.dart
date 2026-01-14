import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:leodys/core/utils/usecase.dart';
import 'package:leodys/features/ocr-reader/domain/entities/ocr_result.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/base_ocr_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/handwritten_text_viewmodel.dart';
import 'package:leodys/features/ocr-reader/presentation/viewmodels/printed_text_viewmodel.dart';
import 'data/datasources/mlkit_ocr_datasource.dart';
import 'data/datasources/ocrspace_ocr_datasource.dart';
import 'data/repositories/ocr_repository_impl.dart';
import 'domain/repositories/ocr_repository.dart';
import 'domain/usecases/recognize_handwritten_text_usecase.dart';
import 'domain/usecases/recognize_printed_text_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  /// ViewModels
  sl.registerFactory<PrintedTextViewModel>(
        () => PrintedTextViewModel(recognizeTextUseCase: sl<RecognizePrintedTextUseCase>()),
  );

  sl.registerFactory<HandwrittenTextViewModel>(
        () => HandwrittenTextViewModel(recognizeTextUseCase: sl<RecognizeHandwrittenTextUseCase>()),
  );

  /// UseCases
  sl.registerLazySingleton(() => RecognizePrintedTextUseCase(sl()));
  sl.registerLazySingleton(() => RecognizeHandwrittenTextUseCase(sl()));

  /// Repository
  sl.registerLazySingleton<OcrRepository>(
        () => OcrRepositoryImpl(
      mlKitDataSource: sl(),
      ocrSpaceDataSource: sl(),
    ),
  );

  /// DataSources
  sl.registerLazySingleton<MLKitDataSource>(
        () => MLKitDataSourceImpl(),
  );

  sl.registerLazySingleton<OCRSpaceDataSource>(
        () => OCRSpaceDataSourceImpl(),
  );
}