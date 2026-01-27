import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/common/mixins/connectivity_mixin.dart';
import 'package:leodys/features/confidential_document/domain/KeyStorageService.dart';
import 'package:leodys/features/confidential_document/domain/encryption_service.dart';
import 'package:leodys/features/confidential_document/domain/entity/decryption_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/picture_download.dart';
import 'package:leodys/features/confidential_document/domain/entity/save_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/sunc_success.dart';
import 'package:leodys/features/confidential_document/domain/synchronisation_usecase.dart';

import '../data/auth_repository.dart';
import '../domain/encrypted_session.dart';
import '../domain/save_document_usecase.dart';

class ConfidentialDocumentViewmodel extends ChangeNotifier with ConnectivityMixin {

  //usecase
  final SaveDocumentUsecase _saveDoc = SaveDocumentUsecase();
  final EncryptionService _encryptionService = EncryptionService();
  final EncryptionSession session = EncryptionSession();
  final AuthRepository _authRepo = AuthRepository();
  final KeyStorageService _keyStorageService = KeyStorageService();
  final SynchronisationUsecase _synchronisationUsecase = SynchronisationUsecase();

  //============
  // Variables
  //============

  //Connection
  String? emailUser;
  bool isLoading = true;
  bool lookingForPicture = false;
  // final _storage = const FlutterSecureStorage();

  //Images
  Uint8List? imageFile;
  List<PictureDownload>? pictures;
  String? noPicture;
  bool hideGallery = true;
  bool isSaving = false;

  //Snack bar
  int errorCount = 0;
  String? infoSaveImg;
  //Synch
  String? alerteSync;

  //Input
  final TextEditingController titleController = TextEditingController();
  String? titleError;

  // Initialization for screen
  Future<void> i65nit() async {
    //voir si récupère la connexion
    // final AuthRepository authRepo = AuthRepository();
    // await authRepo.login();
    initConnectivity();
    print("Has Connection ? $hasConnection");

    emailUser = _saveDoc.returnUser();
    SecretKey? key = await _keyStorageService.loadKey();
    if(key != null){
      session.setKey(key);
      print("****Debug clé détecter : ${session.key} ****");
    } else {
      print("****Debug aucune clé ****");
    }
    isLoading = false;
    notifyListeners(); // On prévient l'UI que c'est bon
    await sync();
  }
  Future<void> sync() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Checks de base
      if (!hasConnection || !_authRepo.isConnected) {
        print("Synchro annulée : Pas de réseau ou pas de session locale.");
        return; // Le code saute directement au 'finally'
      }

      // 2. Check serveur (avec le timeout dont on a parlé pour éviter l'infini)
      bool isServerUp = await _authRepo.checkServerConnection();

      if (!isServerUp) {
        print("Le serveur Supabase est injoignable.");
        alerteSync = "Connexion serveur impossible.";
        return; // Le code saute directement au 'finally'
      }

      // 3. Logique de synchro
      SyncSuccess syncRes = await _synchronisationUsecase.synchronisation(hasConnection);

      switch (syncRes) {
        case SyncSuccess.syncCompleted:
          alerteSync = "Synchronisation réussie";
          break;
        case SyncSuccess.alreadySync:
          alerteSync = "Tout est déjà à jour.";
          break;
        case SyncSuccess.syncFailed:
          alerteSync = "La synchronisation a échoué.";
          break;
      }

    } catch (e) {
      print("Erreur inattendue lors de la synchro : $e");
      alerteSync = "Une erreur est survenue.";
    } finally {
      // CE BLOC S'EXÉCUTE TOUJOURS
      // Que tu aies fait un "return", que ça ait réussi, ou que ça ait crashé.
      isLoading = false;
      notifyListeners();
      print("Fin du processus de synchro (Loading arrêté)");
    }
  }

Future<void> clearAlerte() async {
    alerteSync = null;
    notifyListeners();
}

  /// search a picture in personal files
  Future<void> getPicture() async {
    try {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile == null) return;

      final Uint8List bytes = await pickedFile.readAsBytes();
      imageFile = bytes;
      notifyListeners();
    } catch (e) {
      print('Erreur au chargement de l\'image: $e');
    }
  }

  Future<void> takePicture() async {
    try{
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile == null) return;

      _showChosenPicture(pickedFile);
    } catch(e) {
      print("Erreur lors de la prise de la photo : $e");
    }
  }

  Future<void> _showChosenPicture(XFile pickedFile) async {
    final Uint8List bytes = await pickedFile.readAsBytes();
    imageFile = bytes;
    notifyListeners();
  }

  Future<void> cancelImageFile() async {
    imageFile = null;
    titleController.clear();
    notifyListeners();
  }

  Future<void> saveImage() async {
    if (isSaving) return;
    if (imageFile == null) {
      titleError = "Veuillez sélectionner une image";
      notifyListeners();
      return;
    }

    if (titleController.text.isEmpty) {
      titleError = "Le titre ne peut pas être vide";
      notifyListeners();
      return;
    }

    if (session.isLocked) {
      titleError = "Le coffre est verrouillé.";
      notifyListeners();
      return;
    }

    isSaving = true;
    notifyListeners();
    try {
      SaveResult res = await _saveDoc.saveImage(
        imageFile!,
        titleController.text,
        session.key!,
      );

      imageFile = null;
      titleError = null;

      infoSaveImg = switch (res) {
        SaveResult.failure => "Échec de l'enregistrement",
      SaveResult.remoteOnly => "Enregistrement web réussi",
        SaveResult.localOnly => "Enregistrement local réussi",
        SaveResult.fullSuccess => "Image enregistrée avec succès",
      };

    } catch (_) {
      infoSaveImg = "Erreur lors de l'enregistrement";
    } finally {
      isSaving = false;
      titleController.clear();
      notifyListeners();
    }
  }


  Future<void> clearInfoSave() async {
    infoSaveImg = null;
    notifyListeners();
  }

    Future<void> getAllPicture() async {
      lookingForPicture = true;
      notifyListeners();
      print("Lancement recherche image dans viewmodel");
      if (!session.isLocked) {
        print("session déverouiller lancement recherche");
        DecryptionResult? result = await _saveDoc.getAllImages(checkConnection());
        if(result != null) {
          pictures = result.pictures;
          errorCount = result.errorCount;
          notifyListeners();
        }
        else {
          noPicture = "Aucune image n'est enregistrée dans votre espace";
        }
      }
      lookingForPicture = false;
      notifyListeners();
    }

    Future<void> deletePicture(String title) async {
    //TODO delete picture selected
    }


    //TODO modifier cette méthode pour la création de la clé et la récupération de la clé
  Future<bool> saveKey(String password) async {
    final String? userUid = _authRepo.currentUser?.id;
    if (userUid == null || userUid.isEmpty) return false;
    if (password.isEmpty) return false;
    try {
      // Générer la clé une seule fois
      final key = await _encryptionService.getEncryptionKey(password, userUid);
      session.setKey(key);
      await _keyStorageService.saveKey(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> maskGallery (bool status) async {
    hideGallery = status;
  }

}
