import '../entities/calendar_event.dart';

abstract class CalendarRepository {
  /// Récupère les événements pour un jour (local + Google si connecté)
  Future<List<CalendarEvent>> getEventsForDay(DateTime day);

  /// Ajoute un événement (local + Google si connecté)
  Future<void> addEvent(CalendarEvent event);

  /// Met à jour un événement (local + Google si connecté)
  Future<void> updateEvent(CalendarEvent event);

  /// Supprime un événement (local + Google si connecté)
  Future<void> deleteEvent(String eventId);

  /// Initialise Google Calendar avec un compte Google
  Future<void> initializeGoogleCalendar(dynamic googleUser);

  /// Configure la source de données à utiliser
  void setGoogleCalendarEnabled(bool enabled);

  /// Vérifie si Google Calendar est activé
  bool isGoogleCalendarEnabled();

  /// Synchronise les événements locaux vers Google
  Future<void> syncLocalToGoogle();

  /// Synchronise les événements Google vers local
  Future<void> syncGoogleToLocal(DateTime startDate, DateTime endDate);
}