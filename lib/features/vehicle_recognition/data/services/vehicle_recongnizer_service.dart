import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:leodys/features/vehicle_recognition/domain/models/plate_scan.dart';
import '../../domain/models/vehicle_info.dart';

/// Service chargé de communiquer avec l’API Plate Recognizer
class VehicleRecognizerService {
  static const String _endpoint =
      'https://api.platerecognizer.com/v1/plate-reader/';

  final String? _apiToken = dotenv.env['PLATE_RECOGNIZER_API_KEY'];

  /// Envoie une image à Plate Recognizer et retourne les infos véhicule
  Future<VehicleInfo?> recognizeVehicle(File image) async {
    if (_apiToken == null || _apiToken!.isEmpty) {
      throw Exception('Clé API Plate Recognizer manquante');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(_endpoint),
    );

    request.headers['Authorization'] = 'Token $_apiToken';

    request.files.add(
      await http.MultipartFile.fromPath(
        'upload',
        image.path,
      ),
    );

    request.fields['regions'] = 'fr';
    request.fields['mmc'] = 'true';

    final response = await request.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erreur Plate Recognizer (${response.statusCode}) : $body',
      );
    }

    final Map<String, dynamic> json =
    jsonDecode(body) as Map<String, dynamic>;

    final List results = json['results'] as List? ?? [];

    if (results.isEmpty) {
      return null;
    }


    final Map<String, dynamic> result =
    results.first as Map<String, dynamic>;

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
