import 'package:flutter/material.dart';
import 'package:leodys/features/map/presentation/widgets/reusable/bouncing_interactable_widget.dart';

class ElevatedBouncingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Icon icon;
  final Text text;
  final Color backgroundColor;
  final Color foregroundColor;
  final int animDurationMs;

  const ElevatedBouncingButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.animDurationMs = 100,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingInteractableWidget(
      animDurationMs: animDurationMs,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        label: text,
        icon: icon,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
      ),
    );
  }
}
