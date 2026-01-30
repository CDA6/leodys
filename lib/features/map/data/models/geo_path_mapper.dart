import '../../domain/entities/geo_path.dart';
import '../../domain/entities/geo_position.dart';
import '../../domain/entities/geo_step.dart';

class GeoPathMapper {
  static GeoPath fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final List coords = route['geometry']['coordinates'];
    final List legs = route['legs'];

    // Extract points
    final points = coords
        .map(
          (c) =>
              GeoPosition(latitude: c[1] as double, longitude: c[0] as double),
        )
        .toList();

    // Extract steps
    List<GeoStep> steps = [];
    for (var leg in legs) {
      for (var step in leg['steps']) {
        steps.add(
          GeoStep(
            instruction: step['maneuver']['instruction'] ?? "",
            distance: (step['distance'] as num).toDouble(),
            position: GeoPosition(
              latitude: step['maneuver']['location'][1] as double,
              longitude: step['maneuver']['location'][0] as double,
            ),
            maneuver: _mapManeuverType(
              step['maneuver']['type'],
              step['maneuver']['modifier'],
            ),
          ),
        );
      }
    }

    return GeoPath(
      points: points,
      steps: steps,
      totalDistance: (route['distance'] as num).toDouble(),
      totalDuration: (route['duration'] as num).toDouble(),
    );
  }

  static ManeuverType _mapManeuverType(String type, String? modifier) {
    if (type == 'depart') return ManeuverType.depart;
    if (type == 'arrive') return ManeuverType.arrive;
    if (modifier != null) {
      if (modifier.contains('left')) return ManeuverType.turnLeft;
      if (modifier.contains('right')) return ManeuverType.turnRight;
    }
    return ManeuverType.straight;
  }
}
