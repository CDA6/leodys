import 'package:flutter/material.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/map/domain/entities/geo_step.dart';
import 'package:leodys/features/map/domain/entities/navigation_progress.dart';

class NavigationInfoOverlay extends StatelessWidget {
  final Stream<NavigationProgress?> progressStream;

  const NavigationInfoOverlay({super.key, required this.progressStream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NavigationProgress?>(
      stream: progressStream,
      builder: (context, snapshot) {
        final progress = snapshot.data;

        if (progress == null || progress.remainingDistance <= 0) {
          return const SizedBox.shrink();
        }

        final String distanceLabel = progress.remainingDistance > 1000
            ? "${(progress.remainingDistance / 1000).toStringAsFixed(1)} km"
            : "${progress.remainingDistance.round()} m";

        final int minutes = (progress.remainingDuration / 60).ceil();
        final String timeLabel = minutes > 0 ? "$minutes min" : "< 1 min";

        return Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (progress.nextInstruction != null)
                _buildInstructionBanner(
                  context,
                  progress.nextInstruction!,
                  progress.maneuverType, // Paramètre ajouté
                ),

              _buildProgressBadge(context, distanceLabel, timeLabel),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInstructionBanner(
    BuildContext context,
    String instruction,
    ManeuverType? maneuver,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.primary,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
      ),
      child: Row(
        children: [
          Icon(
            _getManeuverIcon(maneuver),
            color: context.colorScheme.onPrimary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                color: context.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBadge(
    BuildContext context,
    String distance,
    String time,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(25),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.directions_walk,
            color: context.colorScheme.onSecondaryContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            "$distance • $time",
            style: TextStyle(
              color: context.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getManeuverIcon(ManeuverType? type) {
    switch (type) {
      case ManeuverType.turnLeft:
      case ManeuverType.sharpLeft:
      case ManeuverType.slightLeft:
        return Icons.turn_left;
      case ManeuverType.turnRight:
      case ManeuverType.sharpRight:
      case ManeuverType.slightRight:
        return Icons.turn_right;
      case ManeuverType.arrive:
        return Icons.place;
      case ManeuverType.roundabout:
        return Icons.roundabout_right;
      default:
        return Icons.straight;
    }
  }
}
