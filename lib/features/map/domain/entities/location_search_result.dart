import 'package:leodys/features/map/domain/entities/geo_position.dart';

class LocationSearchResult {
  final String name;
  final GeoPosition position;

  const LocationSearchResult({required this.name, required this.position});
}
