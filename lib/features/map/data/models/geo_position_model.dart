import 'package:leodys/features/map/domain/entities/geo_position.dart';

class GeoPositionModel {
  final double lat;
  final double lng;
  final double accuracy;

  GeoPositionModel(this.lat, this.lng, {this.accuracy = 0});

  GeoPosition toEntity() =>
      GeoPosition(latitude: lat, longitude: lng, accuracy: accuracy);

  static GeoPositionModel fromEntity(GeoPosition entity) => GeoPositionModel(
    entity.latitude,
    entity.longitude,
    accuracy: entity.accuracy,
  );
}
