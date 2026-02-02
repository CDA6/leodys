import '../repositories/forum_repository.dart';
import '../entities/message.dart';

class GetMessages {
  final ForumRepository repository;
  GetMessages(this.repository);

  Future<List<Message>> call(String topicId) async {
    return repository.getMessages(topicId);
  }
}
