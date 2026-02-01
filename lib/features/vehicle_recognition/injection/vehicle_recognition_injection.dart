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

// Get it utilise le pattern signleton.
// Ici on récupere l'instance global su service locator et on le stock
// dans une variable nommé sl pour service locator

// Get it agit comme un conteneur. tous les services, controller, repo, usecase
// sont enregistrés dans un meme endroit
//

final GetIt sl = GetIt.instance;

void initVehicleRecognition() {

  // registerLazySingleton crée une instance unique à la demande au 1ere utilisation

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

  // registerFactory créer une nouvelle instance à chaque demande
  // Souvent utiliser pour les controllers qui on un cycle de vie court
  sl.registerFactory(
        () => ScanImmatriculationController(
      scanUsecase: sl(),
    ),
  );

  sl.registerFactory(
        () => PlateTtsController(
      speakPlateUsecase: sl(),
      readerConfig: sl(),
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
