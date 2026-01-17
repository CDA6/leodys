import 'package:hive_flutter/hive_flutter.dart';
import '../../features/notification/domain/entities/message_entity.dart';
import '../../features/notification/domain/entities/referent_entity.dart';

class DatabaseService {
  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    Hive.registerAdapter(MessageEntityAdapter());
    Hive.registerAdapter(ReferentEntityAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<ReferentEntity>('referent_entity');
    await Hive.openBox<MessageEntity>('message_history');

    // Optionnel : Clear pour le dev si nécessaire
    // await Hive.box<ReferentEntity>('referent_entity').clear();
  }
}