import 'package:flutter/material.dart';
import 'package:leodys/common/theme/state_color_extension.dart';
import 'package:leodys/common/theme/theme_context_extension.dart';

/// Bouton microphone pour le chat vocal.
///
/// Utilise un GestureDetector pour détecter l'appui et le relâchement.
/// Le bouton change de taille et de couleur selon l'état d'écoute.
class MicButton extends StatelessWidget {
  /// Indique si l'écoute est active.
  final bool isListening;

  /// Indique si le bouton est désactivé.
  final bool isDisabled;

  /// Callback appelé quand l'utilisateur appuie sur le bouton.
  final VoidCallback onPressed;

  /// Callback appelé quand l'utilisateur relâche le bouton.
  final VoidCallback onReleased;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isDisabled,
    required this.onPressed,
    required this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: isDisabled ? null : (_) => onPressed(),
      onPointerUp: isDisabled ? null : (_) => onReleased(),
      onPointerCancel: isDisabled ? null : (_) => onReleased(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isListening ? 100 : 80,
        height: isListening ? 100 : 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(context),
          boxShadow: isListening
              ? [
            BoxShadow(
              color: context.stateColors.error.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ]
              : null,
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          size: isListening ? 48 : 40,
          color: _getIconColor(context),
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isDisabled) {
      return context.colorScheme.outline;
    }
    if (isListening) {
      return context.stateColors.error;
    }
    return context.colorScheme.primary;
  }

  Color _getIconColor(BuildContext context) {
    if (isDisabled) {
      return context.colorScheme.onSurfaceVariant;
    }
    if (isListening) {
      return context.stateColors.onError;
    }
    return context.colorScheme.onPrimary;
  }
}