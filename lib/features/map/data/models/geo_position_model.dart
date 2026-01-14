import 'package:Leodys/features/map/domain/entities/geo_position.dart';

class GeoPositionModel
{
  final double lat;
  final double lng;

  GeoPositionModel(this.lat, this.lng);

  GeoPosition toEntity() => GeoPosition(latitude: lat, longitude: lng);
}
