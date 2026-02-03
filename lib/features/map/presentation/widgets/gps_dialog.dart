import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void showGpsDialog(BuildContext context, String errorType) {
  String message = "Une erreur est survenue avec le GPS.";
  bool showSettings = errorType == 'GPS_DISABLED';

  if (showSettings) {
    message = "Ton GPS est éteint. Veux-tu l'allumer pour voir la carte ?";
  } else if (errorType == 'GPS_DENIED') {
    message = "L'accès à la position est nécessaire.";
  }

  showDialog(
    context: context,
    barrierDismissible: false,

    builder: (context) => AlertDialog(
      title: const Icon(Icons.location_off, size: 50, color: Colors.orange),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        if (showSettings)
          ElevatedButton(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Paramètres"),
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
