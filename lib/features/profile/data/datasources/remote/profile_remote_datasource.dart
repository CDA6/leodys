import 'dart:io';

import 'package:leodys/features/profile/domain/models/user_profile_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRemoteDatasource {

  final SupabaseClient supabase;

  const ProfileRemoteDatasource({required this.supabase});

  Future<void> uploadProfile(UserProfileModel profile) async {

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw AuthException("Erreur : utilisateur non connecté");
    }

    final userId = user.id;

    // upload avatar de l'user dans le bucket si il existe
    final localPath = profile.avatarPath;

    dynamic storagePath;

    // suppression de l'ancien avatar si existe
    if (profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty) {
      final oldPath = profile.avatarUrl!.split('/').last; // chemin relatif
      try {
        await supabase.storage.from('avatars').remove(['user_$userId/$oldPath']);
      } catch (e) {
        print("Impossible de supprimer l'ancien avatar distant : $e");
      }
    }

    if(localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (await file.exists()) {
        // chemin distant
        storagePath = 'user_$userId/${localPath.split('/').last}';

        try {
          await supabase.storage
              .from('avatars')
              .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));
        } on StorageException catch (_) {
          rethrow;
        } catch (e) {
          throw Exception(e.toString());
        }
      }
    }

    // upsert dans la table user_profiles
    try {
      // ajout ou modification d'une ligne existante dans la table user_profiles
      await supabase.from('user_profiles').upsert({
        'id': user.id,
        'first_name': profile.firstName,
        'last_name': profile.lastName,
        'email': profile.email,
        'phone': profile.phone,
        'avatar_url': storagePath ?? '',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
        'sync_status': 'SYNCED',
      }, onConflict: 'id'); // clé primaire pour upsert
    } on PostgrestException catch (_) {
      rethrow;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<UserProfileModel?> loadRemoteProfile() async {
    final user = supabase.auth.currentUser;
    if(user == null) return null;

    final response = await supabase
        .from("user_profiles")
        .select()
        .eq("id", user.id)
        .maybeSingle();


    UserProfileModel? remoteProfile;
    if(response != null) {
      try {
        remoteProfile = UserProfileModel(
          userId: response['id'],
          firstName: response['first_name'],
          lastName: response['last_name'],
          email: response['email'],
          phone: response['phone'],
          avatarUrl: response['avatar_url'],
          avatarPath: null, // on garde le local pour le cache
          updatedAt: DateTime.parse(response['updated_at']),
          syncStatus: 'SYNCED',
        );
        return remoteProfile;
      } catch (e) {
        print(e.toString());
        rethrow;
      }
    }
    return null;
  }
}