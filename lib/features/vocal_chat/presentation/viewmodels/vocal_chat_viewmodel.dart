import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:leodys/features/vocal_notes/data/services/speech_service.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/usecases/send_chat_message_usecase.dart';

/// États de la machine d'état du chat vocal.
enum VocalChatState {
  /// Prêt à recevoir une entrée utilisateur.
  idle,

  /// Écoute de la voix utilisateur (STT actif).
  listening,

  /// Envoi du message au LLM et attente de réponse.
  processing,

  /// Lecture de la réponse (TTS actif).
  speaking,

  /// Erreur survenue.
  error,
}

/// ViewModel pour le chat vocal.
///
/// Gère le flux : écoute -> transcription -> envoi au LLM -> lecture de la réponse.
/// L'historique de conversation est conservé pendant la session et effacé à la sortie.
class VocalChatViewModel extends ChangeNotifier {
  final SpeechService _speechService;
  final SendChatMessageUseCase _sendChatMessageUseCase;

  VocalChatViewModel({
    required SpeechService speechService,
    required SendChatMessageUseCase sendChatMessageUseCase,
  })  : _speechService = speechService,
        _sendChatMessageUseCase = sendChatMessageUseCase;

  // ============================================
  // État
  // ============================================

  VocalChatState _state = VocalChatState.idle;
  String? _errorMessage;
  String _currentTranscription = '';
  final List<ChatMessage> _conversationHistory = [];

  StreamSubscription<String>? _speechTextSub;
  StreamSubscription<bool>? _listeningSub;
  StreamSubscription<bool>? _speakingSub;

  // ============================================
  // Getters
  // ============================================

  /// État actuel de la machine d'état.
  VocalChatState get state => _state;

  /// Message d'erreur si [state] == [VocalChatState.error].
  String? get errorMessage => _errorMessage;

  /// Texte en cours de transcription.
  String get currentTranscription => _currentTranscription;

  /// Historique de la conversation (lecture seule).
  List<ChatMessage> get conversationHistory =>
      List.unmodifiable(_conversationHistory);

  /// Indique si l'état est idle (prêt).
  bool get isIdle => _state == VocalChatState.idle;

  /// Indique si l'écoute est active.
  bool get isListening => _state == VocalChatState.listening;

  /// Indique si le traitement est en cours.
  bool get isProcessing => _state == VocalChatState.processing;

  /// Indique si la lecture TTS est active.
  bool get isSpeaking => _state == VocalChatState.speaking;

  /// Indique si une erreur s'est produite.
  bool get hasError => _state == VocalChatState.error;

  // ============================================
  // Initialisation
  // ============================================

  /// Initialise le service de reconnaissance vocale.
  Future<void> initialize() async {
    try {
      await _speechService.init();
      _setupListeners();
    } on SpeechServiceException catch (e) {
      _state = VocalChatState.error;
      _errorMessage = 'Erreur d\'initialisation: ${e.message}';
      notifyListeners();
    } catch (e) {
      _state = VocalChatState.error;
      _errorMessage = 'Erreur d\'initialisation: $e';
      notifyListeners();
    }
  }

  void _setupListeners() {
    // Écoute du texte reconnu
    _speechTextSub = _speechService.speechText.listen((text) {
      _currentTranscription = text;
      notifyListeners();
    });

    // Écoute de l'état d'écoute (pour sync avec le service)
    _listeningSub = _speechService.listening.listen((isListening) {
      // État géré manuellement par startListening/stopListeningAndProcess
    });

    // Écoute de l'état de parole (pour transition speaking -> idle)
    _speakingSub = _speechService.speaking.listen((isSpeaking) {
      if (!isSpeaking && _state == VocalChatState.speaking) {
        _state = VocalChatState.idle;
        notifyListeners();
      }
    });
  }

  // ============================================
  // Actions
  // ============================================

  /// Démarre l'écoute vocale (appelé quand l'utilisateur appuie sur le micro).
  void startListening() {
    if (_state != VocalChatState.idle) return;

    _currentTranscription = '';
    _errorMessage = null;
    _state = VocalChatState.listening;
    _speechService.startListening();
    notifyListeners();
  }

  /// Arrête l'écoute et traite le message (appelé quand l'utilisateur relâche le micro).
  Future<void> stopListeningAndProcess() async {
    if (_state != VocalChatState.listening) return;

    _speechService.stopListening();

    // Petit délai pour s'assurer que la dernière transcription est capturée
    await Future.delayed(const Duration(milliseconds: 300));

    final userText = _currentTranscription.trim();

    // Gestion du prompt vide
    if (userText.isEmpty) {
      _state = VocalChatState.speaking;
      notifyListeners();
      _speechService.speak('Appuyez sur le bouton pour parler');
      return;
    }

    // Passer en mode traitement
    _state = VocalChatState.processing;
    notifyListeners();

    await _sendToLLM(userText);
  }

  Future<void> _sendToLLM(String userText) async {
    // Ajouter le message utilisateur à l'historique
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: userText,
      timestamp: DateTime.now(),
    );
    _conversationHistory.add(userMessage);

    // Appeler le use case
    final result = await _sendChatMessageUseCase.call(
      SendChatMessageParams(
        conversationHistory: _conversationHistory,
        userMessage: userText,
      ),
    );

    result.fold(
      (failure) {
        _state = VocalChatState.error;
        _errorMessage = failure.message;
        notifyListeners();
      },
      (response) {
        // Ajouter la réponse de l'assistant à l'historique
        final assistantMessage = ChatMessage(
          id: const Uuid().v4(),
          role: ChatRole.assistant,
          content: response,
          timestamp: DateTime.now(),
        );
        _conversationHistory.add(assistantMessage);

        // Lire la réponse
        _state = VocalChatState.speaking;
        notifyListeners();
        _speechService.speak(response);
      },
    );
  }

  /// Efface l'historique de conversation.
  void clearHistory() {
    _conversationHistory.clear();
    notifyListeners();
  }

  /// Arrête la lecture vocale en cours.
  void stopSpeaking() {
    if (_state == VocalChatState.speaking) {
      _speechService.stopSpeaking();
      _state = VocalChatState.idle;
      notifyListeners();
    }
  }

  /// Réinitialise l'état après une erreur.
  void resetError() {
    if (_state == VocalChatState.error) {
      _state = VocalChatState.idle;
      _errorMessage = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _speechTextSub?.cancel();
    _listeningSub?.cancel();
    _speakingSub?.cancel();
    super.dispose();
  }
}
