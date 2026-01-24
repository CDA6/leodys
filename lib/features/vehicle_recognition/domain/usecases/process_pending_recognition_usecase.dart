import 'dart:io';

import 'package:leodys/features/vehicle_recognition/domain/models/pending_recognition.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/pending_recognition_repository.dart';
import 'package:leodys/features/vehicle_recognition/domain/usecases/scan_and_identify_vehicle_usecase.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../repositories/plate_history_repository.dart';

class ProcessPendingRecognitionUsecase {

  final PendingRecognitionRepository pendingRepository;
  final ScanAndIdentifyVehicleUsecase scanAndIdentifyVehicleUsecase;
  final PlateHistoryRepository plateHistoryRepository;

  ProcessPendingRecognitionUsecase ({
    required this.pendingRepository,
    required this.scanAndIdentifyVehicleUsecase,
    required this.plateHistoryRepository
  });

  Future<void> add (PendingRecognition pending) async{
    await pendingRepository.add(pending);
  }

  Future<List<PendingRecognition>> getAll() async {
   return await pendingRepository.getAll();
  }

  Future<void> remove (String id) async {
    await pendingRepository.remove(id);
  }

  Future<void> clear() async {
    await pendingRepository.clear();
  }

  Future<void> execute() async {
    final List<PendingRecognition> pendings =
    await pendingRepository.getAll();

    for (final pending in pendings) {
      try {
        final File file = File(pending.imagePath);
        final plateScan =
        await scanAndIdentifyVehicleUsecase.execute(file);

        if (plateScan != null) {
          await plateHistoryRepository.savePlateScan(plateScan);
          await pendingRepository.remove(pending.id);
        }
      } catch (_) {
        // catch vide, ignorer volontairement pour eviter de l'arret du traitement
        // en cas de hors réseau la reconnaissance reste en attente et pourra être retentée.
      }
    }
  }

}