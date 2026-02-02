import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_entity.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';
import '../models/referent_model.dart';


abstract class NotificationRemoteDataSource {
  Future<void> saveMessageToRemote(MessageEntity message);
  Future<List<MessageEntity>> getMessagesFromRemote();
  Future<void> saveReferentToRemote(ReferentEntity referent);
  Future<List<ReferentEntity>> getReferentsFromRemote();
  Future<void> deleteReferentFromRemote(String id);
}

/// Implémentation concrète pour la persistance des messages dans Supabase.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final _supabase = Supabase.instance.client;
  // Remplacer la variable par un getter dynamique
  String get _currentUserId => _supabase.auth.currentUser?.id ?? '';


  @override
  Future<void> saveReferentToRemote(ReferentEntity referent) async {
    final model = ReferentModel.fromEntity(referent);
    await _supabase.from('referents').upsert(model.toJson());
  }

  @override
  Future<List<ReferentEntity>> getReferentsFromRemote() async {
    final response = await _supabase.from('referents').select().eq('user_id', _currentUserId);
    return (response as List).map((json) => ReferentModel.fromJson(json)).toList();
  }

  @override
  Future<void> deleteReferentFromRemote(String id) async {
    await _supabase.from('referents').delete().eq('id', id).eq('user_id', _currentUserId);;
  }

  Future<void> saveMessageToRemote(MessageEntity message) async {
    if (_currentUserId.isEmpty) return;
    // On convertit l'entité en modèle pour obtenir le JSON
    final model = MessageModel.fromEntity(message);

    await _supabase.from('messages').insert(model.toJson());
    print("LOG: Message sauvegardé réellement dans Supabase : ${message.id}");
  }

  @override
  Future<List<MessageEntity>> getMessagesFromRemote() async {
    if (_currentUserId.isEmpty) return [];
    final response = await _supabase
        .from('messages')
        .select()
        .eq('user_id', _currentUserId)
        .order('sent_at', ascending: false);

    // On mappe le résultat JSON vers une liste de MessageModel (qui sont des MessageEntity)
    return (response as List)
        .map((json) => MessageModel.fromJson(json))
        .toList();
  }
}
