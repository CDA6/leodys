import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Synchronise les événements locaux vers Google Calendar
class SyncLocalToGoogle implements UseCase<void, NoParams> {
  final CalendarRepository repository;

  SyncLocalToGoogle(this.repository);

  @override
  Future<void> call(NoParams params) async {
    return await repository.syncLocalToGoogle();
  }
}
