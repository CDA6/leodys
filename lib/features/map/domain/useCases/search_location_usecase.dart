import 'package:leodys/features/map/domain/entities/location_search_result.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';

import '../entities/geo_position.dart';

class SearchLocationUseCase {
  final ILocationSearchRepository repository;

  SearchLocationUseCase(this.repository);

  Future<List<LocationSearchResult>> call(
    String query,
    GeoPosition centerPos,
    double radiusInKm,
  ) {
    return repository.searchAround(query, centerPos, radiusInKm);
  }
}
