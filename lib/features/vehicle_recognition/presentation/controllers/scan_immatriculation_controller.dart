import 'dart:io';

import 'package:flutter/foundation.dart';
import '../../domain/models/pending_recognition.dart';
import '../../domain/models/plate_scan.dart';
import '../../domain/usecases/scan_and_identify_vehicle_usecase.dart';
import '../../domain/usecases/is_network_available_usecase.dart';
import '../../domain/repositories/pending_recognition_repository.dart';

class ScanImmatriculationController extends ChangeNotifier {

  final ScanAndIdentifyVehicleUsecase scanUsecase;
  final IsNetworkAvailableUsecase networkUsecase;
  final PendingRecognitionRepository pendingRepository;

  PlateScan? _result;
  bool _isLoading = false;

  PlateScan? get result => _result;
  bool get isLoading => _isLoading;
  bool _hasScanned = false;
  bool get hasScanned => _hasScanned;

  ScanImmatriculationController({
    required this.scanUsecase,
    required this.networkUsecase,
    required this.pendingRepository,
  });

  /// Lance un scan à partir d’une image capturée.
  ///
  /// - si réseau dispo → reconnaissance immédiate
  /// - sinon → stockage en reconnaissance différée
  Future<void> scan(String imagePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      final isConnected = await networkUsecase.execute();

      if (!isConnected) {
        final pending = PendingRecognition(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          imagePath: imagePath,
          createdAt: DateTime.now(),
        );

        await pendingRepository.add(pending);
        return;
      }
      _hasScanned = true;
      final file = File(imagePath);
      _result = await scanUsecase.execute(file);

    } catch (e) {
      _result = null;
      // Optionnel : logger l’erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void clearResult() {
    _result = null;
    notifyListeners();
  }
}
