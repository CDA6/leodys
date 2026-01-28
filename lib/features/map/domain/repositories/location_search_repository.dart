// features/map/domain/repositories/search_repository.dart
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/entities/location_search_result.dart';

abstract class ILocationSearchRepository {
  Future<List<LocationSearchResult>> searchAround(
    String query,
    GeoPosition centerPos,
    double radiusInKm,
  );
}
