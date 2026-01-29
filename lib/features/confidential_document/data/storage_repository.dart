import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../common/utils/app_logger.dart';

class RemoteStorageRepository {
  final _client = Supabase.instance.client;
  late final _userId = _client.auth.currentUser?.id;
  final String _folder = 'Confidential_document';

  Future<void> uploadDocument(Uint8List bytes, String title) async {

    if (_userId == null) throw Exception("Non connecté");
    final String filePath = '$_userId/$title.enc';
    await _client.storage
        .from(_folder) // Le nom du bucket créé manuellement
        .uploadBinary(
      filePath,
      bytes,
      fileOptions: const FileOptions(upsert: true), // Permet d'écraser si besoin
    );
  }



 Future <Uint8List?> getImage(String title, {String? bucketName}) async {
 bucketName ??= _userId;
    final String filePath = '$_userId/$title';
    try {
      final response = await _client.storage
          .from(_folder)
          .download(filePath);

      if (response.isEmpty) {
        AppLogger().warning("Alerte :Le fichier a été trouvé mais il est TOTALEMENT VIDE (0 octet).");
        return null;
      }

      // Si la taille est petite (ex: < 100 octets), c'est peut-être un message d'erreur JSON
      if (response.length < 200) {
        try {
          String errorMsg = utf8.decode(response);
          AppLogger().warning("Alerte : Le contenu ressemble à un message d'erreur : $errorMsg");
        } catch (_) {
          // Si on ne peut pas le décoder en texte, c'est que c'est bien de la donnée binaire
        }
      }

      return response;

    } catch (e) {
      // VÉRIFICATION 3 : L'erreur Supabase
      AppLogger().error("Erreur critique lors du download" , error: e);
      return null;
    }
 }

 Future<List<String>> getListTitle({String? bucketName}) async {
   bucketName ??= _userId;
   try {
     final List<FileObject> objects = await _client
         .storage
         .from(_folder)
         .list(path: bucketName!);
     AppLogger().info("Nombre d'objets récupérés dans Supabase : ${objects.length}");
     return objects.map((object) => object.name).toList();
   } catch (e) {
     AppLogger().error("Erreur Supabase Storage", error: e);
     return [];
   }
 }

Future<void> deleteImage(List<String> titles, {String? bucketName}) async {
  bucketName ??= _userId;
  final List<String> listFilePath = titles.map((title) {
    return title.endsWith('.enc') ? '$_userId/$title' : '$_userId/$title.enc';
  }).toList();
  try{
    final List<FileObject> objects = await _client
        .storage
        .from(_folder)
        .remove(listFilePath);
  }catch(e){
    AppLogger().error("erreur suppression", error : e );
  }
}
}