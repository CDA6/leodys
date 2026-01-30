import 'package:flutter/material.dart';

class CancelNavigationButton extends StatelessWidget {
  final VoidCallback onStop;

  const CancelNavigationButton({super.key, required this.onStop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 90),
      child: FloatingActionButton.extended(
        onPressed: onStop,
        label: const Text("Arrêter le trajet"),
        icon: const Icon(Icons.close),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
    );
  }
}
