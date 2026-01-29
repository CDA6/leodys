import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../common/utils/app_logger.dart';
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
      AppLogger().error("Erreur lors du chargement du registre", error: e);
      return {};
    }
  }

  // Sauvegarder tout le registre
  Future<void> saveRegistry(Map<String, FileMetadata> registry) async {
    try {
      final file = await _getRegistryFile();
      final String content = jsonEncode(
        registry.map((key, value) => MapEntry(key, value.toJson())),
      );
      await file.writeAsString(content);
    } catch(e){
      AppLogger().error("Erreur lors de l'enregistrement du registre", error: e);
    }
  }

  // Mettre à jour ou ajouter une seule entrée
  Future<void> updateEntry(FileMetadata metadata) async {
    try {
      final registry = await loadRegistry();
      registry[metadata.title] = metadata;
      await saveRegistry(registry);
    } catch (e) {
      AppLogger().error("Erreur lors de l'update d'une entrée du registre", error: e);
    }
  }

  // Supprimer une entrée du registre
  Future<void> removeEntry(String title) async {
    try {
      final registry = await loadRegistry();
      registry.remove(title);
      await saveRegistry(registry);
    } catch(e) {
      AppLogger().error("Erreur lors de la suppression d'une entrée du registre", error: e);
    }
  }
}