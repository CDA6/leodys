import 'package:get_it/get_it.dart';
import 'data/datasources/calendar_local_datasource.dart';
import 'data/datasources/calendar_google_datasource.dart';
import 'data/repositories/calendar_repository_impl.dart';
import 'domain/repositories/calendar_repository.dart';
import 'domain/usecases/get_event_for_day.dart';
import 'domain/usecases/add_event.dart';
import 'domain/usecases/update_event.dart';
import 'domain/usecases/delete_event.dart';
import 'domain/usecases/initialize_google_calendar.dart';
import 'domain/usecases/set_google_sync_enabled.dart';
import 'domain/usecases/sync_local_to_google.dart';
import 'domain/usecases/sync_google_to_local.dart';
import 'presentation/viewModels/calendar_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Use Cases
  sl.registerFactory(() => GetEventsForDay(sl()));
  sl.registerFactory(() => AddEvent(sl()));
  sl.registerFactory(() => UpdateEvent(sl()));
  sl.registerFactory(() => DeleteEvent(sl()));
  sl.registerFactory(() => InitializeGoogleCalendar(sl()));
  sl.registerFactory(() => SetGoogleSyncEnabled(sl()));
  sl.registerFactory(() => SyncLocalToGoogle(sl()));
  sl.registerFactory(() => SyncGoogleToLocal(sl()));

  // Controller
  sl.registerFactory(
    () => CalendarController(
      getEventsForDayUseCase: sl(),
      addEventUseCase: sl(),
      updateEventUseCase: sl(),
      deleteEventUseCase: sl(),
      initializeGoogleCalendarUseCase: sl(),
      setGoogleSyncEnabledUseCase: sl(),
      syncLocalToGoogleUseCase: sl(),
      syncGoogleToLocalUseCase: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<CalendarRepository>(
    () => CalendarRepositoryImpl(localDataSource: sl(), googleDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<CalendarLocalDataSource>(
    () => CalendarLocalDataSource(),
  );

  sl.registerLazySingleton<CalendarGoogleDataSource>(
    () => CalendarGoogleDataSource(),
  );
}
