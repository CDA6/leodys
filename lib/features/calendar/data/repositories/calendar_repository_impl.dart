import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';
import '../datasources/calendar_google_datasource.dart';
import '../models/calendar_event_model.dart';

/// Implémentation du CalendarRepository avec synchronisation
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource = CalendarLocalDataSource();
  final CalendarGoogleDataSource? googleDataSource = CalendarGoogleDataSource();

  bool _googleEnabled = false;

  @override
  void setGoogleCalendarEnabled(bool enabled) {
    _googleEnabled =
        enabled && googleDataSource != null && googleDataSource!.isReady;
    print('📅 Google Calendar ${_googleEnabled ? "activé" : "désactivé"}');
  }

  @override
  bool isGoogleCalendarEnabled() => _googleEnabled;

  @override
  Future<List<CalendarEvent>> getEventsForDay(DateTime day) async {
    // 1. Récupère toujours les événements locaux
    final localModels = await localDataSource.getEventsForDay(day);
    final localEvents = localModels.map((m) => m.toEntity()).toList();

    // 2. Si Google activé ET disponible, fusionne avec Google Calendar
    if (_googleEnabled &&
        googleDataSource != null &&
        googleDataSource!.isReady) {
      try {
        final googleModels = await googleDataSource!.getEventsForDay(
          day,
        ); // ← Ajoute !
        final googleEvents = googleModels.map((m) => m.toEntity()).toList();

        // Fusionne en évitant les doublons (même ID)
        final allEvents = <String, CalendarEvent>{};

        // Ajoute les événements locaux
        for (var event in localEvents) {
          allEvents[event.id] = event;
        }

        // Ajoute/écrase avec les événements Google
        for (var event in googleEvents) {
          allEvents[event.id] = event;
        }

        print(
          '📅 ${localEvents.length} locaux + ${googleEvents.length} Google = ${allEvents.length} total',
        );
        return allEvents.values.toList();
      } catch (e) {
        print('⚠️ Erreur sync Google, utilise local uniquement: $e');
        return localEvents;
      }
    }

    return localEvents;
  }

  @override
  Future<void> addEvent(CalendarEvent event) async {
    final model = CalendarEventModel.fromEntity(event);

    // 1. Sauvegarde TOUJOURS en local d'abord
    await localDataSource.addEvent(model);
    print('✅ Événement sauvegardé localement');

    // 2. Si Google activé ET disponible, sync vers Google
    if (_googleEnabled && googleDataSource != null) {
      try {
        await googleDataSource!.addEvent(model); // ← Ajoute !
        print('☁️ Événement synchronisé avec Google Calendar');
      } catch (e) {
        print('⚠️ Erreur sync Google (événement reste local): $e');
      }
    }
  }

  @override
  Future<void> updateEvent(CalendarEvent event) async {
    final model = CalendarEventModel.fromEntity(event);

    // 1. Met à jour en local
    await localDataSource.updateEvent(model);
    print('✅ Événement mis à jour localement');

    // 2. Si Google activé, sync vers Google
    if (_googleEnabled && googleDataSource != null) {
      try {
        await googleDataSource!.updateEvent(model); // ← Ajoute !
        print('☁️ Événement mis à jour sur Google Calendar');
      } catch (e) {
        print('⚠️ Erreur sync Google: $e');
      }
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    // 1. Supprime en local
    await localDataSource.deleteEvent(eventId);
    print('✅ Événement supprimé localement');

    // 2. Si Google activé, supprime de Google
    if (_googleEnabled && googleDataSource != null) {
      try {
        await googleDataSource!.deleteEvent(eventId); // ← Ajoute !
        print('☁️ Événement supprimé de Google Calendar');
      } catch (e) {
        print('⚠️ Erreur suppression Google: $e');
      }
    }
  }

  @override
  Future<void> initializeGoogleCalendar(dynamic googleUser) async {
    if (googleDataSource == null) {
      throw Exception('Google DataSource non disponible');
    }

    try {
      await googleDataSource!.initialize(googleUser);
      _googleEnabled = true;
      print('✅ Google Calendar initialisé via Repository');
    } catch (e) {
      print('❌ Erreur initialisation Google Calendar: $e');
      rethrow;
    }
  }

  @override
  Future<void> syncLocalToGoogle() async {
    if (!_googleEnabled || googleDataSource == null) {
      throw Exception('Google Calendar non activé');
    }

    print('🔄 Synchronisation local → Google...');

    // Récupère tous les événements locaux
    final allLocalEvents = await localDataSource.getAllEvents();

    int synced = 0;
    int errors = 0;

    for (var model in allLocalEvents) {
      try {
        await googleDataSource!.addEvent(model); // ← Ajoute !
        synced++;
      } catch (e) {
        errors++;
        print('⚠️ Erreur sync événement ${model.title}: $e');
      }
    }

    print('✅ Sync terminée: $synced réussis, $errors erreurs');
  }

  @override
  Future<void> syncGoogleToLocal(DateTime startDate, DateTime endDate) async {
    if (!_googleEnabled || googleDataSource == null) {
      throw Exception('Google Calendar non activé');
    }

    print('🔄 Synchronisation Google → local...');

    // Récupère les événements Google sur la période
    int synced = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      try {
        final googleEvents = await googleDataSource!.getEventsForDay(
          currentDate,
        ); // ← Ajoute !

        for (var model in googleEvents) {
          // Vérifie si l'événement existe déjà en local
          final localEvents = await localDataSource.getEventsForDay(
            currentDate,
          );
          final exists = localEvents.any((e) => e.id == model.id);

          if (!exists) {
            await localDataSource.addEvent(model);
            synced++;
          }
        }
      } catch (e) {
        print('⚠️ Erreur sync jour $currentDate: $e');
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    print('✅ Sync Google→local terminée: $synced nouveaux événements');
  }
}
