import 'package:leodys/features/map/domain/entities/location_search_result.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';

class SearchLocationUseCase {
  final ILocationSearchRepository repository;

  SearchLocationUseCase(this.repository);

  Future<List<LocationSearchResult>> call(String query) {
    return repository.search(query);
  }
}
