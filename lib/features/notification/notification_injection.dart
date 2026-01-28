import 'package:get_it/get_it.dart';
import 'package:leodys/features/notification/presentation/pages/notification_dashboard_page.dart';
import 'data/datasources/notification_local_datasource.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'data/datasources/email_sender_datasource.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'domain/usecases/send_notification_email.dart';
import 'domain/usecases/sync_message_history.dart';
import 'presentation/controllers/notification_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerFactory(() => SendNotificationEmail(sl()));
  sl.registerFactory(() => SyncMessageHistory(sl()));

  // Controller
  sl.registerFactory(() => NotificationController(sl(), sl(),  sl()));

  // Repository
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(
      localDataSource: sl(),
      remoteMessageDataSource: sl(),
      emailSenderDataSource: sl(),
    ),
  );

  // DataSources
  sl.registerLazySingleton<NotificationLocalDataSource>(
        () => NotificationLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<EmailSenderDataSource>(
        () => EmailSenderDataSourceImpl(),
  );

  sl.registerLazySingleton<NotificationRemoteDataSource>(
        () => NotificationRemoteDataSourceImpl(),
  );

}
