import '../repositories/forum_repository.dart';
import '../entities/topic.dart';

class CreateTopic {
  final ForumRepository repository;
  CreateTopic(this.repository);

  Future<void> call(Topic topic) async {
    await repository.createTopic(topic);
  }
}
