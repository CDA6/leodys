import 'package:Leodys/features/map/data/dataSources/geolocator_datasource.dart';
import 'package:Leodys/features/map/domain/entities/geo_position.dart';
import 'package:Leodys/features/map/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements ILocationRepository
{
  final GeolocatorDatasource dataSource;

  LocationRepositoryImpl(this.dataSource);

  @override
  Stream<GeoPosition> watchPosition() {
    return dataSource.getPositionStream().map(
          (p) => GeoPosition(latitude: p.latitude, longitude: p.longitude),
    );
  }
}
