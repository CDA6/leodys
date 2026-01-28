import 'package:dartz/dartz.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';
import 'package:leodys/features/map/domain/repositories/geo_location_repository.dart';

class WatchUserLocationUseCase {
  final GeoLocationRepository repository;

  WatchUserLocationUseCase(this.repository);

  Stream<Either<GpsFailure, GeoPosition>> call() {
    return repository.watchPosition();
  }
}
