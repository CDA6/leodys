import '../../data/repositories/calendar_repository_impl.dart';

import '../repositories/calendar_repository.dart';

/// UseCase pour initialiser Google Calendar
class InitializeGoogleCalendar {
  final CalendarRepository repository = CalendarRepositoryImpl();

  Future<void> call(dynamic googleUser) async {
    return await repository.initializeGoogleCalendar(googleUser);
  }
}