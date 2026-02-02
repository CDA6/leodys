import 'geo_position.dart';

class MapCameraCommand {
  final GeoPosition position;
  final double? zoom;

  MapCameraCommand({required this.position, this.zoom});
}
