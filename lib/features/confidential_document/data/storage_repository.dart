import 'dart:convert';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    print("getImage appeler");
 bucketName ??= _userId;
    final String filePath = '$_userId/$title';
    print("Tentative de téléchargement : $filePath");
    try {
      final response = await _client.storage
          .from(_folder)
          .download(filePath);

      // VÉRIFICATION 1 : La taille
      print("Réponse reçue. Taille brute : ${response.length} octets");

      if (response.isEmpty) {
        print("⚠️ Alerte : Le fichier a été trouvé mais il est TOTALEMENT VIDE (0 octet).");
        return null;
      }

      // VÉRIFICATION 2 : Est-ce du texte caché dans des octets ?
      // Si la taille est petite (ex: < 100 octets), c'est peut-être un message d'erreur JSON
      if (response.length < 200) {
        try {
          String errorMsg = utf8.decode(response);
          print("⚠️ Alerte : Le contenu ressemble à un message d'erreur : $errorMsg");
        } catch (_) {
          // Si on ne peut pas le décoder en texte, c'est que c'est bien de la donnée binaire
        }
      }

      return response;

    } catch (e) {
      // VÉRIFICATION 3 : L'erreur Supabase
      print("❌ Erreur critique lors du download : $e");
      return null;
    }
 }

 Future<List<String>> getListTitle({String? bucketName}) async {
   print("getListTitle appeler");
   bucketName ??= _userId;
   print(bucketName);
   try {
     final List<FileObject> objects = await _client
         .storage
         .from(_folder)
         .list(path: bucketName!);
     print("Nombre d'objets récupérés dans Supabase : ${objects.length}");
     for (FileObject o in objects) {
       print("Fichier trouvé : ${o.name}");
     }
     return objects.map((object) => object.name).toList();
   } catch (e) {
     print("Erreur Supabase Storage : $e");
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
    print("erreur suppression : $e");
  }
}
}