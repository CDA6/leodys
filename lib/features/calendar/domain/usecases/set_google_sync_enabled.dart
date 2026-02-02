import '../repositories/calendar_repository.dart';

/// Active/désactive la synchronisation Google Calendar
class SetGoogleSyncEnabled {
  final CalendarRepository repository;

  SetGoogleSyncEnabled(this.repository);

  void call(bool enabled) {
    repository.setGoogleCalendarEnabled(enabled);
  }
}
