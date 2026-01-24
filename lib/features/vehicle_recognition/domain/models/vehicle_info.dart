import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';

/// Cette classe représente un modele de véhicule qui contient des informations
/// du véhicule suite au retour de la reconnaissance de la plaque immatriculation
class VehicleInfo {

  final String plate;
  final String? make;
  final String? model;
  final String? label;

  const VehicleInfo({
    required this.plate,
    required this.make,
    required this.model,
    required this.label,
  });
}