
import 'dart:io';

import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';
import 'package:leodys/features/vehicle_recognition/domain/models/vehicle_info.dart';

/// Classe abstraite de la couche domaine
/// Déterminer les contrats métiers
/// Son objectif est l'identification d'un véhicule à
/// partir d'une image
abstract class VehicleRepository {

  /// Identifier un véhicule à partir d'une plaque
  Future<VehicleInfo?> identifyVehicle(File image);

}