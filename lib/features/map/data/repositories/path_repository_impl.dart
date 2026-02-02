import 'package:leodys/features/map/data/dataSources/path_datasource.dart';
import 'package:leodys/features/map/data/models/geo_path_mapper.dart';
import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/repositories/path_repository.dart';

class PathRepositoryImpl implements IPathRepository {
  final PathDatasource dataSource;

  PathRepositoryImpl(this.dataSource);

  @override
  Future<GeoPath> getWalkingPath(GeoPosition start, GeoPosition end) async {
    final jsonResponse = await dataSource.getRawDirections(
      start.toLatLng(),
      end.toLatLng(),
    );
    return GeoPathMapper.fromJson(jsonResponse);
  }
}
