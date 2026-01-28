import 'dart:convert';
import 'dart:io';

import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileLocalDatasource {
  Future<UserProfileModel?> loadLocalProfile() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String jsonProfilePath = '${appDir.path}/profile/profile.json';

    final jsonFile = File(jsonProfilePath);

    if (!jsonFile.existsSync()) return null;

    final localData = jsonDecode(await jsonFile.readAsString());

    return UserProfileModel(
        userId: localData['userId'],
        firstName: localData['firstName'],
        lastName: localData['lastName'],
        email: localData['email'],
        phone: localData['phone'],
        avatarPath: localData['avatarPath'],
        avatarUrl: localData['avatarUrl'],
        updatedAt: localData['updatedAt'],
        syncStatus: localData['syncStatus']
    );
  }

  Future<void> saveLocalProfile(UserProfileModel profile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');

    if (!profileDir.existsSync()) {
      profileDir.createSync(recursive: true);
    }

    final user = Supabase.instance.client.auth.currentUser;
    var userId = '';
    if (user != null) {
      userId = user.id;
    }

    final jsonProfilePath = '${profileDir.path}/profile.json';
    final jsonFile = File(jsonProfilePath);

    if (!jsonFile.existsSync()) {
      final profileJson = {
        "userId" : userId,
        "firstName" : profile.firstName,
        "lastName" : profile.lastName,
        "email" : profile.email,
        "phone" : profile.phone,
        "avatarPath" : 'profile.avatarPath',
        "avatarUrl" : 'profile.avatarUrl',
        "updatedAt" : DateTime.now().toIso8601String(),
        "syncStatus" : "PENDING"
      };
    }
  }

  // Future<String> copyAvatarToAppDir(String avatarPath) async {
  //   if (avatarPath.isEmpty) return '';
  //
  //   final originalFile = File(avatarPath);
  //   if (!originalFile.existsSync()) return '';
  //
  //   // Répertoire dédié aux profils
  //   final appDir = await getApplicationDocumentsDirectory();
  //   final profileDir = Directory('${appDir.path}/profile');
  //
  //   // Crée le dossier s'il n'existe pas
  //   if (!profileDir.existsSync()) {
  //     profileDir.createSync(recursive: true);
  //   }
  //
  //   // Nom du fichier inchangé ou tu peux générer un UUID si tu veux
  //   final fileName = path.basename(avatarPath);
  //   final newPath = '${profileDir.path}/$fileName';
  //
  //   final newFile = await originalFile.copy(newPath);
  //   return newFile.path; // retourne le chemin du fichier copié
  // }
}