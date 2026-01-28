import 'package:get_it/get_it.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/dataSources/location_search_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_search_repository_impl.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';
import 'package:leodys/features/map/domain/useCases/search_location_usecase.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';

import 'data/repositories/location_repository_impl.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/useCases/watch_user_location_usecase.dart';

final locator = GetIt.instance;

Future<void> init() async {
  setupGeolocator();
  setupLocationSearch();
  setupMapPresentation();
}

void setupGeolocator() {
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
}

void setupLocationSearch() {
  // DataSource
  locator.registerLazySingleton<LocationSearchDatasource>(
    () => LocationSearchDatasource(),
  );

  // Repository
  locator.registerLazySingleton<ILocationSearchRepository>(
    () => LocationSearchRepositoryImpl(locator<LocationSearchDatasource>()),
  );

  // Use Case
  locator.registerLazySingleton<SearchLocationUseCase>(
    () => SearchLocationUseCase(locator<ILocationSearchRepository>()),
  );
}

void setupMapPresentation() {
  // Presentation Layer
  locator.registerLazySingleton<MapViewModel>(
    () => MapViewModel(
      locator<WatchUserLocationUseCase>(),
      locator<SearchLocationUseCase>(),
    ),
    dispose: (param) => param.dispose(),
  );
}
