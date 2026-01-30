import 'package:leodys/features/forum/domain/entities/message.dart';

abstract class MessageRepository {
  Future<List<Message>> getMessages();
  Future<void> sendMessage(Message message);
}