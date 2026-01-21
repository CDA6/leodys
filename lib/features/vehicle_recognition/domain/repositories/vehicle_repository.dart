
/// Classe abstraite de la couche domaine
/// Déterminer les contrats métiers
/// Son objectif est l'identification d'un véhicule à
/// partir d'une plaque déjà reconnu
abstract class VehicleRepository {

  /// Identifier un véhicule à partir d'une plaque
  Future<String?> identifyVehicle(String plate);

}