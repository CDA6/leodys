import 'package:hive/hive.dart';
import '../models/calendar_event_model.dart';

class CalendarLocalDataSource {
  static const String _boxName = 'calendar_events';

  /// Récupère la box hive
  Box<CalendarEventModel> get _box {
    return Hive.box<CalendarEventModel>(_boxName);
  }

  /// Récupère les événements pour un jour donné
  Future<List<CalendarEventModel>> getEventsForDay(DateTime day) async {
    // Normalise la date
    final normalizedDay = DateTime(day.year, day.month, day.day);

    // Filtre les événements du jour
    final events = _box.values.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      return eventDate.isAtSameMomentAs(normalizedDay);
    }).toList();

    return events;
  }

  /// Ajoute un événement
  Future<void> addEvent(CalendarEventModel event) async {
    // Utilise l'ID comme clé pour faciliter les updates/deletes
    await _box.put(event.id, event);
  }

  /// Met à jour un événement
  Future<void> updateEvent(CalendarEventModel event) async {
    // Hive écrase automatiquement si la clé existe
    await _box.put(event.id, event);
  }

  /// Supprime un événement
  Future<void> deleteEvent(String eventId) async {
    await _box.delete(eventId);
  }

  /// Récupère tous les événements
  Future<List<CalendarEventModel>> getAllEvents() async {
    return _box.values.toList();
  }

  /// Nettoie tous les événements (utile pour le dev)
  Future<void> clearAll() async {
    await _box.clear();
  }
}