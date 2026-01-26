/// Classe de base représentant une erreur métier dans l'application.
///
/// Toutes les erreurs doivent hériter de cette classe pour assurer
/// une gestion cohérente des erreurs à travers les différentes couches.
abstract class Failure {

  final String message;
  const Failure(this.message);
}

/// Erreur liée à la connectivité réseau.
///
/// Levée lorsque :
/// - Aucune connexion Internet n'est disponible
/// - Le serveur est injoignable
/// - Le timeout de connexion est dépassé
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Erreur survenue lors du traitement OCR.
///
/// Peut inclure :
/// - Erreurs de l'API OCR.space (quota dépassé, clé invalide)
/// - Erreurs de ML Kit (modèle non chargé, format d'image invalide)
/// - Erreurs de reconnaissance (texte illisible, image floue
class OCRFailure extends Failure {
  const OCRFailure(super.message);
}

/// Erreur lors du prétraitement ou de la compression d'image.
///
/// Survient quand :
/// - L'image ne peut pas être décodée
/// - La compression échoue
/// - Le format d'image n'est pas supporté
class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(super.message);
}

/// Erreur liée à la gestion du cache local (Hive).
///
/// Survient quand :
/// - La lecture/écriture dans la base de données locale échoue (ex: fichier corrompu, permissions insuffisantes).
/// - La désérialisation/sérialisation des données échoue (ex: schéma Hive incompatible avec [SettingsModel]).
/// - La boîte Hive n'est pas initialisée ou est inaccessible.
/// - L'opération est interrompue par une erreur système (ex: espace disque insuffisant).
/// ```
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}