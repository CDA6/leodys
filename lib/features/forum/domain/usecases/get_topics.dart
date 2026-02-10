import '../repositories/forum_repository.dart';
import '../entities/topic.dart';

class GetTopics {
  final ForumRepository repository;
  GetTopics(this.repository);

  Future<List<Topic>> call() async {
    return repository.getTopics();
  }
}
