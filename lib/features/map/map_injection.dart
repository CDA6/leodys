import 'package:get_it/get_it.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';

import 'data/repositories/location_repository_impl.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/useCases/watch_user_location_usecase.dart';

final locator = GetIt.instance;

Future<void> init() async {
  // DataSources Layer
  locator.registerLazySingleton<GeolocatorDatasource>(
    () => GeolocatorDatasource(),
  );

  locator.registerLazySingleton<ILocationRepository>(
    () => LocationRepositoryImpl(locator<GeolocatorDatasource>()),
  );

  // Domain Layer
  locator.registerLazySingleton<WatchUserLocationUseCase>(
    () => WatchUserLocationUseCase(locator<ILocationRepository>()),
  );

  // Presentation Layer
  locator.registerLazySingleton<MapViewModel>(
    () => MapViewModel(locator<WatchUserLocationUseCase>()),
    dispose: (param) => param.dispose(),
  );
}
