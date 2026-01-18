import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:manual_speech_to_text/manual_speech_to_text.dart';

/// Service centralisé pour la reconnaissance vocale (STT) et la synthèse vocale (TTS).
///
/// Ce service expose des streams réactifs pour suivre l'état de l'écoute,
/// de la parole, et le texte reconnu.
class SpeechService {
  final BuildContext _context;
  ManualSttController? _sttController;
  final FlutterTts _tts = FlutterTts();

  SpeechService(this._context);

  final StreamController<String> _speechTextController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _speakingController =
      StreamController<bool>.broadcast();

  bool _isInitialized = false;
  bool _isListening = false;
  bool _isSpeaking = false;

  // ============================================
  // Streams publics
  // ============================================

  /// Stream du texte reconnu par la reconnaissance vocale.
  Stream<String> get speechText => _speechTextController.stream;

  /// Stream de l'état d'écoute (true = en cours d'écoute).
  Stream<bool> get listening => _listeningController.stream;

  /// Stream de l'état de parole (true = en cours de lecture TTS).
  Stream<bool> get speaking => _speakingController.stream;

  // ============================================
  // Getters synchrones pour l'état actuel
  // ============================================

  /// Indique si le service est initialisé.
  bool get isInitialized => _isInitialized;

  /// Indique si le service écoute actuellement.
  bool get isListening => _isListening;

  /// Indique si le service parle actuellement.
  bool get isSpeaking => _isSpeaking;

  // ============================================
  // Initialisation
  // ============================================

  /// Initialise le service STT/TTS.
  ///
  /// Cette méthode doit être appelée par la couche Provider avant utilisation.
  /// Retourne silencieusement si déjà initialisé.
  Future<void> init() async {
    if (_isInitialized) return;

    // Configuration STT avec écoute continue
    _sttController = ManualSttController(_context);
    _sttController!.listen(
      onListeningStateChanged: (ManualSttState state) {
        _isListening = state == ManualSttState.listening;
        _listeningController.add(_isListening);
      },
      onListeningTextChanged: (String text) {
        if (text.isNotEmpty) {
          _speechTextController.add(text);
        }
      },
    );

    // Configuration TTS
    await _tts.setLanguage('fr-FR');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isSpeaking = true;
      _speakingController.add(_isSpeaking);
    });

    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _speakingController.add(_isSpeaking);
    });

    _tts.setErrorHandler((error) {
      _isSpeaking = false;
      _speakingController.add(_isSpeaking);
    });

    _isInitialized = true;
  }

  // ============================================
  // Contrôles STT (Speech-to-Text)
  // ============================================

  /// Démarre l'écoute vocale.
  ///
  /// Les résultats seront émis via le stream [speechText].
  void startListening() {
    _ensureInitialized();
    if (!_isListening) {
      _sttController!.startStt();
    }
  }

  /// Arrête l'écoute vocale.
  void stopListening() {
    if (_isListening) {
      _sttController?.stopStt();
    }
  }

  /// Bascule l'état d'écoute (start/stop).
  void toggleListening() {
    if (_isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  // ============================================
  // Contrôles TTS (Text-to-Speech)
  // ============================================

  /// Lit le texte fourni à haute voix.
  ///
  /// [text] Le texte à lire.
  void speak(String text) {
    _ensureInitialized();
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw SpeechServiceException(
        'Le texte à lire ne peut pas être vide',
        SpeechServiceErrorType.emptyText,
      );
    }
    _tts.speak(trimmedText);
  }

  /// Arrête la lecture vocale en cours.
  void stopSpeaking() {
    if (_isSpeaking) {
      _tts.stop();
    }
  }

  /// Bascule l'état de lecture (start/stop).
  ///
  /// [text] Le texte à lire si la lecture démarre.
  void toggleSpeaking(String text) {
    if (_isSpeaking) {
      stopSpeaking();
    } else {
      speak(text);
    }
  }

  // ============================================
  // Nettoyage
  // ============================================

  /// Libère toutes les ressources du service.
  Future<void> dispose() async {
    _sttController?.dispose();
    await _tts.stop();

    await _speechTextController.close();
    await _listeningController.close();
    await _speakingController.close();

    _isInitialized = false;
  }

  // ============================================
  // Helpers privés
  // ============================================

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw SpeechServiceException(
        'SpeechService non initialisé. Appelez init() d\'abord.',
        SpeechServiceErrorType.notInitialized,
      );
    }
  }
}

// ============================================
// Gestion des erreurs
// ============================================

/// Types d'erreurs possibles du SpeechService.
enum SpeechServiceErrorType {
  notInitialized,
  permissionDenied,
  emptyText,
  unknown,
}

/// Exception spécifique au SpeechService.
class SpeechServiceException implements Exception {
  final String message;
  final SpeechServiceErrorType type;

  const SpeechServiceException(this.message, this.type);

  @override
  String toString() => 'SpeechServiceException: $message';
}
