import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:leodys/features/confidential_document/data/local_storage_repository.dart';
import 'package:leodys/features/confidential_document/data/storage_repository.dart';
import 'package:leodys/features/confidential_document/data/sync_registry_repository.dart';
import 'package:leodys/features/confidential_document/domain/encrypted_session.dart';
import 'package:leodys/features/confidential_document/domain/services/encryption_service.dart';
import 'package:leodys/features/confidential_document/domain/entity/fileMetadata.dart';
import 'package:leodys/features/confidential_document/domain/entity/save_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/status_enum.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaveDocumentUsecase {
  final RemoteStorageRepository _remoteStorageRepository =
      RemoteStorageRepository();
  final LocalStorageRepository _localStorageRepository =
      LocalStorageRepository();
  final EncryptionService _encryptionService = EncryptionService();
  EncryptionSession session = EncryptionSession();
  final SyncRegistryRepository _syncRegistryRepository = SyncRegistryRepository();


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
    FileMetadata? metadata;
    SaveResult savRes = SaveResult.failure;
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
      if (localSuccess && remoteSuccess) {
        metadata = FileMetadata(title: title, status: SyncStatus.synced, lastUpdated: DateTime.now());
        savRes = SaveResult.fullSuccess;
      } else if (localSuccess) {
        metadata = FileMetadata(title: title, status: SyncStatus.pendingDownload, lastUpdated: DateTime.now());
        savRes = SaveResult.localOnly;
      } else {
        savRes = SaveResult.failure;
      }

      if(metadata != null) {
     _syncRegistryRepository.updateEntry(metadata);
      }
      return savRes;

    } catch (e) {
      return SaveResult.failure;
    }
  }


}
