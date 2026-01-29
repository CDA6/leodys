import '../../data/repositories/calendar_repository_impl.dart';

import '../entities/calendar_event.dart';
import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// Récupère les événements d'un jour
class GetEventsForDay implements UseCase<List<CalendarEvent>, DateTime> {
  final CalendarRepository repository = CalendarRepositoryImpl();

  @override
  Future<List<CalendarEvent>> call(DateTime day) {
    return repository.getEventsForDay(day);
  }
}