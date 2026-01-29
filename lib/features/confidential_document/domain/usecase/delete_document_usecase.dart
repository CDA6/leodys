import 'dart:io';

import 'package:leodys/features/confidential_document/data/local_storage_repository.dart';
import 'package:leodys/features/confidential_document/data/storage_repository.dart';
import 'package:leodys/features/confidential_document/data/sync_registry_repository.dart';
import 'package:leodys/features/confidential_document/domain/entity/delete_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/fileMetadata.dart';
import 'package:leodys/features/confidential_document/domain/platform/platform_enum.dart';
import 'package:leodys/features/confidential_document/domain/platform/platform_info.dart';
import 'package:leodys/features/confidential_document/domain/platform/platform_info_implement.dart';

import '../../../../common/utils/app_logger.dart';
import '../entity/status_enum.dart';

class DeleteDocumentUseCase {
  final LocalStorageRepository _localStorageRepository = LocalStorageRepository();
  final RemoteStorageRepository _remoteStorageRepository = RemoteStorageRepository();
  final _syncRegistryRepository = SyncRegistryRepository();
  final PlatformInfo _platformInfo = FlutterPlatformInfo();

  Future<DeleteResult> deleteDocument(String title, bool hasConnection) async{
    bool remoteDelete = false;
    try{
     if( hasConnection) {
       List<String> tiltes = [title];
       await _remoteStorageRepository.deleteImage(tiltes);
       remoteDelete = true;
     }
     switch (_platformInfo.platform) {
       case PlatformType.web :
         if(remoteDelete) {
           return DeleteResult.deletedRemote;
         } else {
           return DeleteResult.failure;
         }
       case PlatformType.android:
         _localStorageRepository.deleteDocument(title);
         if(remoteDelete) {
           _syncRegistryRepository.removeEntry(title);
           return DeleteResult.deletedAll;
         } else {
           FileMetadata metadata = FileMetadata(title: title, status: SyncStatus.pendingDelete, lastUpdated: DateTime.now());
           _syncRegistryRepository.updateEntry(metadata);
           return DeleteResult.deletedLocal;
         }
       case PlatformType.windows:
         if(remoteDelete) {
           _syncRegistryRepository.removeEntry(title);
           return DeleteResult.deletedAll;
         } else {
           FileMetadata metadata = FileMetadata(title: title, status: SyncStatus.pendingDelete, lastUpdated: DateTime.now());
           _syncRegistryRepository.updateEntry(metadata);
           return DeleteResult.deletedLocal;
         }
       default:
         return DeleteResult.failure;
    }
    }catch (e) {
      AppLogger().error("Erreur lors de la suppression d'un fichier", error: e);
      return DeleteResult.failure;
    }
  }

}