import '../../data/repositories/calendar_repository_impl.dart';

import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Ajoute un événement
class AddEvent implements UseCase<void, CalendarEvent> {
  final CalendarRepository repository = CalendarRepositoryImpl();

  @override
  Future<void> call(CalendarEvent event) {
    return repository.addEvent(event);
  }
}