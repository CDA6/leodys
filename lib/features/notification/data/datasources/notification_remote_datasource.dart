import '../../domain/entities/message_entity.dart';


abstract class NotificationRemoteDataSource {
  Future<void> saveMessageToRemote(MessageEntity message);
  Future<List<MessageEntity>> getMessagesFromRemote();
}

/// Implémentation concrète pour la persistance des messages dans Supabase.
class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  // final _supabase = Supabase.instance.client;

  @override
  Future<void> saveMessageToRemote(MessageEntity message) async {

    // await _supabase.from('messages').insert({
    //   'id': message.id,
    //   'referent_id': message.referentId,
    //   'referent_name': message.referentName,
    //   'subject': message.subject,
    //   'body': message.body,
    //   'sent_at': message.sentAt.toIso8601String(),
    // });
    print("LOG: Message sauvegardé à distance dans Supabase (mock) : ${message.id}");
    await Future.delayed(const Duration(milliseconds: 100)); // Simuler un appel réseau
  }

  @override
  Future<List<MessageEntity>> getMessagesFromRemote() async {
    // final response = await _supabase.from('messages').select().order('sent_at', ascending: false);
    // return (response as List).map((json) => MessageEntity.fromJson(json)).toList();
    print("LOG: Récupération des messages depuis Supabase (mock)");
    await Future.delayed(const Duration(milliseconds: 200)); // Simuler un appel réseau
    return [
      MessageEntity(
        id: 'remote_msg_1', // Un ID distinct pour simuler un message distant
        referentId: '2',
        referentName: 'Pascal Lamy',
        subject: 'Demande de renseignement depuis un autre appareil',
        body: 'Bonjour Pascal, j\'espère que vous allez bien. Ce message vient du cloud.',
        sentAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
}
