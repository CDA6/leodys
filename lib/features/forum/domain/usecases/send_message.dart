import 'package:leodys/features/forum/domain/repositories/message_repository.dart';
import 'package:leodys/features/forum/domain/entities/message.dart';

class SendMessage {
  final MessageRepository repository;
  SendMessage(this.repository);

  Future<void> call(Message message) async {
    return repository.sendMessage(message);
  }
}
