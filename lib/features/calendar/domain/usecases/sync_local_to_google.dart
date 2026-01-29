import '../../data/repositories/calendar_repository_impl.dart';

import '../repositories/calendar_repository.dart';
import 'usecase.dart';

/// UseCase pour synchroniser local vers Google
class SyncLocalToGoogle implements UseCase<void, NoParams> {
  final CalendarRepository repository = CalendarRepositoryImpl();

  @override
  Future<void> call(NoParams params) async {
    return await repository.syncLocalToGoogle();
  }
}