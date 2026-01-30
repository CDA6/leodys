import 'dart:convert';
import 'dart:io';

import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class ProfileLocalDatasource {
  // chargement du profil existant
  Future<UserProfileModel?> loadLocalProfile() async {
    final appDir = await getApplicationDocumentsDirectory();
    final jsonFile = File('${appDir.path}/profile/profile.json');

    if (!jsonFile.existsSync()) return null;

    final fileContent = await jsonFile.readAsString();
    if (fileContent.trim().isEmpty) return null; // fichier vide
    final localData = jsonDecode(fileContent);

    UserProfileModel? profile;
    try {
      profile = UserProfileModel(
        userId: localData['userId'],
        firstName: localData['firstName'],
        lastName: localData['lastName'],
        email: localData['email'],
        phone: localData['phone'],
        avatarPath: localData['avatarPath'],
        avatarUrl: localData['avatarUrl'],
        updatedAt: DateTime.parse(localData['updatedAt']),
        syncStatus: localData['syncStatus'],
      );
    } catch (e) {
      print("Erreur lecture JSON local: $e");
      return null;
    }
    return profile;

  }

  // save / update du profil local
  Future<UserProfileModel> saveLocalProfile(UserProfileModel profile) async {
    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');

    if (!profileDir.existsSync()) {
      profileDir.createSync(recursive: true);
    }

    // userId = UUID Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? profile.userId;

    // Copier l’avatar si présent
    String? avatarPath;
    if (profile.avatarPath != null && profile.avatarPath!.isNotEmpty) {
      final copiedPath = await copyAvatarToAppDir(profile.avatarPath!);
      avatarPath = copiedPath.isNotEmpty ? copiedPath : null;
    }

    final profileJson = {
      "userId": userId,
      "firstName": profile.firstName,
      "lastName": profile.lastName,
      "email": profile.email,
      "phone": profile.phone,
      "avatarPath": avatarPath,
      "avatarUrl": profile.avatarUrl,
      "updatedAt": DateTime.now().toIso8601String(),
      "syncStatus": "PENDING"
    };

    final jsonFile = File('${profileDir.path}/profile.json');

    await jsonFile.writeAsString(
      jsonEncode(profileJson),
      flush: true,
    );

    return profile;
  }

  // copie de l'avatar des fichiers utilisateurs vers fichiers de l'application
  Future<String> copyAvatarToAppDir(String avatarPath) async {
    final originalFile = File(avatarPath);
    if (!originalFile.existsSync()) return '';

    final bytes = await originalFile.readAsBytes();
    if (bytes.isEmpty) return '';

    final appDir = await getApplicationDocumentsDirectory();
    final profileDir = Directory('${appDir.path}/profile');

    if (!profileDir.existsSync()) {
      profileDir.createSync(recursive: true);
    }

    // récupère l'extension du fichier original
    final extension = path.extension(avatarPath);

    // Nom standardisé : avatar.jpg / avatar.png
    final newPath = '${profileDir.path}/avatar$extension';

    // supprime l'ancien avatar s'il existe
    final newFile = File(newPath);
    if (newFile.existsSync()) {
      await newFile.delete();
    }

    // copie le nouvel avatar
    await newFile.writeAsBytes(bytes, flush: true);

    return newFile.path;
  }


}