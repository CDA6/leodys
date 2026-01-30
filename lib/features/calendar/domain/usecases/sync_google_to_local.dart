import '../repositories/calendar_repository.dart';

/// Paramètres pour la synchronisation Google → Local
class SyncGoogleToLocalParams {
  final DateTime startDate;
  final DateTime endDate;

  SyncGoogleToLocalParams({
    required this.startDate,
    required this.endDate,
  });
}

/// Synchronise Google Calendar vers les événements locaux
class SyncGoogleToLocal {
  final CalendarRepository repository;

  SyncGoogleToLocal(this.repository);

  Future<void> call(SyncGoogleToLocalParams params) async {
    return await repository.syncGoogleToLocal(params.startDate, params.endDate);
  }
}
