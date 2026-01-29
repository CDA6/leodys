import 'dart:async';
import 'package:flutter/material.dart';
import '../../features/vocal_notes/injection_container.dart';
import '../../features/vocal_notes/data/services/speech_service.dart';

class TtsReaderWidget extends StatefulWidget {
  final String text;
  final double size;
  final Color? iconColor;

  const TtsReaderWidget({
    required this.text,
    required this.size,
    this.iconColor,
    super.key,
  });

  @override
  State<TtsReaderWidget> createState() => _TtsReaderWidgetState();
}

class _TtsReaderWidgetState extends State<TtsReaderWidget> {
  // On récupère l'instance du service
  final SpeechService _speechService = sl<SpeechService>();


  // Abonnement pour écouter les changements d'état
  StreamSubscription<bool>? _speakingSubscription;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _speechService.init();
    _isSpeaking = _speechService.isSpeaking;

    // On écoute le stream : dès que le service dit "je parle" ou "j'ai fini",
    // on met à jour l'interfaces.
    _speakingSubscription = _speechService.speaking.listen((isSpeaking) {
      if (mounted) {
        setState(() {
          _isSpeaking = isSpeaking;
        });
      }
    });
  }

  @override
  void dispose() {
    // Très important : on annule l'abonnement pour éviter les fuites de mémoire
    _speakingSubscription?.cancel();
    super.dispose();
  }

  void _onTap() {
    // On délègue toute la logique au service
    _speechService.toggleSpeaking(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = _isSpeaking ? "Arrêter la lecture" : "Lire le message";

    return Semantics(
      button: true,
      label: actionLabel,
      child: IconButton(
        icon: Icon(_isSpeaking ? Icons.stop_circle : Icons.play_circle_fill),
        color: widget.iconColor ?? Colors.blue,
        iconSize: widget.size,
        onPressed: _onTap,
        tooltip: actionLabel,
      ),
    );
  }
}