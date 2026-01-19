import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:leodys/features/confidential_document/data/storage_repository.dart';
import 'package:leodys/features/confidential_document/domain/encrypted_session.dart';
import 'package:leodys/features/confidential_document/domain/encryption_service.dart';
import 'package:leodys/features/confidential_document/domain/entity/decryption_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/picture_download.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveDocumentUsecase {
  StorageRepository _storageRepository = StorageRepository();
  EncryptionService _encryptionService = EncryptionService();
  EncryptionSession session = EncryptionSession();
  //Get the actual user
  User? get user => Supabase.instance.client.auth.currentUser;
  late final userID = user?.id;

  String? returnUser() {
    return user?.email;
  }

  Future<void> saveImage(Uint8List bytes, String title, SecretKey key) async {
    //TODO appliquer le chiffrement
    final encryptByte = await _encryptionService.encryptData(bytes, key);
    if (!kIsWeb) {
      final directory = await getApplicationDocumentsDirectory();
      final localFile = File('${directory.path}/$title.enc');
      await localFile.writeAsBytes(encryptByte);
      print("Fichier chiffré sauvegardé en local : ${localFile.path}");
    }

    _storageRepository.uploadDocument(encryptByte, title);
  }

  Future<DecryptionResult?> getAllImages() async {
    print("Lancement recherhce image dans usecase");
    final SecretKey? key = session.key;
    int errorCount = 0;
List<PictureDownload> listPicture = [];
    final List<String> listTitles = await _storageRepository.getListTitle();
    if(listTitles.isEmpty){
      return null;
    }
    for (String title in listTitles) {
      print("boucle en cours");
      Uint8List? encryptedData = await _storageRepository.getImage(title);
      if(encryptedData != null && encryptedData.isNotEmpty){
        Uint8List? byte = await _encryptionService.decryptData(encryptedData, key!);
        if(byte != null) {
          PictureDownload image = PictureDownload(byte, title);
          listPicture.add(image);
        } else {
          errorCount++;
        }
      }
    }
    return DecryptionResult(listPicture, errorCount);
  }
}
