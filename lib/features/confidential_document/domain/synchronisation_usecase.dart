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

  Future<SyncSuccess> synchronisation(bool hasConnection) async {
    if (!hasConnection) return SyncSuccess.syncFailed;
    bool hasChanges = false;
    List<String> remoteDeletionList = [];
    final Set<String> processedTitles = {}; //gestion des fichiers orphelins

    try {
      final List<String> listLocalTitle =  await _localStorageRepository.getAllTitlesEnc();
      final List<String> listRemoteTitle = await _remoteStorageRepository
          .getListTitle();
      final Map<String, FileMetadata> metadata = await _syncRegistryRepository
          .loadRegistry();

      ///Comparaison
      for (String title in listRemoteTitle) {
        final entry = metadata[title];
        processedTitles.add(title); //Fichier présnet sur le serveur
        if (entry == null) {
          //Cas ajouter sur supabase mais pas en local (critère absent de la liste métadata)
          await _downloadAndRegister(title);
          hasChanges = true;
        } else if (entry.status == SyncStatus.pendingDelete) {
          // Cas : Présent sur Supabase mais l'utilisateur veut le supprimer
          remoteDeletionList.add(title);
        }
        }

      //Cas supprimé sur supabase mais pas local (critère synchrone mais n'existe plus sur supabase)
      final localOrphans = metadata.keys
          .where((t) => !processedTitles.contains(t))
          .toList();

      for (String title in localOrphans) {
        final entry = metadata[title];
        if (entry?.status == SyncStatus.synced) {
          await _cleanUpLocalFile(title);
          hasChanges = true;
        } else if (entry?.status == SyncStatus.pendingDownload){
          await _processUploadFilePending(title);
          hasChanges = true;
        }
      }


      if (remoteDeletionList.isNotEmpty) {
        hasChanges = true;
        await _processRemoteDeletions(remoteDeletionList);
      }

      return hasChanges ? SyncSuccess.syncCompleted : SyncSuccess.alreadySync;
    } catch (e) {
      return SyncSuccess.syncFailed;
    }
  }

  ///Méthode privée
  Future<void> _downloadAndRegister(String title) async {
    Uint8List? bytes = await _remoteStorageRepository.getImage(title);
    if (bytes != null) {
      await _localStorageRepository.uploadDocument(bytes, title);
      await _syncRegistryRepository.updateEntry(
        FileMetadata(
          title: title,
          status: SyncStatus.synced,
          lastUpdated: DateTime.now(),
        ),
      );
    }
  }

  Future<void> _cleanUpLocalFile(String title) async {
    await _localStorageRepository.deleteDocument(title);
    await _syncRegistryRepository.removeEntry(title);
  }

  Future<void> _processRemoteDeletions(List<String> titles) async {
    await _remoteStorageRepository.deleteImage(titles);
    for (String title in titles) {
      await _syncRegistryRepository.removeEntry(title);
      await _localStorageRepository.deleteDocument(title);
    }
  }

  Future<void> _processUploadFilePending(String title) async {
    try {
      //Récupérer les bytes et le titre du local
      Uint8List? bytes = await _localStorageRepository.getBytes(title);
      if (bytes != null) {
        //enregistrer sur Supabase
        await _remoteStorageRepository.uploadDocument(bytes, title);
        //mettre à jour le json en indiquant sync
        FileMetadata metadata = FileMetadata(title: title,
            status: SyncStatus.synced,
            lastUpdated: DateTime.now());
        _syncRegistryRepository.updateEntry(metadata);
      }
    }catch(e) {
      print(e);
    }
  }



  //Permet de nettoyer les fichiers qui ne sont pas référencer - transformer en opération de maintenance
  Future<void> cleanFilePhone() async{
    //TODO nettoyer le dossier du téléphone
    try{
      final List<String> listLocalTitle =  await _localStorageRepository.getAllTitlesEnc();
      final Map<String, FileMetadata> metadata = await _syncRegistryRepository
          .loadRegistry();

    //Supprimer les fichiers qui ne sont pas référencer dans le json
      Map<String, String> indexFileJson = {};
      indexFileJson["register"] = "json";
      for(String title in metadata.keys){
        indexFileJson[title] = "enc";
      }
      //TODO récupérer le count pour informer les log
      _localStorageRepository.cleanUnwantedFile(indexFileJson);

    //Supprimer les enregistrement json qui ne corresponde plus à rien
      for(String title in listLocalTitle){
        if(metadata[title] != null){
          continue;
        } else {
          _localStorageRepository.deleteDocument(title);
          _syncRegistryRepository.removeEntry(title);
        }
      }
    }catch (e) {
      print(e);
    }
    //Renvoyer un message à l'utilisateur sur le modification effectuer en local
    //Lancer avec la synchro
}
}
