import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:path_provider/path_provider.dart';

class LocalStorageRepository {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/confidential_images";
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> uploadDocument(Uint8List bytes, String title) async {
    final path = await _localPath;
    final localFile = File('$path/$title.enc');
    await localFile.writeAsBytes(bytes);
    print("Fichier chiffré sauvegardé en local : ${localFile.path}");
  }

 Future<Map<String, Uint8List>> getAllEncryptedFiles() async {
    Map<String, Uint8List> listFile = {};
    final path = await _localPath;
    final dir = Directory(path);
    if(await dir.exists()) {
      for(var entity in dir.listSync()){
        if(entity is File && entity.path.endsWith('.enc')){
          final title = entity.path.split('/').last.replaceAll('.enc', '');
          listFile[title] = await entity.readAsBytes();
        }
      }
    }
      return listFile;
 }

  Future<void> deleteDocument(String title) async {

  }

}