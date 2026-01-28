import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';

void showGpsDialog(BuildContext context, GpsFailure failure) {
  String message = "Une erreur est survenue avec le GPS.";
  bool showGpsSettings = false;
  bool showAppSettings = false;

  if (failure is GpsDisabledFailure) {
    message = "Ton GPS est éteint. Veux-tu l'allumer pour voir la carte ?";
    showGpsSettings = true;
  } else if (failure is GpsPermissionDeniedFailure) {
    message = "L'accès à la position est nécessaire.";
    showAppSettings = true;
  } else if (failure is GpsPermissionForeverDeniedFailure) {
    message =
        "L'autorisation à la position est bloquée définitivement dans les réglages";
    showAppSettings = true;
  }

  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (context) => AlertDialog(
      title: const Icon(Icons.location_off, size: 50, color: Colors.orange),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (showGpsSettings)
          ElevatedButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Activer le GPS"),
          ),

        if (showAppSettings)
          ElevatedButton(
            onPressed: () async {
              await Geolocator.openAppSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Autorisations"),
          ),

        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Close MapScreen to return to HomePage
          },
          child: const Text("Retour"),
        ),
      ],
    ),
  );
}
