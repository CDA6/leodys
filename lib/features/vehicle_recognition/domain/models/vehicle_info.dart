
/// Cette classe représente un modele de véhicule avec des données
/// retournées par l'API Plate recognizer suite à la reconnaissance de la plaque immatriculation
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