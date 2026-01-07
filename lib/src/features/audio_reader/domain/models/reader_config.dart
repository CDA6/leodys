/*
Modèle metier qui représente
la configuration de lecture audio pour un text scanné
 */

class ReaderConfig {
  final double speechRate; //Vitesse de lecture
  final String languageCode; // Code de langage
  final String?
  voiceId; // Identifiant de la voix, permet de sélectionner une voix adapter à chaque personne dys
  final bool dysFriendlyMode; // Mode de lecture pour les dys

  /*
  Constructeur constant
  "const" garantit l'immuabilité de l'objet
  les "{}" signifie que les parametre sont nommés,
  l'ordre n'est pas important,
  chaque valeur est associé à un nom
   */
  const ReaderConfig({
    // parametre obligatoire
    required this.speechRate,
    required this.languageCode,
    // parametre facultatif
    this.voiceId,
    this.dysFriendlyMode = true,
  });

  /*
  Configuration par défaut adaptée pour les dys
  defaultConfig est une variable de classe type ReaderConfig
  déclarée "static const"
   */
  static const ReaderConfig defaultConfig = ReaderConfig(
    // les parametres nommés
    speechRate: 0.8,
    languageCode: "fr-FR",
    dysFriendlyMode: true,
  );

  /*
  Permet de créer une nouvelle configuration à partir
  d'une configuration existante.
  Cette méthode prend des parametres nommés et nullable
  Elle retourne un nouvel objet ReaderConfig
   */
  ReaderConfig copyWith({
    double? speechRate,
    String? languageCode,
    String? voiceId,
    bool? dysFriendlyMode,
  }) {
    return ReaderConfig(
      speechRate: speechRate ?? this.speechRate,
      languageCode: languageCode ?? this.languageCode,
      voiceId: voiceId ?? this.voiceId,
      dysFriendlyMode: dysFriendlyMode ?? this.dysFriendlyMode,
    );
  }
}
