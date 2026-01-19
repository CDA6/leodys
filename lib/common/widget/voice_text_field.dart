import 'dart:async';
import 'package:flutter/material.dart';// Import du sl
import '../../features/vocal_notes/data/services/speech_service.dart';
import '../../features/vocal_notes/injection_container.dart';

class VoiceTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int maxLines;

  const VoiceTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    super.key,
  });

  @override
  State<VoiceTextField> createState() => _VoiceTextFieldState();
}

class _VoiceTextFieldState extends State<VoiceTextField> {
  final SpeechService _speechService = sl<SpeechService>();

  StreamSubscription<bool>? _listeningSubscription;
  StreamSubscription<String>? _textSubscription;

  bool _isListening = false;
  String _textBeforeSession = ""; // Pour concaténer au lieu d'écraser

  @override
  void initState() {
    super.initState();
    // Initialisation du service si nécessaire (au cas où)
    _initService();

    // 1. Écouter l'état du micro (ON/OFF)
    _listeningSubscription = _speechService.listening.listen((isListening) {
      if (mounted) {
        setState(() {
          _isListening = isListening;

          // Si on commence à écouter, on sauvegarde le texte actuel
          if (isListening) {
            _textBeforeSession = widget.controller.text;
          }
        });
      }
    });

    // 2. Écouter le texte qui arrive
    _textSubscription = _speechService.speechText.listen((recognizedText) {
      if (mounted && _isListening) {
        // Logique de concaténation : Ancien texte + Espace + Nouveau texte
        final prefix = _textBeforeSession.trim();
        final newPart = recognizedText.trim();

        if (prefix.isEmpty) {
          widget.controller.text = newPart;
        } else {
          widget.controller.text = "$prefix $newPart";
        }

        // Placer le curseur à la fin
        widget.controller.selection = TextSelection.fromPosition(
          TextPosition(offset: widget.controller.text.length),
        );
      }
    });
  }

  Future<void> _initService() async {
    // On s'assure que le service est prêt (demande de permissions, etc.)
    try {
      await _speechService.init();
      if (mounted) setState(() {}); // Rafraichir pour afficher l'icône si besoin
    } catch (e) {
      debugPrint("Erreur init SpeechService: $e");
    }
  }

  @override
  void dispose() {
    _listeningSubscription?.cancel();
    _textSubscription?.cancel();
    // On ne dispose PAS le service ici car il est global !
    super.dispose();
  }

  void _toggleListening() {
    // Si le service n'est pas prêt, on tente de l'initialiser ou on ne fait rien
    if (!_speechService.isInitialized) {
      _initService().then((_) => _speechService.toggleListening());
    } else {
      _speechService.toggleListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    // On affiche le micro seulement si le service a pu s'initialiser
    // ou si on veut permettre à l'utilisateur de tenter l'init au clic
    final bool canShowMic = true;

    return Semantics(
      textField: true,
      label: widget.label,
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        decoration: InputDecoration(
          labelText: widget.label,
          suffixIcon: canShowMic
              ? IconButton(
            icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
            // Rouge si écoute, Bleu sinon
            color: _isListening ? Colors.red : Colors.blue,
            onPressed: _toggleListening,
            tooltip: _isListening ? "Arrêter la dictée" : "Dicter le texte",
          )
              : null,
        ),
      ),
    );
  }
}