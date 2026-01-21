import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:leodys/features/vocal_notes/data/services/speech_service.dart';
import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/delete_note_usecase.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/get_all_notes_usecase.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/save_note_usecase.dart';
import 'package:uuid/uuid.dart';

/// État possible du ViewModel.
enum VocalNotesStatus {
  /// État initial, en attente d'initialisation.
  initial,

  /// Initialisation en cours.
  loading,

  /// Prêt à être utilisé.
  ready,

  /// Erreur lors de l'initialisation.
  error,
}

/// ViewModel pour la gestion d'état des notes vocales.
///
/// Gère l'initialisation du [SpeechService] et expose un état réactif
/// pour la reconnaissance vocale et la synthèse vocale.
class VocalNotesViewModel extends ChangeNotifier {
  final SpeechService _speechService;
  final GetAllNotesUseCase _getAllNotesUseCase;
  final SaveNoteUseCase _saveNoteUseCase;
  final DeleteNoteUseCase _deleteNoteUseCase;

  VocalNotesViewModel({
    required SpeechService speechService,
    required GetAllNotesUseCase getAllNotesUseCase,
    required SaveNoteUseCase saveNoteUseCase,
    required DeleteNoteUseCase deleteNoteUseCase,
  }) : _speechService = speechService,
       _getAllNotesUseCase = getAllNotesUseCase,
       _saveNoteUseCase = saveNoteUseCase,
       _deleteNoteUseCase = deleteNoteUseCase;

  // ============================================
  // État
  // ============================================

  VocalNotesStatus _status = VocalNotesStatus.initial;
  String? _errorMessage;
  String _recognizedText = '';
  bool _isListening = false;
  bool _isSpeaking = false;

  StreamSubscription<String>? _speechTextSub;
  StreamSubscription<bool>? _listeningSub;
  StreamSubscription<bool>? _speakingSub;

  // ============================================
  // Getters
  // ============================================

  /// Statut actuel du ViewModel.
  VocalNotesStatus get status => _status;

  /// Message d'erreur si [status] == [VocalNotesStatus.error].
  String? get errorMessage => _errorMessage;

  /// Indique si le service est prêt à être utilisé.
  bool get isReady => _status == VocalNotesStatus.ready;

  /// Indique si le service est en cours de chargement.
  bool get isLoading => _status == VocalNotesStatus.loading;

  /// Indique si une erreur s'est produite.
  bool get hasError => _status == VocalNotesStatus.error;

  /// Texte reconnu par la reconnaissance vocale.
  String get recognizedText => _recognizedText;

  /// Indique si le microphone est actif.
  bool get isListening => _isListening;

  /// Indique si une lecture vocale est en cours.
  bool get isSpeaking => _isSpeaking;

  // ============================================
  // Initialisation
  // ============================================

  /// Initialise le service de reconnaissance vocale.
  Future<void> initialize() async {
    if (_status == VocalNotesStatus.loading ||
        _status == VocalNotesStatus.ready) {
      return;
    }

    _status = VocalNotesStatus.loading;
    notifyListeners();

    try {
      await _speechService.init();
      _setupListeners();
      _status = VocalNotesStatus.ready;
    } on SpeechServiceException catch (e) {
      _status = VocalNotesStatus.error;
      _errorMessage = e.message;
    } catch (e) {
      _status = VocalNotesStatus.error;
      _errorMessage = 'Erreur inattendue: $e';
    }

    notifyListeners();
  }

  void _setupListeners() {
    // Écoute du texte reconnu
    _speechTextSub = _speechService.speechText.listen((text) {
      _recognizedText = text;
      notifyListeners();
    });

    // Écoute de l'état d'écoute
    _listeningSub = _speechService.listening.listen((isListening) {
      _isListening = isListening;
      notifyListeners();
    });

    // Écoute de l'état de parole
    _speakingSub = _speechService.speaking.listen((isSpeaking) {
      _isSpeaking = isSpeaking;
      notifyListeners();
    });
  }

  // ============================================
  // Actions STT
  // ============================================

  /// Démarre la reconnaissance vocale.
  void startListening() {
    if (!isReady) return;
    _speechService.startListening();
  }

  /// Arrête la reconnaissance vocale.
  void stopListening() {
    _speechService.stopListening();
  }

  /// Bascule l'état d'écoute.
  void toggleListening() {
    if (_isListening) {
      stopListening();
    } else {
      startListening();
    }
  }

  /// Efface le texte reconnu.
  void clearRecognizedText() {
    _recognizedText = '';
    notifyListeners();
  }

  // ============================================
  // Actions TTS
  // ============================================

  /// Lit le texte fourni à haute voix.
  void speak(String text) {
    if (!isReady) return;
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;
    _speechService.speak(trimmedText);
  }

  /// Arrête la lecture vocale.
  void stopSpeaking() {
    _speechService.stopSpeaking();
  }

  /// Bascule l'état de lecture.
  void toggleSpeaking(String text) {
    if (_isSpeaking) {
      stopSpeaking();
    } else {
      speak(text);
    }
  }

  /// Lit le texte reconnu à haute voix.
  void speakRecognizedText() {
    speak(_recognizedText);
  }

  // ============================================
  // État CRUD
  // ============================================

  List<VocalNoteEntity> _notes = [];
  bool _isLoadingNotes = false;

  List<VocalNoteEntity> get notes => _notes;
  bool get isLoadingNotes => _isLoadingNotes;

  // ============================================
  // Actions CRUD
  // ============================================

  /// Charge toutes les notes.
  Future<void> loadNotes() async {
    _isLoadingNotes = true;
    notifyListeners();

    final result = await _getAllNotesUseCase.call(NoParams());
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _status = VocalNotesStatus.error;
      },
      (notes) {
        _notes = notes;
      },
    );

    _isLoadingNotes = false;
    notifyListeners();
  }

  /// Sauvegarde une note (création ou modification).
  Future<void> saveNote(String title, String content, {String? id}) async {
    _isLoadingNotes = true;
    notifyListeners();

    final note = VocalNoteEntity(
      id: id ?? const Uuid().v4(),
      title: title,
      content: content,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    final result = await _saveNoteUseCase.call(note);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (_) async {
        await loadNotes(); // Recharger la liste
      },
    );

    _isLoadingNotes = false;
    notifyListeners();
  }

  /// Supprime une note.
  Future<void> deleteNote(String id) async {
    final result = await _deleteNoteUseCase.call(id);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _notes.removeWhere((n) => n.id == id);
        notifyListeners();
      },
    );
  }

  // ============================================
  // Getters Service
  // ============================================

  Stream<String> get speechText => _speechService.speechText;

  @override
  void dispose() {
    _speechTextSub?.cancel();
    _listeningSub?.cancel();
    _speakingSub?.cancel();
    super.dispose();
  }
}
