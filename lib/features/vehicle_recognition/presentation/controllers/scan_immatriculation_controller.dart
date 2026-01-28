import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../domain/models/plate_scan.dart';
import '../../domain/usecases/scan_and_identify_vehicle_usecase.dart';

class ScanImmatriculationController extends ChangeNotifier {
  final ScanAndIdentifyVehicleUsecase scanUsecase;

  PlateScan? _result;
  bool _isLoading = false;
  bool _hasScanned = false;

  PlateScan? get result => _result;
  bool get isLoading => _isLoading;
  bool get hasScanned => _hasScanned;

  ScanImmatriculationController({
    required this.scanUsecase,
  });

  /// Lance un scan à partir d’une image capturée (en ligne uniquement)
  Future<void> scan(String imagePath) async {
    _isLoading = true;
    _hasScanned = true;
    notifyListeners();

    try {
      final file = File(imagePath);
      _result = await scanUsecase.execute(file);
    } catch (e) {
      _result = null;
      // Optionnel : AppLogger.error(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _result = null;
    _hasScanned = false;
    notifyListeners();
  }
}
