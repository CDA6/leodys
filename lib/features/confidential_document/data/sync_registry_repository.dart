import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/entity/fileMetadata.dart';

class SyncRegistryRepository {

  // Récupérer le chemin du fichier sur l'appareil
  Future<File> _getRegistryFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = "${directory.path}/confidential_images";
    final dir = Directory(folderPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return File("$folderPath/register.json");
  }

  // Lire tout le registre
  Future<Map<String, FileMetadata>> loadRegistry() async {
    try {
      final file = await _getRegistryFile();
      if (!await file.exists()) return {};

      final String content = await file.readAsString();
      final Map<String, dynamic> jsonMap = jsonDecode(content);

      return jsonMap.map((key, value) => MapEntry(
        key,
        FileMetadata.fromJson(value),
      ));
    } catch (e) {
      print("Erreur lors du chargement du registre: $e");
      return {};
    }
  }

  // Sauvegarder tout le registre
  Future<void> saveRegistry(Map<String, FileMetadata> registry) async {
    final file = await _getRegistryFile();
    final String content = jsonEncode(
      registry.map((key, value) => MapEntry(key, value.toJson())),
    );
    await file.writeAsString(content);
  }

  // Mettre à jour ou ajouter une seule entrée
  Future<void> updateEntry(FileMetadata metadata) async {
    final registry = await loadRegistry();
    registry[metadata.title] = metadata;
    await saveRegistry(registry);
  }

  // Supprimer une entrée du registre
  Future<void> removeEntry(String title) async {
    final registry = await loadRegistry();
    registry.remove(title);
    await saveRegistry(registry);
  }
}