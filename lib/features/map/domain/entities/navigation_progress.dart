import 'geo_step.dart';

class NavigationProgress {
  final double remainingDistance;
  final double remainingDuration;
  final String? nextInstruction;
  final ManeuverType? maneuverType;

  NavigationProgress({
    required this.remainingDistance,
    required this.remainingDuration,
    this.nextInstruction,
    this.maneuverType,
  });
}
