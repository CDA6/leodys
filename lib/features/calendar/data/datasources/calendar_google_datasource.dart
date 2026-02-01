import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar_api;
import 'package:http/http.dart' as http;
import '../models/calendar_event_model.dart';

class CalendarGoogleDataSource {
  static const String _calendarScope =
      'https://www.googleapis.com/auth/calendar';

  calendar_api.CalendarApi? _calendarApi;
  GoogleSignInAccount? _currentUser;


  /// Initialise l'API avec le compte Google connecté
  Future<void> initialize(GoogleSignInAccount googleUser) async {
    _currentUser = googleUser;

    // Obtient les tokens d'autorisation pour Calendar
    final authHeaders = await googleUser.authorizationClient
        .authorizationHeaders([_calendarScope]);

    if (authHeaders == null) {
      // Demande l'autorisation explicitement
      final auth = await googleUser.authorizationClient.authorizeScopes([
        _calendarScope,
      ]);

      final client = _AuthenticatedClient(auth.accessToken);
      _calendarApi = calendar_api.CalendarApi(client);
    } else {
      final client = _AuthenticatedClientFromHeaders(authHeaders);
      _calendarApi = calendar_api.CalendarApi(client);
    }
  }

  /// Vérifie si l'API est prête
  bool get isReady => _calendarApi != null;

  /// Récupère les événements pour un jour
  Future<List<CalendarEventModel>> getEventsForDay(DateTime day) async {
    if (_calendarApi == null) {
      throw Exception('API non initialisée.');
    }

    final startOfDay = DateTime(day.year, day.month, day.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: startOfDay.toUtc(),
        timeMax: endOfDay.toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
        showDeleted: false,
      );

      if (events.items == null) return [];

      return events.items!.map((event) {
        // Si dateTime existe, c'est un événement avec heure
        // Sinon, date est un DateTime (événement toute la journée)

        final startTime =
            event.start?.dateTime?.toLocal() ??
            event.start?.date ??
            DateTime.now();

        final endTime =
            event.end?.dateTime?.toLocal() ?? event.end?.date ?? DateTime.now();

        return CalendarEventModel(
          id: event.id ?? '',
          title: event.summary ?? 'Sans titre',
          description: event.description,
          startTime: startTime,
          endTime: endTime,
          location: event.location,
          isAllDay: event.start?.date != null,
        );
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des événements');
    }
  }

  /// Ajoute un événement
  Future<void> addEvent(CalendarEventModel event) async {
    if (_calendarApi == null) {
      throw Exception('API non initialisée');
    }

    final googleEvent = calendar_api.Event(
      id: event.id,
      summary: event.title,
      description: event.description,
      location: event.location,
    );

    if (event.isAllDay) {
      final startDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      final endDate = DateTime(
        event.endTime.year,
        event.endTime.month,
        event.endTime.day,
      ).add(const Duration(days: 1));

      googleEvent.start = calendar_api.EventDateTime(date: startDate);

      googleEvent.end = calendar_api.EventDateTime(date: endDate);
    } else {
      googleEvent.start = calendar_api.EventDateTime(
        dateTime: event.startTime.toUtc(),
      );
      googleEvent.end = calendar_api.EventDateTime(
        dateTime: event.endTime.toUtc(),
      );
    }

    try {
      await _calendarApi!.events.insert(googleEvent, 'primary');
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'événement');
    }
  }

  /// Met à jour un événement
  Future<void> updateEvent(CalendarEventModel event) async {
    if (_calendarApi == null) {
      throw Exception('API non initialisée');
    }

    final googleEvent = calendar_api.Event(
      summary: event.title,
      description: event.description,
      location: event.location,
    );

    if (event.isAllDay) {
      // Sinon, date est un DateTime (événement toute la journée)

      final startDate = DateTime(
        event.startTime.year,
        event.startTime.month,
        event.startTime.day,
      );

      final endDate = DateTime(
        event.endTime.year,
        event.endTime.month,
        event.endTime.day,
      ).add(const Duration(days: 1));

      googleEvent.start = calendar_api.EventDateTime(date: startDate);

      googleEvent.end = calendar_api.EventDateTime(date: endDate);
    } else {
      googleEvent.start = calendar_api.EventDateTime(
        dateTime: event.startTime.toUtc(),
      );
      googleEvent.end = calendar_api.EventDateTime(
        dateTime: event.endTime.toUtc(),
      );
    }

    try {
      await _calendarApi!.events.update(googleEvent, 'primary', event.id);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'événement');
    }
  }

  /// Supprime un événement
  Future<void> deleteEvent(String eventId) async {
    if (_calendarApi == null) {
      throw Exception('API non initialisée');
    }

    try {
      await _calendarApi!.events.delete('primary', eventId);
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'événement');
    }
  }
}

/// Client HTTP authentifié avec access token
class _AuthenticatedClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _inner = http.Client();

  _AuthenticatedClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _inner.send(request);
  }
}

/// Client HTTP authentifié avec headers
class _AuthenticatedClientFromHeaders extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  _AuthenticatedClientFromHeaders(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }


}
