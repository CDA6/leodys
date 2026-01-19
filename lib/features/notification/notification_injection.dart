import 'package:get_it/get_it.dart';
import 'data/datasources/notification_local_datasource.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'presentation/controllers/notification_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Controller
  sl.registerFactory(() => NotificationController(sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
        () => NotificationRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<NotificationLocalDataSource>(
        () => NotificationLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSourceImpl(),
  );
}