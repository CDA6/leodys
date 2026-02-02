import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';

abstract class IPathRepository {
  Future<GeoPath> getWalkingPath(GeoPosition start, GeoPosition end);
}
