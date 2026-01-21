import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/src/cryptography/secret_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:leodys/features/confidential_document/domain/KeyStorageService.dart';
import 'package:leodys/features/confidential_document/domain/encryption_service.dart';
import 'package:leodys/features/confidential_document/domain/entity/decryption_result.dart';
import 'package:leodys/features/confidential_document/domain/entity/picture_download.dart';

import '../data/auth_repository.dart';
import '../domain/encrypted_session.dart';
import '../domain/save_document_usecase.dart';

class ConfidentialDocumentViewmodel extends ChangeNotifier {
  //connection Supabase

  //usecase
  final SaveDocumentUsecase _saveDoc = SaveDocumentUsecase();
  final EncryptionService _encryptionService = EncryptionService();
  final EncryptionSession session = EncryptionSession();
  final AuthRepository _authRepo = AuthRepository();
  final KeyStorageService _keyStorageService = KeyStorageService();

  //============
  // Variables
  //============

  //Connection
  String? emailUser;
  bool isLoading = true;
  bool lookingForPicture = false;
  final _storage = const FlutterSecureStorage();

  //Images
  Uint8List? imageFile;
  List<PictureDownload>? pictures;
  String? noPicture;
  int errorCount = 0;
  bool hideGallery = true;

  //Input
  final TextEditingController titleController = TextEditingController();
  String? titleError;

  // Initialization for screen
  Future<void> i65nit() async {
    final AuthRepository authRepo = AuthRepository();
    await authRepo.login();
    emailUser = _saveDoc.returnUser();
    await _keyStorageService.loadKey();
    isLoading = false;
    notifyListeners(); // On prévient l'UI que c'est bon
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

  //TODO take picture


  Future<void> cancelImageFile() async {
    imageFile = null;
    notifyListeners();
  }

  Future<void> saveImage() async {
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
    if (!session.isLocked) {
      await _saveDoc.saveImage(imageFile!, titleController.text, session.key!);
      // Nettoyage après succès
      imageFile = null;
      titleError = null;
      notifyListeners();
    } else {
      // Si c'est verrouillé
      titleError = "Le coffre est verrouillé. Entrez votre mot de passe.";
      notifyListeners();
    }
//TODO récupérer le resultat de l'enregistrement pour faire une petite snack bar
  }

    Future<void> getAllPicture() async {
      lookingForPicture = true;
      notifyListeners();
      print("Lancement recherche image dans viewmodel");
      if (!session.isLocked) {
        print("session déverouiller lancement recherche");
        DecryptionResult? result = await _saveDoc.getAllImages();
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
