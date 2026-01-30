import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:leodys/features/confidential_document/domain/platform/platform_enum.dart';

import '../../../../common/utils/app_logger.dart';
import '../../data/local_storage_repository.dart';
import '../../data/storage_repository.dart';
import '../encrypted_session.dart';
import '../entity/decryption_result.dart';
import '../entity/picture_download.dart';
import '../platform/platform_info.dart';
import '../platform/platform_info_implement.dart';
import '../services/encryption_service.dart';

class GetDocumentUsecase {

  final RemoteStorageRepository _remoteStorageRepository =
  RemoteStorageRepository();
  final LocalStorageRepository _localStorageRepository =
  LocalStorageRepository();
  final EncryptionService _encryptionService = EncryptionService();
  EncryptionSession session = EncryptionSession();
  final PlatformInfo _platformInfo = FlutterPlatformInfo();

  Future<DecryptionResult?> getAllImages(bool hasConnection) async {
    final SecretKey? key = session.key;
    try{
      switch(_platformInfo.platform) {

        case PlatformType.web:
          return _getRemote(hasConnection, key);
        case PlatformType.android:
          return _getLocal(key);
        case PlatformType.windows:
          return _getLocal(key);
      }
    } catch (e){
      AppLogger().error("Erreur lors de la récupération des images en fonction de la platforme ", error: e);
      return null;
    }
  }

  Future<DecryptionResult?> _getLocal(SecretKey? key ) async{
    int errorCount = 0;
    List<PictureDownload> listPicture = [];
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
    return DecryptionResult(listPicture, errorCount);
  }

  Future<DecryptionResult?> _getRemote(bool hasConnection, SecretKey? key) async {
    int errorCount = 0;
    List<PictureDownload> listPicture = [];
    if (hasConnection) {
      final List<String> listTitles = await _remoteStorageRepository
          .getListTitle();
      if (listTitles.isEmpty) {
        return null;
      }
      for (String title in listTitles) {
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
    return DecryptionResult(listPicture, errorCount);
  }
}