import 'package:flutter/foundation.dart';
import '../../domain/usecases/sync_google_to_local.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_event_for_day.dart';
import '../../domain/usecases/add_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/initialize_google_calendar.dart';
import '../../domain/usecases/set_google_sync_enabled.dart';
import '../../domain/usecases/sync_local_to_google.dart';
import '../../domain/usecases/usecase.dart';

class CalendarController extends ChangeNotifier {

  final GetEventsForDay getEventsForDayUseCase;
  final AddEvent addEventUseCase;
  final UpdateEvent updateEventUseCase;
  final DeleteEvent deleteEventUseCase;
  final InitializeGoogleCalendar initializeGoogleCalendarUseCase;
  final SetGoogleSyncEnabled setGoogleSyncEnabledUseCase;
  final SyncLocalToGoogle syncLocalToGoogleUseCase;
  final SyncGoogleToLocal syncGoogleToLocalUseCase;

  // Cache des événements par jour
  final Map<String, List<CalendarEvent>> _eventsCache = {};

  late DateTime _selectedDay;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGoogleSyncEnabled = false;

  CalendarController({
    required this.getEventsForDayUseCase,
    required this.addEventUseCase,
    required this.updateEventUseCase,
    required this.deleteEventUseCase,
    required this.initializeGoogleCalendarUseCase,
    required this.setGoogleSyncEnabledUseCase,
    required this.syncLocalToGoogleUseCase,
    required this.syncGoogleToLocalUseCase,
  }){
    _selectedDay = _normalizeDate(DateTime.now());
  }

  // Récupère tous les événements en cache
  List<CalendarEvent> get events {
    final allEvents = <CalendarEvent>[];
    _eventsCache.forEach((date, events) {
      allEvents.addAll(events);
    });
    return allEvents;
  }

  DateTime get selectedDay => _selectedDay;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isGoogleSyncEnabled => _isGoogleSyncEnabled;

  /// Retourne les événements pour un jour spécifique
  List<CalendarEvent> getEventsForDay(DateTime day) {
    final key = _dateKey(day);
    return _eventsCache[key] ?? [];
  }

  /// Génère une clé de cache pour une date
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Normalise une date en supprimant l'heure
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void setGoogleSyncEnabled(bool enabled) {
    _isGoogleSyncEnabled = enabled;
    setGoogleSyncEnabledUseCase(enabled);

    notifyListeners();
  }

  /// Charge les événements pour un jour
  Future<void> loadEventsForDay(DateTime day) async {
    // Normalise toujours la date
    final normalizedDay = _normalizeDate(day);
    _selectedDay = normalizedDay;

    // Si déjà en cache, pas besoin de recharger
    final key = _dateKey(normalizedDay);
    if (_eventsCache.containsKey(key)) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final events = await getEventsForDayUseCase(normalizedDay);
      _eventsCache[key] = events;

    } catch (_) {
      _errorMessage = 'Erreur lors du chargement des événements';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge les événements pour une plage de dates (pour le mois visible)
  Future<void> loadEventsForRange(DateTime start, DateTime end) async {
    _isLoading = true;
    notifyListeners();

    try {
      DateTime currentDay = _normalizeDate(start);
      final normalizedEnd = _normalizeDate(end);

      while (currentDay.isBefore(normalizedEnd) ||
          currentDay.isAtSameMomentAs(normalizedEnd)) {
        final key = _dateKey(currentDay);

        // Charge seulement si pas déjà en cache
        if (!_eventsCache.containsKey(key)) {
          final events = await getEventsForDayUseCase(currentDay);
          _eventsCache[key] = events;
        }

        currentDay = currentDay.add(const Duration(days: 1));
      }

    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des événements';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Recharge la plage visible (mois courant +/- 1 mois)
  Future<void> _reloadVisibleRange() async {
    final now = _selectedDay;
    final start = DateTime(now.year, now.month - 1, 1);
    final end = DateTime(now.year, now.month + 2, 0);

    // Vide le cache seulement si Google est activé
    if (_isGoogleSyncEnabled) {
      _eventsCache.clear();
    }

    // Gère les erreurs
    try {
      await loadEventsForRange(start, end);
    } catch (e) {
      print('Erreur rechargement plage visible: $e');

    }
  }

  /// Ajoute un événement
  Future<void> addEvent(CalendarEvent event) async {
    try {
      await addEventUseCase(event);

      // Normalise la date avant de recharger
      final eventDate = _normalizeDate(event.startTime);
      final key = _dateKey(eventDate);
      _eventsCache.remove(key);
      await loadEventsForDay(eventDate);

      // Si le jour ajouté n'est pas le jour sélectionné, notifie quand même
      if (!_isSameDay(event.startTime, _selectedDay)) {
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de l\'événement';
      notifyListeners();
    }
  }

  /// Met à jour un événement
  Future<void> updateEvent(CalendarEvent event) async {
    try {
      await updateEventUseCase(event);

      // Normalise la date avant de recharger
      final eventDate = _normalizeDate(event.startTime);
      final key = _dateKey(eventDate);
      _eventsCache.remove(key);
      await loadEventsForDay(eventDate);
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de l\'événement';
      notifyListeners();
    }
  }

  /// Supprime un événement
  Future<void> deleteEvent(String eventId) async {
    try {

      // Trouve l'événement pour savoir quel jour invalider
      CalendarEvent? eventToDelete;
      for (var dayEvents in _eventsCache.values) {
        try {
          eventToDelete = dayEvents.firstWhere((e) => e.id == eventId);
          break;
        } catch (e) {
          // Continue à chercher
        }
      }

      await deleteEventUseCase(eventId);

      // Normalise la date et invalide le cache
      if (eventToDelete != null) {
        final eventDate = _normalizeDate(eventToDelete.startTime);
        final key = _dateKey(eventDate);
        _eventsCache.remove(key);
        await loadEventsForDay(eventDate);
      } else {
        await loadEventsForDay(_selectedDay);
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de l\'événement';
      notifyListeners();
    }
  }

  /// Initialise Google Calendar avec le compte Google connecté
  Future<void> initializeGoogleCalendar(dynamic googleUser) async {
    try {

      // 1. Initialise le datasource
      await initializeGoogleCalendarUseCase(googleUser);

      // 2. Active la sync
      _isGoogleSyncEnabled = true;

      notifyListeners();

      // 4. Recharge avec gestion d'erreur
      try {
        await _reloadVisibleRange();
      } catch (e) {
        print('Erreur rechargement avec Google: $e');
        // Continue quand même, les événements locaux sont là
      }
    } catch (e) {
      _isGoogleSyncEnabled = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Synchronise les événements locaux vers Google Calendar
  Future<void> syncLocalToGoogle() async {
    if (!_isGoogleSyncEnabled) {
      _errorMessage = 'Google Calendar non activé';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await syncLocalToGoogleUseCase(NoParams());

      // Recharge les événements
      await _reloadVisibleRange();
    } catch (e) {
      _errorMessage = 'Erreur lors de la synchronisation';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Synchronise Google Calendar vers local
  Future<void> syncGoogleToLocal({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!_isGoogleSyncEnabled) {
      _errorMessage = 'Google Calendar non activé';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final start =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now().add(const Duration(days: 90));

      await syncGoogleToLocalUseCase(
        SyncGoogleToLocalParams(startDate: start, endDate: end),
      );

      // Vide le cache et recharge
      _eventsCache.clear();
      await _reloadVisibleRange();
    } catch (e) {
      _errorMessage = 'Erreur lors de la synchronisation';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Vérifie si deux dates sont le même jour
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}