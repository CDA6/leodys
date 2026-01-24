import 'dart:io';

import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/plate_history_repository.dart';
import 'package:leodys/features/vehicle_recognition/domain/repositories/vehicle_repository.dart';

/// Cas métier pour scanner une plaque et identifier un véhicule associé
///
class ScanAndIdentifyVehicleUsecase {

  final VehicleRepository vehicleRepository;
  final PlateHistoryRepository plateHistoryRepository;
  ScanAndIdentifyVehicleUsecase({required this.plateHistoryRepository, required this.vehicleRepository});

  /// Méthode de logique métier pour scanner une plaque, retourner un résultat et sauvegarder
  Future<PlateScan?> execute(File image) async{

    // Identifier le véhicule à partir du scan
    final vehicle = await vehicleRepository.identifyVehicle(image);
    // Retourne null si la plaque n'est pas connue
    if (vehicle == null){
      return null;
    }
    // Créer un modele de PlateScan si plaque reconnue
    final plateScan = PlateScan(
        plate: vehicle.plate,
        vehicleLabel: vehicle.label!,);
    // Sauvegarder les bon résultats
    await plateHistoryRepository.savePlateScan(plateScan);
    return plateScan;
  }

}