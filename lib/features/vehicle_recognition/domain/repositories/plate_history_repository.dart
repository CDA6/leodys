
import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';

/// Classe abstraite de la couche domaine
/// Elle joue le role d'interface métier
/// Détermine les contrats métiers pour la gestion des résultats de scan de plaques
abstract class PlateHistoryRepository {

  /// Enregistrement le résultat d'un scan
  /// que si le véhicule est reconnu
  Future<void> savePlateScan(PlateScan ps);

  /// Supprimer un scan de plaque existante
  Future<void> deletePlateScan(String plate);

  /// Lister des plaques enregistrées suite un un scan réussi
  Future<List<PlateScan>> getAllPlateScans();

  /// Récuperer une plaque par son numéro d'immatriculation
  Future<PlateScan?> getByPlate(String plate);
}