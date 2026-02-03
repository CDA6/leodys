import 'package:leodys/features/map/domain/entities/geo_position.dart';

abstract class ILocationRepository
{
  Stream<GeoPosition> watchPosition();
}
