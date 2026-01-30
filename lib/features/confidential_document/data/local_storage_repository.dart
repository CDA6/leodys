import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../../../common/utils/app_logger.dart';

class LocalStorageRepository {
  String? _cachedPath;

  //Méthode pour récupérer le chemin de stockage en local
  //utilisation d'un cache pour ne pas relencer toute la méthode
  Future<String> get _localPath async {
    if (_cachedPath != null) return _cachedPath!;

    final directory = await getApplicationDocumentsDirectory();
    final path = p.join(directory.path, "confidential_images");
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _cachedPath = path;
    return path;
  }

// Enregistrer document
  Future<void> uploadDocument(Uint8List bytes, String title) async {
    final path = await _localPath;
    final localFile = File('$path/$title.enc');
    await localFile.writeAsBytes(bytes);
  }

  //Récupécupération de tous les fichiers avec leur titre
  Future<Map<String, Uint8List>> getAllEncryptedFiles() async {
    Map<String, Uint8List> listFile = {};
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      for (var entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.enc')) {
          final title = entity.path.split('/').last.replaceAll('.enc', '');
          listFile[title] = await entity.readAsBytes();
        }
      }
    }
    return listFile;
  }

  //Récupération de la liste des titres des fichiers en local - info indépendente du registre
  Future<List<String>> getAllTitlesEnc() async {
    List<String> listTitle = [];
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      await for (var entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.enc')) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final title = fileName.replaceAll('.enc', '');
          listTitle.add(title);
        }
      }
    }
    return listTitle;
  }

  //Récupérer un fichier avec .enc en extension par le titre
  Future<Uint8List?> getBytes(String title) async {
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      final filePath = '${dir.path}${Platform.pathSeparator}$title.enc';
      final file = File(filePath);
      if (await file.exists()){
        return await file.readAsBytes();
      }
    }
    return null;
  }

  //Supprimer un document à partir d'un titre
  Future<void> deleteDocument(String title) async {
    try {
      final path = await _localPath;
      final localFile = File('$path/$title.enc');

      if (await localFile.exists()) {
        await localFile.delete();
        AppLogger().info("Fichier local supprimé : $title");
      } else {
        AppLogger().info("Suppression ignorée : le fichier $title n'existe déjà plus.");
      }
    } catch (e) {
      // On capture l'erreur pour éviter que toute la synchro ne s'arrête
      AppLogger().error("Erreur lors de la suppression du fichier $title", error: e);
    }
  }

  //Méthode pour supprimer les fichiers inutil ou devenu illisible
  Future<int> cleanUnwantedFile(Map<String, String> exception) async{
    final path = await _localPath;
    int count = 0;
    Map<String, String> listFile = await getAllTitlesWithExtensions();
//La clé correspond au titre et la clé à l'extension
    for(var file in listFile.keys){
      if(exception[file] != null && exception[file] == listFile[file]) {
        continue;
      } else {
        count ++;
        File localFile = File("$path${Platform.pathSeparator}$file.${listFile[file]}");
        try {
          if (await localFile.exists()) {
            await localFile.delete();
            count++;
          }
        } catch (e) {
          AppLogger().error("Erreur lors de la suppression de $file.${listFile[file]}", error: e);
        }
      }
    }
    return count;
  }

//Récupérer tous mes titres pour faire le nettoyage du dossiers
  Future<Map<String, String>> getAllTitlesWithExtensions() async {
    Map<String, String> titlesWithExtensions = {};
    final path = await _localPath;
    final dir = Directory(path);
    if (await dir.exists()) {
      await for (var entity in dir.list()) {
        if (entity is File) {
          final fileName = entity.path.split(Platform.pathSeparator).last;
          final parts = fileName.split('.');
          if (parts.length > 1) {
            final title = parts.first;
            final extension = parts.last;
            titlesWithExtensions[title] = extension;
          }
        }
      }
    }
    return titlesWithExtensions;
  }

}
