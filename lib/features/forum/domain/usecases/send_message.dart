import '../repositories/forum_repository.dart';
import '../entities/message.dart';

class SendMessage {
  final ForumRepository repository;
  SendMessage(this.repository);

  Future<void> call(Message message) async {
    await repository.sendMessage(message);
  }
}
