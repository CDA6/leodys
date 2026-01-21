import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:leodys/features/confidential_document/data/local_storage_repository.dart';
import 'package:leodys/features/confidential_document/data/storage_repository.dart';
import 'package:leodys/features/confidential_document/domain/encrypted_session.dart';
import 'package:leodys/features/confidential_document/domain/encryption_service.dart';
import 'package:leodys/features/confidential_document/domain/entity/decryption_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/picture_download.dart';
import 'package:leodys/features/confidential_document/domain/entity/save_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveDocumentUsecase {
  final RemoteStorageRepository _remoteStorageRepository =
      RemoteStorageRepository();
  final LocalStorageRepository _localStorageRepository =
      LocalStorageRepository();
  final EncryptionService _encryptionService = EncryptionService();
  EncryptionSession session = EncryptionSession();

  //Get the actual user
  User? get user => Supabase.instance.client.auth.currentUser;
  late final userID = user?.id;

  String? returnUser() {
    return user?.email;
  }

  Future<SaveResult> saveImage(
    Uint8List bytes,
    String title,
    SecretKey key,
  ) async {
    bool localSuccess = false;
    bool remoteSuccess = false;
    try {
      if (bytes.isEmpty) throw Exception("L'image est vide");
      if (title.trim().isEmpty) throw Exception("Le titre est invalide");
      final encryptByte = await _encryptionService.encryptData(bytes, key);

      if (!kIsWeb) {
        try {
          await _localStorageRepository.uploadDocument(encryptByte, title);
          localSuccess = true;
        } catch (e) {
          print("Erreur disque : $e");
        }
      } else {
        localSuccess =
            true; // On considère OK sur Web car pas de stockage local
      }
      try {
        await _remoteStorageRepository.uploadDocument(encryptByte, title);
        remoteSuccess = true;
      } catch (e) {
        print("Erreur réseau : $e");
      }
      ;
      if (localSuccess && remoteSuccess) return SaveResult.fullSuccess;
      if (localSuccess) return SaveResult.localOnly;
      return SaveResult.failure;
    } catch (e) {
      return SaveResult.failure;
    }
  }

  Future<DecryptionResult?> getAllImages(bool hasConnection) async {
    print("Lancement recherhce image dans usecase");
    final SecretKey? key = session.key;
    int errorCount = 0;
    List<PictureDownload> listPicture = [];

    //Récupération du local hors-ligne
    if (!hasConnection) {
      final Map<String, Uint8List> listFile = await _localStorageRepository
          .getAllEncryptedFiles();
      if (listFile.isEmpty) {
        return null;
      }
      for (var file in listFile.entries) {
        final String title = file.key;
        final Uint8List encryptedData = file.value;
        Uint8List? byte = await _encryptionService.decryptData(
          encryptedData,
          key!,
        );
        if (byte != null) {
          PictureDownload image = PictureDownload(byte, title);
          listPicture.add(image);
        } else {
          errorCount++;
        }
      }
    }
    ///Récupération seulement sur le remote storage et pas de local
    if (hasConnection && kIsWeb) {
      final List<String> listTitles = await _remoteStorageRepository
          .getListTitle();
      if (listTitles.isEmpty) {
        return null;
      }
      for (String title in listTitles) {
        print("boucle en cours");
        Uint8List? encryptedData = await _remoteStorageRepository.getImage(
          title,
        );
        if (encryptedData != null && encryptedData.isNotEmpty) {
          Uint8List? byte = await _encryptionService.decryptData(
            encryptedData,
            key!,
          );
          if (byte != null) {
            PictureDownload image = PictureDownload(byte, title);
            listPicture.add(image);
          } else {
            errorCount++;
          }
        }
      }
    }
    //TODO local et en ligne

    return DecryptionResult(listPicture, errorCount);
  }
}
