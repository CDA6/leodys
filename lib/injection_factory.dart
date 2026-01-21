import 'package:get_it/get_it.dart';
import 'package:Leodys/src/features/left_right/data/datasource/pose_datasource.dart';
import 'package:Leodys/src/features/left_right/data/repository/pose_repository_impl.dart';
import 'package:Leodys/src/features/left_right/domain/usecase/detect_pose_usecase.dart';
import 'package:Leodys/src/features/left_right/domain/repository/pose_repository.dart';
import 'package:Leodys/src/features/left_right/presentation/pose_viewmodel.dart';


final sl = GetIt.instance;

Future<void> init() async {

  sl.registerFactory(() => PoseViewModel(sl()));
  sl.registerLazySingleton(() => DetectPoseUseCase(sl()));
  sl.registerLazySingleton<PoseRepository>(() => PoseRepositoryImpl(sl()),);
  sl.registerLazySingleton(() => PoseDataSource());
}