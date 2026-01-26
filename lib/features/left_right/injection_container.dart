
import 'package:get_it/get_it.dart';
import 'package:leodys/features/left_right/presentation/pose_viewmodel.dart';


import 'data/datasource/pose_datasource.dart';
import 'data/repository/pose_repository_impl.dart';
import 'domain/repository/pose_repository.dart';
import 'domain/usecase/detect_pose_usecase.dart';



final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => PoseViewModel(sl()));
  sl.registerLazySingleton(() => DetectPoseUseCase(sl()));
  sl.registerLazySingleton<PoseRepository>(() => PoseRepositoryImpl(sl()));
  sl.registerLazySingleton(() => PoseDataSource());
  try {
    await sl<PoseDataSource>().loadModel();
    print("[PoseDetection] Modèle TFLite chargé");
  } catch (e) {
    print("[PoseDetection] Erreur chargement modèle : $e");
  }
}