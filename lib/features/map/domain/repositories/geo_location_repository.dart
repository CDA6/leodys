import 'package:dartz/dartz.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';

import '../failures/gps_failures.dart';

abstract class GeoLocationRepository {
  GeoPosition? getLastCachedPosition();
  Stream<Either<GpsFailure, GeoPosition>> watchPosition();
}
