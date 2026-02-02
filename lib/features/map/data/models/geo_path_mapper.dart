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
        final maneuver = step['maneuver'];
        final String type = maneuver['type'] ?? "";
        final String? modifier = maneuver['modifier'];
        final String streetName = step['name'] ?? "";

        steps.add(
          GeoStep(
            instruction: _generateInstruction(type, modifier, streetName),
            distance: (step['distance'] as num).toDouble(),
            position: GeoPosition(
              latitude: (maneuver['location'][1] as num).toDouble(),
              longitude: (maneuver['location'][0] as num).toDouble(),
            ),
            maneuver: _mapManeuverType(type, modifier),
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
    if (type.contains('roundabout')) return ManeuverType.roundabout;

    if (modifier != null) {
      if (modifier == 'left') return ManeuverType.turnLeft;
      if (modifier == 'right') return ManeuverType.turnRight;
      if (modifier == 'sharp left') return ManeuverType.sharpLeft;
      if (modifier == 'sharp right') return ManeuverType.sharpRight;
      if (modifier == 'slight left') return ManeuverType.slightLeft;
      if (modifier == 'slight right') return ManeuverType.slightRight;
    }

    return ManeuverType.straight;
  }

  static String _generateInstruction(
    String type,
    String? modifier,
    String streetName,
  ) {
    final street = streetName.isNotEmpty ? " sur $streetName" : "";

    if (type == 'depart') return "Démarrez votre trajet$street";
    if (type == 'arrive') return "Vous êtes arrivé à destination";

    String direction = "Continuez tout droit";

    if (modifier != null) {
      switch (modifier) {
        case 'left':
          direction = "Tournez à gauche";
          break;
        case 'right':
          direction = "Tournez à droite";
          break;
        case 'sharp left':
          direction = "Prenez franchement à gauche";
          break;
        case 'sharp right':
          direction = "Prenez franchement à droite";
          break;
        case 'slight left':
          direction = "Légèrement à gauche";
          break;
        case 'slight right':
          direction = "Légèrement à droite";
          break;
        case 'uturn':
          direction = "Faites demi-tour";
          break;
      }
    }

    return "$direction$street";
  }
}
