import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///Bouton de scan de document
///
class ScanPlateButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed; //VoidCallBack rend le bouton cliquable

  const ScanPlateButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: const Icon(Icons.document_scanner),
      label: Text(isLoading ? 'Scan en cours...' : 'Scanner'),
    );
  }
}
