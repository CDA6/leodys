import '../../data/repositories/calendar_repository_impl.dart';

import '../repositories/calendar_repository.dart';

/// UseCase pour activer/désactiver la synchronisation Google
class SetGoogleSyncEnabled {
  final CalendarRepository repository = CalendarRepositoryImpl();

  void call(bool enabled) {
    repository.setGoogleCalendarEnabled(enabled);
  }
}