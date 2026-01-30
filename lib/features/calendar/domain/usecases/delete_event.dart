import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Supprime un événement
class DeleteEvent implements UseCase<void, String> {
  final CalendarRepository repository;

  DeleteEvent(this.repository);

  @override
  Future<void> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}
