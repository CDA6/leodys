import 'package:leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements ILocationRepository {
  final GeolocatorDatasource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Stream<GeoPosition> watchPosition() {
    return dataSource
        .getPositionStream()
        .map(
          (p) => GeoPosition(
            latitude: p.latitude,
            longitude: p.longitude,
            accuracy: p.accuracy,
          ),
        )
        .distinct((prev, next) {
          return prev.latitude == next.latitude &&
              prev.longitude == next.longitude &&
              prev.accuracy == next.accuracy;
        });
  }
}
