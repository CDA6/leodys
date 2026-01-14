import 'package:Leodys/features/map/domain/entities/geo_position.dart';
import 'package:Leodys/features/map/domain/repositories/location_repository.dart';

class WatchUserLocationUseCase {
  final ILocationRepository repository;

  WatchUserLocationUseCase(this.repository);

  Stream<GeoPosition> call() {
    return repository.watchPosition();
  }
}
