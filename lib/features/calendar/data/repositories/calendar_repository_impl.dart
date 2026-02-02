import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../datasources/calendar_local_datasource.dart';
import '../datasources/calendar_google_datasource.dart';
import '../models/calendar_event_model.dart';

/// Implémentation du CalendarRepository avec synchronisation
class CalendarRepositoryImpl implements CalendarRepository {
  final CalendarLocalDataSource localDataSource;
  final CalendarGoogleDataSource? googleDataSource;

  CalendarRepositoryImpl({
    required this.localDataSource,
    this.googleDataSource,
  });

  bool _googleEnabled = false;

  @override
  void setGoogleCalendarEnabled(bool enabled) {
    _googleEnabled =
        enabled && googleDataSource != null && googleDataSource!.isReady;
  }

  @override
  bool isGoogleCalendarEnabled() => _googleEnabled;

  @override
  Future<List<CalendarEvent>> getEventsForDay(DateTime day) async {
    // 1. Récupère toujours les événements locaux
    final localModels = await localDataSource.getEventsForDay(day);
    final localEvents = localModels.map((m) => m.toEntity()).toList();

    // 2. Si Google activé ET disponible, fusionne avec Google Calendar
    if (_googleEnabled) {
      try {
        final googleModels = await googleDataSource!.getEventsForDay(day);
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

        return allEvents.values.toList();
      } catch (e) {
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

    // 2. Si Google activé ET disponible, sync vers Google
    if (_googleEnabled) {
      try {
        await googleDataSource!.addEvent(model);
      } catch (e) {}
    }
  }

  @override
  Future<void> updateEvent(CalendarEvent event) async {
    final model = CalendarEventModel.fromEntity(event);

    // 1. Met à jour en local
    await localDataSource.updateEvent(model);

    // 2. Si Google activé, sync vers Google
    if (_googleEnabled && googleDataSource != null) {
      try {
        await googleDataSource!.updateEvent(model);
      } catch (e) {
        print('Erreur sync Google: $e');
      }
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    // 1. Supprime en local
    await localDataSource.deleteEvent(eventId);
    print('Événement supprimé localement');

    // 2. Si Google activé, supprime de Google
    if (_googleEnabled && googleDataSource != null) {
      try {
        await googleDataSource!.deleteEvent(eventId);
        print('Événement supprimé de Google Calendar');
      } catch (e) {
        print('Erreur suppression Google: $e');
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
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> syncLocalToGoogle() async {
    if (!_googleEnabled || googleDataSource == null) {
      throw Exception('Google Calendar non activé');
    }

    // Récupère tous les événements locaux
    final allLocalEvents = await localDataSource.getAllEvents();

    int synced = 0;
    int errors = 0;

    for (var model in allLocalEvents) {
      try {
        await googleDataSource!.addEvent(model);
        synced++;
      } catch (e) {
        errors++;
        print('Erreur sync événement ${model.title}: $e');
      }
    }
  }

  @override
  Future<void> syncGoogleToLocal(DateTime startDate, DateTime endDate) async {
    if (!_googleEnabled || googleDataSource == null) {
      throw Exception('Google Calendar non activé');
    }

    int synced = 0;
    int deleted = 0;
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      try {
        // 1. Récupère les événements Google pour ce jour
        final googleEvents = await googleDataSource!.getEventsForDay(currentDate);
        final googleIds = googleEvents.map((e) => e.id).toSet();

        // 2. Récupère les événements locaux pour ce jour
        final localEvents = await localDataSource.getEventsForDay(currentDate);

        // 3. Ajoute les événements Google qui n'existent pas en local
        for (var model in googleEvents) {
          final exists = localEvents.any((e) => e.id == model.id);
          if (!exists) {
            await localDataSource.addEvent(model);
            synced++;
          }
        }

        // 4. ✅ NOUVEAU : Supprime les événements locaux qui n'existent plus dans Google
        for (var localEvent in localEvents) {
          if (!googleIds.contains(localEvent.id)) {
            await localDataSource.deleteEvent(localEvent.id);
            deleted++;
            print('🗑️ Événement supprimé en local: ${localEvent.title}');
          }
        }
      } catch (e) {
        print('⚠️ Erreur sync jour $currentDate: $e');
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    print('✅ Sync terminée: $synced ajoutés, $deleted supprimés');
  }
}
