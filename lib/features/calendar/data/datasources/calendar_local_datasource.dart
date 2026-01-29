import 'dart:collection';
import 'package:table_calendar/table_calendar.dart';
import '../models/calendar_event_model.dart';

/// DataSource local pour stocker les événements en mémoire
class CalendarLocalDataSource {
  /// Stockage des événements avec LinkedHashMap
  /// Permet de comparer les DateTime uniquement par la date
  final _events = LinkedHashMap<DateTime, List<CalendarEventModel>>(
    equals: isSameDay,
    hashCode: _getHashCode,
  );

  /// Fonction de hash personnalisée pour DateTime
  static int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  /// Récupère les événements pour un jour donné
  Future<List<CalendarEventModel>> getEventsForDay(DateTime day) async {
    // Normalise la date (enlève l'heure)
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  /// Ajoute un événement
  Future<void> addEvent(CalendarEventModel event) async {
    final day = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );

    if (_events[day] == null) {
      _events[day] = [];
    }
    _events[day]!.add(event);
  }

  /// Met à jour un événement
  Future<void> updateEvent(CalendarEventModel event) async {
    final day = DateTime(
      event.startTime.year,
      event.startTime.month,
      event.startTime.day,
    );

    if (_events[day] != null) {
      final index = _events[day]!.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[day]![index] = event;
      }
    }
  }

  /// Supprime un événement
  Future<void> deleteEvent(String eventId) async {
    for (final day in _events.keys) {
      _events[day]!.removeWhere((event) => event.id == eventId);
    }
  }

  Future<List<CalendarEventModel>> getAllEvents() async {
    final allEvents = <CalendarEventModel>[];

    _events.forEach((date, eventsList) {
      allEvents.addAll(eventsList);
    });

    return allEvents;
  }
}
