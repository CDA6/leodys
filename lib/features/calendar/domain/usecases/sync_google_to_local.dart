import '../../data/repositories/calendar_repository_impl.dart';

import '../repositories/calendar_repository.dart';

/// Paramètres pour la synchronisation Google vers local
class SyncGoogleToLocalParams {
  final DateTime startDate;
  final DateTime endDate;

  SyncGoogleToLocalParams({
    required this.startDate,
    required this.endDate,
  });
}

/// UseCase pour synchroniser Google vers local
class SyncGoogleToLocal {
  final CalendarRepository repository = CalendarRepositoryImpl();

  Future<void> call(SyncGoogleToLocalParams params) async {
    return await repository.syncGoogleToLocal(params.startDate, params.endDate);
  }
}