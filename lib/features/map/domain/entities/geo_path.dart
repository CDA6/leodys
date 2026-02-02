import 'geo_position.dart';
import 'geo_step.dart';

class GeoPath {
  final List<GeoPosition> points;
  final List<GeoStep> steps;
  final double totalDistance;
  final double totalDuration;

  const GeoPath({
    required this.points,
    required this.steps,
    required this.totalDistance,
    required this.totalDuration,
  });

  bool get isEmpty => points.isEmpty;
}
