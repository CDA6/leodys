import 'package:get_it/get_it.dart';
import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/data/dataSources/location_search_datasource.dart';
import 'package:leodys/features/map/data/dataSources/path_datasource.dart';
import 'package:leodys/features/map/data/repositories/location_search_repository_impl.dart';
import 'package:leodys/features/map/data/repositories/path_repository_impl.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';
import 'package:leodys/features/map/domain/repositories/path_repository.dart';
import 'package:leodys/features/map/domain/useCases/get_path_usecase.dart';
import 'package:leodys/features/map/domain/useCases/search_location_usecase.dart';
import 'package:leodys/features/map/presentation/viewModel/map_view_model.dart';

import 'data/repositories/geo_location_repository_impl.dart';
import 'domain/repositories/geo_location_repository.dart';
import 'domain/useCases/watch_user_location_usecase.dart';

final locator = GetIt.instance;

Future<void> init() async {
  setupGeolocator();
  setupLocationSearch();
  setupPathCalculator();
  setupMapPresentation();
}

void setupGeolocator() {
  // DataSource
  locator.registerLazySingleton<GeolocatorDatasource>(
    () => GeolocatorDatasource(),
  );

  locator.registerLazySingleton<GeoLocationRepository>(
    () => GeoLocationRepositoryImpl(locator<GeolocatorDatasource>()),
  );

  // Domain
  locator.registerLazySingleton<WatchUserLocationUseCase>(
    () => WatchUserLocationUseCase(locator<GeoLocationRepository>()),
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

void setupPathCalculator() {
  // Datasource
  locator.registerLazySingleton<PathDatasource>(() => PathDatasource());

  // Repository
  locator.registerLazySingleton<IPathRepository>(
    () => PathRepositoryImpl(locator<PathDatasource>()),
  );

  // Use Case
  locator.registerLazySingleton<GetPathUseCase>(
    () => GetPathUseCase(locator<IPathRepository>()),
  );
}

void setupMapPresentation() {
  // Presentation Layer
  locator.registerLazySingleton<MapViewModel>(
    () => MapViewModel(
      locator<WatchUserLocationUseCase>(),
      locator<SearchLocationUseCase>(),
      locator<GetPathUseCase>(),
    ),
    dispose: (param) => param.dispose(),
  );
}
