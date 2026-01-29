import 'package:leodys/features/forum/data/models/message_model.dart';

abstract class RemoteDataSource {
  Future<List<MessageModel>> fetchMessages();
  Future<void> postMessage(MessageModel message);
}

