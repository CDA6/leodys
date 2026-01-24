import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leodys/features/vehicle_recognition/domain/usecases/process_pending_recognition_usecase.dart';
import '../../domain/usecases/is_network_available_usecase.dart';
import '../../domain/repositories/network_status_repository.dart';

class PendingRecognitionController extends ChangeNotifier {

  final ProcessPendingRecognitionUsecase processUsecase;
  final IsNetworkAvailableUsecase networkUsecase;
  final NetworkStatusRepository networkRepository;

  StreamSubscription<bool>? _networkSubscription;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  PendingRecognitionController({
    required this.processUsecase,
    required this.networkUsecase,
    required this.networkRepository,
  });

  /// À appeler au démarrage de l’écran ou de l’application.
  ///
  /// Écoute les changements de connexion réseau.
  void startListeningNetwork() {
    _networkSubscription =
        networkRepository.onConnectionChanged().listen((isConnected) async {
          if (isConnected && !_isProcessing) {
            await processPending();
          }
        });
  }

  /// Arrête l’écoute réseau (important pour éviter les fuites mémoire).
  void stopListeningNetwork() {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }

  /// Lance le traitement des reconnaissances en attente
  /// si la connexion est disponible.
  Future<void> processPending() async {
    final isConnected = await networkUsecase.execute();
    if (!isConnected || _isProcessing) return;

    _isProcessing = true;
    notifyListeners();

    await processUsecase.execute();

    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListeningNetwork();
    super.dispose();
  }
}
