/// Classe représentant un modele de plaque scannée
/// Un label qui contient les caractéristiques sélectionnés d'un véhicule
/// Les caractéristiques sont récupéré via la classe VehicleInfo
class PlateScan {
  final String plate;
  final String vehicleLabel;

  PlateScan({
    required this.plate,
    required this.vehicleLabel
  });
}
