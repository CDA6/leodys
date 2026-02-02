import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';

abstract class NotificationLocalDataSource {
  Future<List<ReferentEntity>> getReferents();
  Future<void> saveReferent(ReferentEntity referent);
  Future<void> deleteReferent(String id);
  Future<List<MessageEntity>> getMessageHistory();
  Future<void> saveMessage(MessageEntity message);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Box<ReferentEntity> _refBox = Hive.box<ReferentEntity>('referent_entity');
  final Box<MessageEntity> _historyBox = Hive.box<MessageEntity>('message_history');

  @override
  Future<List<ReferentEntity>> getReferents() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return []; // Sécurité si non connecté

    return _refBox.values
        .where((ref) => ref.userId == currentUser.id) // FILTRE ICI
        .toList();
  }

  @override
  Future<void> saveReferent(ReferentEntity referent) async => _refBox.put(referent.id, referent);

  @override
  Future<void> deleteReferent(String id) async => _refBox.delete(id);

  @override
  Future<List<MessageEntity>> getMessageHistory() async {
    final currentUser = Supabase.instance.client.auth.currentUser;

    // 1. Si pas d'utilisateur authentifié (même en cache), on renvoie une liste vide
    if (currentUser == null) {
      print("LOG: Tentative d'accès à l'historique sans authentification.");
      return [];
    }

    final currentUserId = currentUser.id;

    return _historyBox.values
        .where((msg) => msg.userId == currentUserId) // Filtre local impératif
        .toList()
        .reversed
        .toList();
  }

  @override
  Future<void> saveMessage(MessageEntity message) async => _historyBox.add(message);
}