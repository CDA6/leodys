import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/presentation/widgets/reusable/elevated_bouncing_button.dart';

class NavigationConfirmOverlay extends StatelessWidget {
  final GeoPath path;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const NavigationConfirmOverlay({
    super.key,
    required this.path,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.secondaryContainer,
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Trajet trouvé : ${(path.totalDistance / 1000).toStringAsFixed(1)} km",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: context.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Durée estimée : ${(path.totalDuration / 60).round()} min",
              style: TextStyle(color: context.colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: context.stateColors.warning,
                    foregroundColor: context.stateColors.onWarning,
                  ),
                  child: const Text("Annuler"),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedBouncingButton(
                    onPressed: onConfirm,
                    icon: Icon(Icons.done),
                    text: Text("Démarrer"),
                    backgroundColor: context.stateColors.success,
                    foregroundColor: context.stateColors.onSuccess,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
