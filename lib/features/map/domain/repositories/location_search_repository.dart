// features/map/domain/repositories/search_repository.dart
import 'package:leodys/features/map/domain/entities/location_search_result.dart';

abstract class ILocationSearchRepository {
  Future<List<LocationSearchResult>> search(String query);
}
