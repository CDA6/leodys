import 'package:leodys/features/forum/domain/entities/message.dart';
import 'package:leodys/features/forum/domain/repositories/message_repository.dart';

class GetMessages {
  final MessageRepository repository;
  GetMessages(this.repository);

  Future<List<Message>> call() async {
    return repository.getMessages();
  }
}