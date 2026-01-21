import 'package:hive/hive.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/referent_entity.dart';

abstract class NotificationLocalDataSource {
  Future<List<ReferentEntity>> getReferents();
  Future<void> saveReferent(ReferentEntity referent);
  Future<void> deleteReferent(String id);
  Future<List<MessageEntity>> getMessageHistory();
  Future<void> saveMessage(MessageEntity message);
}

class NotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final Box<ReferentEntity> _refBox = Hive.box<ReferentEntity>('referent_entity');
  final Box<MessageEntity> _historyBox = Hive.box<MessageEntity>('message_history');

  @override
  Future<List<ReferentEntity>> getReferents() async {
    // 1. On vérifie si la box est vide
    if (_refBox.isEmpty) {
      // 2. Si oui, on remplit avec les données par défaut
      await _seedInitialData();
    }
    return _refBox.values.toList();
  }

  /// Injection des 6 référents de base
  Future<void> _seedInitialData() async {
    final List<ReferentEntity> initialData = [
      const ReferentEntity(id: '1', name: 'Jean John', email: 'laubert.yoann@gmail.com', role: 'Tuteur', category: 'Mon Référent'),
      const ReferentEntity(id: '2', name: 'Pascal Lamy', email: 'pascal.lamy5@ac-rennes.fr', role: 'Conseillère', category: 'Mon Référent'),
      const ReferentEntity(id: '3', name: 'Paul Mccartney', email: 'p.bernard@capemploi.fr', role: 'Expert', category: 'CAP Emploi'),
      const ReferentEntity(id: '4', name: 'Laure Manaudou', email: 'l.clerc@capemploi.fr', role: 'Chargée de mission', category: 'CAP Emploi'),
      const ReferentEntity(id: '5', name: 'Karl Marx', email: 'm.durand@agefiph.fr', role: 'Délégué', category: 'AGEFIPH'),
      const ReferentEntity(id: '6', name: 'Brad Pitt', email: 's.petit@agefiph.fr', role: 'Référente', category: 'AGEFIPH'),
    ];

    for (var ref in initialData) {
      await _refBox.put(ref.id, ref);
    }
  }

  @override
  Future<void> saveReferent(ReferentEntity referent) async => _refBox.put(referent.id, referent);

  @override
  Future<void> deleteReferent(String id) async => _refBox.delete(id);

  @override
  Future<List<MessageEntity>> getMessageHistory() async => _historyBox.values.toList().reversed.toList();

  @override
  Future<void> saveMessage(MessageEntity message) async => _historyBox.add(message);
}