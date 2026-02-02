import '../repositories/calendar_repository.dart';

/// Initialise Google Calendar
class InitializeGoogleCalendar {
  final CalendarRepository repository;

  InitializeGoogleCalendar(this.repository);

  Future<void> call(dynamic googleUser) async {
    return await repository.initializeGoogleCalendar(googleUser);
  }
}
