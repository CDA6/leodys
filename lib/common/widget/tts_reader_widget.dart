import 'package:flutter/material.dart';
import '../../features/notification/presentation/controllers/tts_controller.dart';

class TtsReaderWidget extends StatefulWidget {
  final String text;
  final Color? iconColor;

  const TtsReaderWidget({
    required this.text,
    this.iconColor,
    super.key,
  });

  @override
  State<TtsReaderWidget> createState() => _TtsReaderWidgetState();
}

class _TtsReaderWidgetState extends State<TtsReaderWidget> {
  final TtsController _ttsController = TtsController();
  bool _isSpeaking = false;

  @override
  void dispose() {
    _ttsController.stop();
    super.dispose();
  }

  void _toggleSpeech() async {
    if (_isSpeaking) {
      await _ttsController.stop();
      setState(() => _isSpeaking = false);
    } else {
      setState(() => _isSpeaking = true);
      await _ttsController.speak(widget.text);
      // On réinitialise l'icône une fois la lecture potentiellement terminée
      // Note: Flutter_tts a des callbacks pour plus de précision (onCompletion)
      setState(() => _isSpeaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.play_circle_fill),
      color: widget.iconColor ?? Colors.blue,
      iconSize: 32,
      onPressed: _toggleSpeech,
      tooltip: "Lire le message",
    );
  }
}