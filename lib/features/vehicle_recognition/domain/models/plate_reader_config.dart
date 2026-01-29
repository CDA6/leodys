/// Modèle metier qui représente
/// la configuration de lecture audio pour un text scanné
class PlateReaderConfig {
  final double speechRate; // Vitesse de lecture
  final double pitch; // Intonation de la voix
  final String languageCode; // Code de langage
  final String? voiceId; // Identifiant de la voix, permet de sélectionner une voix adapter à chaque personne dys
  final bool dysFriendlyMode; // Mode de lecture pour les dys

  ///   Constructeur constant
  ///   "const" garantit l'immuabilité de l'objet
  ///   les "{}" signifie que les parametre sont nommés,
  ///   l'ordre n'est pas important,
  ///   chaque valeur est associé à un nom
  const PlateReaderConfig({
    // parametre obligatoire
    required this.speechRate,
    required this.pitch,
    required this.languageCode,

    // parametre facultatif
    this.voiceId,
    this.dysFriendlyMode = true,
  });

  ///  Configuration par défaut adaptée pour les dys
  ///   defaultConfig est une variable de classe type ReaderConfig
  ///   déclarée "static const"
  static const PlateReaderConfig defaultConfig = PlateReaderConfig(
    // les parametres nommés
    speechRate: 0.5,
    pitch: 1.1,
    languageCode: "fr-FR",
    dysFriendlyMode: true,
  );

  /// Configuration pour un profil d'utilisateur non-dys
  /// Un paramètre de reglage à intégrer dans l'appli si le temps le permet
  static const PlateReaderConfig normalConfig = PlateReaderConfig(
    // les parametres nommés
    speechRate: 1.0,
    pitch: 1.0,
    languageCode: "fr-FR",
    dysFriendlyMode: false,
  );

  ///  Permet de créer une nouvelle configuration personnalisée à partir
  ///   d'une configuration existante.
  ///   Cette méthode prend des parametres nommés et nullable
  ///   Elle retourne un nouvel objet ReaderConfig
  PlateReaderConfig copyWith({
    double? speechRate,
    double? pitch,
    String? languageCode,
    String? voiceId,
    bool? dysFriendlyMode,
  }) {
    return PlateReaderConfig(
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      languageCode: languageCode ?? this.languageCode,
      voiceId: voiceId ?? this.voiceId,
      dysFriendlyMode: dysFriendlyMode ?? this.dysFriendlyMode,
    );
  }
}
