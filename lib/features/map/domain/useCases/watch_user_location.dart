import 'package:Leodys/features/map/domain/entities/geo_position.dart';
import 'package:Leodys/features/map/domain/repositories/location_repository.dart';

class WatchUserLocation
{
  final ILocationRepository repository;

  WatchUserLocation(this.repository);

  Stream<GeoPosition> call() {
    return repository.watchPosition();
  }
}
