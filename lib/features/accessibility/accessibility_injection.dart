import 'package:get_it/get_it.dart';
import 'package:leodys/features/accessibility/presentation/viewmodels/settings_viewmodel.dart';
import '../../common/theme/app_theme_manager.dart';
import '../../common/utils/app_logger.dart';
import 'data/datasources/local_storage_datasource.dart';
import 'data/repositories/accessibility_repository_impl.dart';
import 'domain/repositories/accessibility_repository.dart';
import 'domain/usecases/get_settings_usecase.dart';
import 'domain/usecases/update_settings_usecase.dart';
import 'domain/usecases/reset_settings_usecase.dart';

final sl = GetIt.instance;

Future<void> init(AppThemeManager themeManager) async {
  try {
    // Data sources
    sl.registerLazySingleton<LocalStorageDatasource>(
          () => HiveLocalStorageDatasource(),
    );

    // Repository
    sl.registerLazySingleton<AccessibilityRepository>(
          () => AccessibilityRepositoryImpl(sl()),
    );

    // Use Cases
    sl.registerLazySingleton(() => GetSettingsUseCase(sl()));
    sl.registerLazySingleton(() => UpdateSettingsUseCase(sl()));
    sl.registerLazySingleton(() => ResetSettingsUseCase(sl()));

    // ViewModels
    sl.registerFactory<SettingsViewModel>(
          () => SettingsViewModel(
        getSettingsUseCase: sl<GetSettingsUseCase>(),
        updateSettingsUseCase: sl<UpdateSettingsUseCase>(),
        resetSettingsUseCase: sl<ResetSettingsUseCase>(),
        themeManager: themeManager,
      ),
    );
    AppLogger().info("Accessibility initialized successfully");

    SettingsViewModel.isAvailable = true;
  } catch (e) {
    AppLogger().error("Failed to initialize Accessibility: $e");
    SettingsViewModel.isAvailable = false;
  }
}
