import 'package:flutter/material.dart';
import 'package:leodys/features/map/domain/entities/geo_path.dart';

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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text("Durée estimée : ${(path.totalDuration / 60).round()} min"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text("Annuler"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text("Démarrer"),
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
