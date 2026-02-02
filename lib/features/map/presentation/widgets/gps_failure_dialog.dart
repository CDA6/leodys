import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';
import 'package:leodys/features/map/domain/failures/gps_failures.dart';

void showGpsFailureDialog(BuildContext context, GpsFailure failure) {
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
      backgroundColor: context.colorScheme.primaryContainer,
      title: Icon(
        Icons.location_off,
        size: 50,
        color: context.stateColors.warning,
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.colorScheme.onPrimaryContainer),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (showGpsSettings)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: context.stateColors.warning,
              foregroundColor: context.stateColors.onWarning,
            ),
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
            child: Text(
              "Autorisations",
              style: TextStyle(color: context.colorScheme.onSecondaryContainer),
            ),
          ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colorScheme.secondaryContainer,
            foregroundColor: context.colorScheme.onSecondaryContainer,
            elevation: 0, // Pas d'ombre
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text("Retour"),
        ),
      ],
    ),
  );
}
