import 'package:flutter/foundation.dart';
import 'package:leodys/features/calendar/domain/usecases/sync_google_to_local.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/usecases/get_event_for_day.dart';
import '../../domain/usecases/add_event.dart';
import '../../domain/usecases/update_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/initialize_google_calendar.dart';
import '../../domain/usecases/set_google_sync_enabled.dart';
import '../../domain/usecases/sync_local_to_google.dart';
import '../../domain/usecases/usecase.dart';

/// Controller pour gérer l'état du calendrier
class CalendarController extends ChangeNotifier {
  final GetEventsForDay getEventsForDayUseCase = GetEventsForDay();
  final AddEvent addEventUseCase = AddEvent();
  final UpdateEvent updateEventUseCase = UpdateEvent();
  final DeleteEvent deleteEventUseCase = DeleteEvent();
  final InitializeGoogleCalendar initializeGoogleCalendarUseCase = InitializeGoogleCalendar();
  final SetGoogleSyncEnabled setGoogleSyncEnabledUseCase = SetGoogleSyncEnabled();
  final SyncLocalToGoogle syncLocalToGoogleUseCase = SyncLocalToGoogle();
  final SyncGoogleToLocal syncGoogleToLocalUseCase = SyncGoogleToLocal();

  List<CalendarEvent> _events = [];
  DateTime _selectedDay = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isGoogleSyncEnabled = false;

  List<CalendarEvent> get events => _events;
  DateTime get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isGoogleSyncEnabled => _isGoogleSyncEnabled;

  /// Retourne les événements pour un jour spécifique (pour le calendrier)
  List<CalendarEvent> getEventsForDay(DateTime day) {
    return _events.where((event) {
      final eventDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );
      final targetDate = DateTime(day.year, day.month, day.day);
      return eventDate.isAtSameMomentAs(targetDate);
    }).toList();
  }

  /// Active/désactive la synchronisation Google Calendar
  void setGoogleSyncEnabled(bool enabled) {
    _isGoogleSyncEnabled = enabled;
    setGoogleSyncEnabledUseCase(enabled);

    if (enabled) {
      print('✅ Synchronisation Google Calendar activée');
      // Recharge les événements avec Google
      loadEventsForDay(_selectedDay);
    } else {
      print('❌ Synchronisation Google Calendar désactivée');
    }

    notifyListeners();
  }

  /// Charge les événements pour un jour
  Future<void> loadEventsForDay(DateTime day) async {
    _isLoading = true;
    _errorMessage = null;
    _selectedDay = day;
    notifyListeners();

    try {
      _events = await getEventsForDayUseCase(day);
      print('✅ Événements chargés pour $day : ${_events.length} événements');
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des événements: $e';
      print('❌ Erreur : $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Ajoute un événement
  Future<void> addEvent(CalendarEvent event) async {
    try {
      print('📝 Ajout événement : ${event.title} pour ${event.startTime}');
      await addEventUseCase(event);
      print('✅ Événement ajouté avec succès');

      // Recharge les événements du jour sélectionné
      await loadEventsForDay(_selectedDay);
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'ajout de l\'événement: $e';
      print('❌ Erreur ajout : $e');
      notifyListeners();
    }
  }

  /// Met à jour un événement
  Future<void> updateEvent(CalendarEvent event) async {
    try {
      print('📝 Mise à jour événement : ${event.title}');
      await updateEventUseCase(event);
      print('✅ Événement mis à jour avec succès');

      // Recharge les événements du jour sélectionné
      await loadEventsForDay(_selectedDay);
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour de l\'événement: $e';
      print('❌ Erreur mise à jour : $e');
      notifyListeners();
    }
  }

  /// Supprime un événement
  Future<void> deleteEvent(String eventId) async {
    try {
      print('🗑️ Suppression événement : $eventId');
      await deleteEventUseCase(eventId);
      print('✅ Événement supprimé avec succès');

      // Recharge les événements du jour sélectionné
      await loadEventsForDay(_selectedDay);
    } catch (e) {
      _errorMessage = 'Erreur lors de la suppression de l\'événement: $e';
      print('❌ Erreur suppression : $e');
      notifyListeners();
    }
  }

  /// Initialise Google Calendar avec le compte Google connecté
  Future<void> initializeGoogleCalendar(dynamic googleUser) async {
    try {
      await initializeGoogleCalendarUseCase(googleUser);
      _isGoogleSyncEnabled = true;
      notifyListeners();
      print('✅ Google Calendar initialisé avec succès');
    } catch (e) {
      print('❌ Erreur initialisation Google Calendar: $e');
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
      print('✅ Synchronisation local → Google terminée');

      // Recharge les événements
      await loadEventsForDay(_selectedDay);
    } catch (e) {
      _errorMessage = 'Erreur lors de la synchronisation: $e';
      print('❌ Erreur sync : $e');
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
      final start = startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final end = endDate ?? DateTime.now().add(const Duration(days: 90));

      await syncGoogleToLocalUseCase(SyncGoogleToLocalParams(
        startDate: start,
        endDate: end,
      ));
      print('✅ Synchronisation Google → local terminée');

      // Recharge les événements
      await loadEventsForDay(_selectedDay);
    } catch (e) {
      _errorMessage = 'Erreur lors de la synchronisation: $e';
      print('❌ Erreur sync : $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}