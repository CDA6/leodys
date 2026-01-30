import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Ajoute un événement
class AddEvent implements UseCase<void, CalendarEvent> {
  final CalendarRepository repository;

  AddEvent(this.repository);

  @override
  Future<void> call(CalendarEvent event) {
    return repository.addEvent(event);
  }
}
