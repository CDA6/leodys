import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../domain/models/vehicle_info.dart';

/// Service chargé de communiquer avec l’API Plate Recognizer
class VehicleRecognizerService {
  // Déclaration du _endpoint
  // un endpoint est une adresse spécifique d'une API
  // Ici il permet d'envoyer une image afin d'obtenir des informations du véhicule à partir de
  // la plaque immat
  static const String _endpoint =
      'https://api.platerecognizer.com/v1/plate-reader/';

  // Clé api
  final String? _apiToken = dotenv.env['PLATE_RECOGNIZER_API_KEY'];

  /// Envoie une image à Plate Recognizer et retourne les infos véhicule
  Future<VehicleInfo?> recognizeVehicle(File image) async {
    if (_apiToken == null || _apiToken.isEmpty) {
      throw Exception('Clé API Plate Recognizer manquante');
    }

    // déclaration d'une requete multipart qui permet d'envoyer des fichiers
    final request = http.MultipartRequest(
      'POST', // méthode http
      Uri.parse(_endpoint), // destination: le endpoint de l'API
    );

    // Ajouter un en tete http d'authentification avec la clé API comme clé d'acces
    // Authorization est un header HTTP standard utilisé pour prouver l’identité de l’application appelante.
    request.headers['Authorization'] = 'Token $_apiToken';

    // Ajouter à la requete le fichier à analyser
    request.files.add(
      // créer un fichier Multipart à partir un fichier local
      await http.MultipartFile.fromPath(
        // parametre :
        'upload', // nom du champ attendu par API
        image.path, // chemin du fichier image sur l'appareil
      ),
    );

    // Configuration de la reconnaissance.
    // Limité aux plaques francaises
    // Information sur la marque le modele et la couleur
    // fields est une Map<String, String> les types des valeurs sont interprêtées par le serveur
    // selon sa configuration
    // clé: region valeur: fr
    request.fields['regions'] = 'fr';
    // clé: mmc valeur: true
    request.fields['mmc'] = 'true';

    // Envoie de la requete http
    final response = await request.send();
    // Récupere le flux de données retourné par le serveur(bytes) et transforme en chaine de caractere
    // Stream permet de commencer la lecture sans attendre la fin de l'envoie de données
    // car les données arrivent par paquet et de taille variable
    final body = await response.stream.bytesToString();

    // Vérifie si la requete a échoué avec les coes de statut HTTP
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erreur Plate Recognizer (${response.statusCode}) : $body',
      );
    }

    // Déséralisation JSON avec jsonDecode transforme le JSON en structures Dart.
    // Ici en Map<String, Dynamic>
    final Map<String, dynamic> json =
    // as Map<String, dynamic> est un cast pour préciser le type attendu , evite les erreurs
    jsonDecode(body) as Map<String, dynamic>;

    // Récuperation des valeurs que contient la clé results et le casté en list nullable ou valeur
    // par défaut si clé n'exite pas ou null
    // evite les crash
    final List results = json['results'] as List? ?? [];

    // cas ou la plaque n'est pas reconnue
    if (results.isEmpty) {
      return null;
    }

    // récupere le 1er élément du result et précise le type (cast Map)
    final Map<String, dynamic> result =
    results.first as Map<String, dynamic>;

    // Récuperer la plaque
    final String plate =
    (result['plate'] as String).toUpperCase();

// Valeurs par défaut
    String make = 'inconnue';
    String model = 'inconnu';

// Tentative de récupération marque / modèle
    final List? modelMake = result['model_make'] as List?;

    if (modelMake != null && modelMake.isNotEmpty) {
      final Map<String, dynamic> mmc =
      modelMake.first as Map<String, dynamic>;

      make = mmc['make']?.toString() ?? 'inconnue';
      model = mmc['model']?.toString() ?? 'inconnu';
    }

// TEXTE FINAL UNIFIÉ
    final String label = [
      'Plaque d’immatriculation : $plate',
      'Marque : $make',
      'Modèle : $model',
    ].join('\n');

    return VehicleInfo(
      plate: plate,
      make: make,
      model: model,
      label: label,
    );
  }
}
