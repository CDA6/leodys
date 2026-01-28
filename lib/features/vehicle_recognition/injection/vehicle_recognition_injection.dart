import 'package:get_it/get_it.dart';
import 'package:leodys/features/vehicle_recognition/data/repositories/plate_tts_repository_impl.dart';
import 'package:leodys/features/vehicle_recognition/data/services/plate_tts_service.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_tts_repository.dart';

// Repositories
import '../data/repositories/plate_history_repository_impl.dart';
import '../data/services/vehicle_recongnizer_service.dart';
import '../domain/models/plate_reader_config.dart';
import '../domain/repositories/vehicle_repository.dart';
import '../domain/repositories/plate_history_repository.dart';

// Data implementations
import '../data/repositories/vehicle_repository_impl.dart';

// Use cases
import '../domain/usecases/scan_and_identify_vehicle_usecase.dart';

// Controllers
import '../domain/usecases/speak_plate_usecase.dart';
import '../presentation/controllers/plate_tts_controller.dart';
import '../presentation/controllers/scan_immatriculation_controller.dart';
import '../presentation/controllers/plate_history_controller.dart';
final GetIt sl = GetIt.instance;

void initVehicleRecognition() {

  sl.registerLazySingleton<PlateReaderConfig>(
        () => PlateReaderConfig.defaultConfig,
  );


  // Services
  sl.registerLazySingleton<VehicleRecognizerService>(
        () => VehicleRecognizerService(),
  );

  sl.registerLazySingleton<PlateTtsService>(
      () => PlateTtsService(),
  );

  // Repositories

  sl.registerLazySingleton<PlateTtsRepository>(
      () => PlateTtsRepositoryImpl(sl<PlateTtsService>(),
      ),
  );

  sl.registerLazySingleton<VehicleRepository>(
        () => VehicleRepositoryImpl(
      sl<VehicleRecognizerService>(),
    ),
  );

  // À adapter selon implémentation existante
  sl.registerLazySingleton<PlateHistoryRepository>(
        () => PlateHistoryRepositoryImpl(),
  );

  // Use cases
  sl.registerLazySingleton(
        () => ScanAndIdentifyVehicleUsecase(
      vehicleRepository: sl(),
      plateHistoryRepository: sl(),
    ),
  );

  sl.registerLazySingleton<SpeakPlateUsecase>(
        () => SpeakPlateUsecase(
      plateTtsRepository: sl(),
    ),
  );


  // Controllers
  sl.registerFactory(
        () => ScanImmatriculationController(
      scanUsecase: sl(),
    ),
  );

  sl.registerFactory(
        () => PlateTtsController(
      speakPlateUsecase: sl(),
      readerConfig: sl(), // déjà utilisé ailleurs (audio reader)
    ),
  );

  sl.registerFactory(
        () => PlateHistoryController(
      sl(),
    ),
  );

}

ScanImmatriculationController createScanImmatriculationController() {
  return sl<ScanImmatriculationController>();
}

PlateHistoryController createPlateHistoryController(){
  return sl<PlateHistoryController>();
}

PlateTtsController createPlateTtsController(){
  return sl<PlateTtsController>();
}
