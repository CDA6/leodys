import '../repositories/calendar_repository.dart';
import '../../data/repositories/calendar_repository_impl.dart';
import 'usecase.dart';

/// Supprime un événement
class DeleteEvent implements UseCase<void, String> {
  final CalendarRepository repository = CalendarRepositoryImpl();

  @override
  Future<void> call(String eventId) {
    return repository.deleteEvent(eventId);
  }
}