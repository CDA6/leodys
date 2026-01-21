import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:leodys/features/confidential_document/data/local_storage_repository.dart';
import 'package:leodys/features/confidential_document/data/storage_repository.dart';
import 'package:leodys/features/confidential_document/data/sync_registry_repository.dart';
import 'package:leodys/features/confidential_document/domain/entity/status_enum.dart';

import 'entity/fileMetadata.dart';
import 'entity/sunc_success.dart';

class SynchronisationUsecase {
  final LocalStorageRepository _localStorageRepository =
      LocalStorageRepository();
  final RemoteStorageRepository _remoteStorageRepository =
      RemoteStorageRepository();
  final SyncRegistryRepository _syncRegistryRepository =
      SyncRegistryRepository();

  Future<SyncSuccess> synchronisation() async {
    bool allSync = true;
    List<String> remoteDeletionList = [];

    final Set<String> processedTitles = {};

    final List<String> listRemoteTitle = await _remoteStorageRepository
        .getListTitle();
    final Map<String, FileMetadata> metadata = await _syncRegistryRepository
        .loadRegistry();
    try {
      ///Comparaison
      for (String title in listRemoteTitle) {
        final entry = metadata[title];
        //Cas correspondence titre
        if (entry != null) {
          processedTitles.add(title);
          //Cas synchrone  (correspondance titre et marquer synchrone)
          if (entry.status == SyncStatus.synced) {
            continue;
          }
          //Cas supprimer en local mais pas sur supabase
          if (entry.status == SyncStatus.pendingDelete) {
            remoteDeletionList.add(title);
          }
        } else {
          ///Cas pas de correspondance titre
          //Cas ajouter sur supabase mais pas en local (critère absent de la liste métadata)
          Uint8List? bytes = await _remoteStorageRepository.getImage(title);
          if (bytes != null) {
            _localStorageRepository.uploadDocument(bytes, title);
            _syncRegistryRepository.updateEntry(
              FileMetadata(
                title: title,
                status: SyncStatus.synced,
                lastUpdated: DateTime.now(),
              ),
            );
          }
        }
      }
      //Cas supprimé sur supabase mais pas local (critère synchrone mais n'existe plus sur supabase)
      final localOrphans = metadata.keys
          .where((t) => !processedTitles.contains(t))
          .toList();

      for(String title in localOrphans){
        final entry = metadata[title];
        if(entry?.status == SyncStatus.synced) {
          await _localStorageRepository.deleteDocument(title);
          await _syncRegistryRepository.removeEntry(title);
        }
      }

      if (remoteDeletionList.isNotEmpty) {
        allSync = false;
        _remoteStorageRepository.deleteImage(remoteDeletionList);
        for (String title in remoteDeletionList) {
          _syncRegistryRepository.removeEntry(title);
        }
      }
      if (allSync) {
        return SyncSuccess.alreadySync;
      }

      return SyncSuccess.syncCompleted;
    } catch (e) {
      return SyncSuccess.syncFailed;
    }

}


}
