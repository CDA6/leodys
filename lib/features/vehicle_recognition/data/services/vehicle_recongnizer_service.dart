import 'dart:convert'; // transforme JSON en objet dart
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // librairie HTTP util pour envoyer des requetes multipart/form-data
import '../../domain/models/vehicle_info.dart';

/// Classe service
/// Son rôle est e communiquer avec l'API plate recognizer
class VehicleRecognizerService {
  // URL de l'api plate recognizer
  static const String _endpoint = 'https://api.platerecognizer.com/v1/plate-reader/';
  // clé API stocké dans le .env
  final String? _apiToken = dotenv.env['PLATE_RECOGNIZER_API_KEY'];

  /// Méthode asynchrone qui renvoi l'objet Vehicle info
  /// Retourne plus tard l'objet VehicleInfo ou null
  /// Prend en parametre un fichier image
  Future<VehicleInfo?> recognizeVehicle(File image) async {
    // Création de la requete multipart qui peut contenir plusieurs parties(text+binaire(fichier image))
    final request = http.MultipartRequest(
      'POST', // Méthode POST car on envoie un fichier
      Uri.parse(_endpoint), // transforme URL en objet Uri
    );
    if (_apiToken == null || _apiToken!.isEmpty) {
      throw Exception('La clé de l\'api plate recognizer manquante');
    }

    // Ajouter un header HTTP d'authentification (ientifier l'applicatin , vérification les crédits et autorise ou non la requete
    request.headers['Authorization'] = 'Token $_apiToken';
    // Ajouter l'image à la requete HTTP
    request.files.add(
      await http.MultipartFile.fromPath('upload', image.path),
    );

    request.fields['regions'] = 'fr'; // Indique à l'API de privilégier le format des plaques française
    request.fields['mmc'] = 'true'; // Demander le Marque Modele Couleur

    // Envoyer la requete et retourne un http.StreamedResponse (réponse en flux).
    final response = await request.send();
    // Convertir le flux de bytes en texte.
    final body = await response.stream.bytesToString();

    // Leve une exception en cas de retour négatif du serveur
    if (response.statusCode != 200) {
      throw Exception('Erreur de reponse de Plate Recognizer');
    }

    // Tranforme le JSON en structure dart (map/list)
    final json = jsonDecode(body);

    // Vérification du résultat
    if (json['results'] == null || json['results'].isEmpty) {
      return null;
    }

    final result = json['results'][0]; // Récuperer la 1ere et en théorie la seule plaque

    final plate = result['plate']?.toString().toUpperCase();
    final modelMake = result['model_make'];

    if (plate == null || modelMake == null || modelMake.isEmpty) {
      return null;
    }

    // Retouner l'objet VehicleInfo
    return VehicleInfo(
      plate: plate,
      make: modelMake[0]['make'],
      model: modelMake[0]['model'],
    );
  }
}
