import 'package:flutter/foundation.dart';
import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';
import 'package:leodys/features/text_simplification/domain/usecases/delete_simplification_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/get_all_simplifications_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/save_simplification_usecase.dart';
import 'package:leodys/features/text_simplification/domain/usecases/simplify_text_usecase.dart';
import 'package:uuid/uuid.dart';

/// Etat possible du ViewModel.
enum TextSimplificationStatus {
  /// Etat initial, pret a recevoir du texte.
  idle,

  /// Simplification en cours via le LLM.
  processing,

  /// Simplification terminee avec succes.
  success,

  /// Erreur lors de la simplification.
  error,
}

/// ViewModel pour la gestion d'etat de la simplification de texte.
class TextSimplificationViewModel extends ChangeNotifier {
  final SimplifyTextUseCase _simplifyTextUseCase;
  final GetAllSimplificationsUseCase _getAllUseCase;
  final SaveSimplificationUseCase _saveUseCase;
  final DeleteSimplificationUseCase _deleteUseCase;

  TextSimplificationViewModel({
    required SimplifyTextUseCase simplifyTextUseCase,
    required GetAllSimplificationsUseCase getAllUseCase,
    required SaveSimplificationUseCase saveUseCase,
    required DeleteSimplificationUseCase deleteUseCase,
  })  : _simplifyTextUseCase = simplifyTextUseCase,
        _getAllUseCase = getAllUseCase,
        _saveUseCase = saveUseCase,
        _deleteUseCase = deleteUseCase;

  // ============================================
  // Etat
  // ============================================

  TextSimplificationStatus _status = TextSimplificationStatus.idle;
  String? _errorMessage;
  String _inputText = '';
  TextSimplificationEntity? _currentResult;
  List<TextSimplificationEntity> _history = [];
  bool _isLoadingHistory = false;

  // ============================================
  // Getters
  // ============================================

  /// Statut actuel du ViewModel.
  TextSimplificationStatus get status => _status;

  /// Message d'erreur si [status] == [TextSimplificationStatus.error].
  String? get errorMessage => _errorMessage;

  /// Texte saisi par l'utilisateur.
  String get inputText => _inputText;

  /// Resultat de la derniere simplification.
  TextSimplificationEntity? get currentResult => _currentResult;

  /// Historique des simplifications.
  List<TextSimplificationEntity> get history => _history;

  /// Indique si l'historique est en cours de chargement.
  bool get isLoadingHistory => _isLoadingHistory;

  /// Indique si une simplification est en cours.
  bool get isProcessing => _status == TextSimplificationStatus.processing;

  /// Indique si le ViewModel est pret.
  bool get isIdle => _status == TextSimplificationStatus.idle;

  /// Indique si une erreur s'est produite.
  bool get hasError => _status == TextSimplificationStatus.error;

  /// Indique si une simplification a reussi.
  bool get hasResult => _status == TextSimplificationStatus.success;

  // ============================================
  // Actions
  // ============================================

  /// Met a jour le texte d'entree.
  void setInputText(String text) {
    _inputText = text;
    notifyListeners();
  }

  /// Simplifie le texte saisi.
  Future<void> simplifyText() async {
    if (_inputText.trim().isEmpty) {
      _errorMessage = 'Veuillez entrer du texte a simplifier';
      _status = TextSimplificationStatus.error;
      notifyListeners();
      return;
    }

    _status = TextSimplificationStatus.processing;
    _errorMessage = null;
    notifyListeners();

    final result = await _simplifyTextUseCase.execute(_inputText);

    await result.fold(
      (failure) async {
        _errorMessage = failure.message;
        _status = TextSimplificationStatus.error;
      },
      (simplifiedText) async {
        // Creer l'entite et la sauvegarder
        final entity = TextSimplificationEntity(
          id: const Uuid().v4(),
          originalText: _inputText,
          simplifiedText: simplifiedText,
          createdAt: DateTime.now().toUtc(),
          updatedAt: DateTime.now().toUtc(),
        );

        // Sauvegarder en local et distant
        await _saveUseCase.execute(entity);

        _currentResult = entity;
        _status = TextSimplificationStatus.success;

        // Recharger l'historique
        await loadHistory();
      },
    );

    notifyListeners();
  }

  /// Charge l'historique des simplifications.
  Future<void> loadHistory() async {
    _isLoadingHistory = true;
    notifyListeners();

    final result = await _getAllUseCase.execute();
    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (items) {
        _history = items;
      },
    );

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Supprime une simplification de l'historique.
  Future<void> deleteItem(String id) async {
    final result = await _deleteUseCase.execute(id);
    result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
      },
      (_) {
        _history.removeWhere((item) => item.id == id);
        notifyListeners();
      },
    );
  }

  /// Reinitialise l'etat pour une nouvelle simplification.
  void reset() {
    _inputText = '';
    _currentResult = null;
    _errorMessage = null;
    _status = TextSimplificationStatus.idle;
    notifyListeners();
  }

  /// Efface le message d'erreur et revient a l'etat idle.
  void clearError() {
    _errorMessage = null;
    _status = TextSimplificationStatus.idle;
    notifyListeners();
  }

  /// Selectionne un item de l'historique comme resultat courant.
  void selectFromHistory(TextSimplificationEntity item) {
    _currentResult = item;
    _inputText = item.originalText;
    _status = TextSimplificationStatus.success;
    notifyListeners();
  }
}
