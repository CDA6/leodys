import 'package:leodys/features/map/data/dataSources/location_search_datasource.dart';
import 'package:leodys/features/map/domain/repositories/location_search_repository.dart';
import '../../domain/entities/location_search_result.dart';

class LocationSearchRepositoryImpl implements ILocationSearchRepository {
  final LocationSearchDatasource dataSource;
  LocationSearchRepositoryImpl(this.dataSource);

  @override
  Future<List<LocationSearchResult>> search(String query) async {
    final models = await dataSource.searchAddress(query);
    return models.map((m) => m.toEntity()).toList();
  }
}
