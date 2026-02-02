import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Met à jour un événement
class UpdateEvent implements UseCase<void, CalendarEvent> {
  final CalendarRepository repository;

  UpdateEvent(this.repository);

  @override
  Future<void> call(CalendarEvent event) {
    return repository.updateEvent(event);
  }
}
