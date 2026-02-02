import 'geo_position.dart';

enum ManeuverType {
  depart,
  arrive,
  turnLeft,
  turnRight,
  sharpLeft,
  sharpRight,
  slightLeft,
  slightRight,
  straight,
  roundabout,
  unknown,
}

class GeoStep {
  final String instruction; // ex: "Tournez à gauche dans la rue de la Paix"
  final GeoPosition position;
  final double distance;
  final ManeuverType maneuver;

  const GeoStep({
    required this.instruction,
    required this.position,
    required this.distance,
    required this.maneuver,
  });
}
