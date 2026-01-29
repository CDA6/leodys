import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:leodys/features/calendar/domain/entities/calendar_event.dart';
import 'package:leodys/features/calendar/presentation/controllers/calendar_controller.dart';
import 'package:leodys/features/calendar/presentation/widgets/add_event_dialog.dart';
import 'package:leodys/features/authentication/domain/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

/// Page principale du calendrier
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  static const route = '/calendar';

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Charge les événements du jour actuel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarController>().loadEventsForDay(_selectedDay!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendrier'),
        actions: [
          // ✅ Indicateur de synchronisation Google
          Consumer<CalendarController>(
            builder: (context, controller, child) {
              return IconButton(
                icon: Icon(
                  controller.isGoogleSyncEnabled
                      ? Icons.cloud_done
                      : Icons.cloud_off,
                  color: controller.isGoogleSyncEnabled
                      ? Colors.green
                      : Colors.grey,
                ),
                onPressed: () => _showSyncDialog(context),
                tooltip: controller.isGoogleSyncEnabled
                    ? 'Synchronisé avec Google Calendar'
                    : 'Google Calendar désactivé',
              );
            },
          ),
        ],
      ),
      body: Consumer<CalendarController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              // ✅ Bannière de statut de sync
              if (controller.isGoogleSyncEnabled)
                Container(
                  width: double.infinity,
                  color: Colors.green.shade50,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_done,
                        size: 16,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Synchronisé avec Google Calendar',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Le calendrier
              TableCalendar(
                locale: 'fr_FR',
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                startingDayOfWeek: StartingDayOfWeek.monday,
                availableCalendarFormats: const {
                  CalendarFormat.month: 'Mois',
                  CalendarFormat.twoWeeks: '2 semaines',
                  CalendarFormat.week: 'Semaine',
                },
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },

                // Charge les événements pour afficher les marqueurs
                eventLoader: (day) {
                  return controller.getEventsForDay(day);
                },

                // Quand on sélectionne un jour
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    // Charge les événements du jour sélectionné
                    controller.loadEventsForDay(selectedDay);
                  }
                },

                // Quand on change de format
                onFormatChanged: (format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                },

                // Quand on swipe entre les mois
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
              ),

              // Bouton ajouter sous le calendrier à droite
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        // Ouvre le dialog
                        final event = await showDialog<CalendarEvent>(
                          context: context,
                          builder: (context) => AddEventDialog(
                            selectedDay: _selectedDay ?? DateTime.now(),
                          ),
                        );

                        // Si un événement a été créé
                        if (event != null && mounted) {
                          // Ajoute l'événement via le controller
                          await controller.addEvent(event);
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Nouvel événement'),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Liste des événements du jour sélectionné
              Expanded(child: _buildEventsList(controller)),
            ],
          );
        },
      ),
    );
  }

  /// Construit la liste des événements
  Widget _buildEventsList(CalendarController controller) {
    // Si en cours de chargement
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Si erreur
    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          'Erreur: ${controller.errorMessage}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    // Récupère les événements du jour sélectionné
    final events = controller.getEventsForDay(_selectedDay!);

    // Si aucun événement
    if (events.isEmpty) {
      return const Center(child: Text('Aucun événement pour ce jour'));
    }

    // Affiche la liste des événements
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return ListTile(
          title: Text(event.title),
          subtitle: event.description != null ? Text(event.description!) : null,
          trailing: event.isAllDay
              ? const Text('Toute la journée')
              : Text(
                  '${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')}',
                ),
        );
      },
    );
  }

  /// Affiche un dialog pour gérer la synchronisation
  void _showSyncDialog(BuildContext context) {
    final controller = context.read<CalendarController>();
    final authService = context.read<AuthService>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Synchronisation Google Calendar'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!authService.isAuthenticated)
                const Text(
                  'Vous devez être connecté avec Google pour activer la synchronisation.',
                )
              else if (!controller.isGoogleSyncEnabled)
                const Text(
                  'Activez la synchronisation pour enregistrer vos événements dans Google Calendar.',
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('✅ Synchronisation active'),
                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text(
                        'Envoyer événements locaux vers Google',
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _syncLocalToGoogle(context, controller);
                      },
                    ),

                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      icon: const Icon(Icons.cloud_download),
                      label: const Text('Importer depuis Google Calendar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _syncGoogleToLocal(context, controller);
                      },
                    ),

                    const SizedBox(height: 12),

                    OutlinedButton.icon(
                      icon: const Icon(Icons.cloud_off),
                      label: const Text('Désactiver la synchronisation'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        controller.setGoogleSyncEnabled(false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Synchronisation désactivée'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          if (!authService.isAuthenticated)
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Connectez-vous d\'abord avec Google'),
                  ),
                );
              },
              child: const Text('OK'),
            )
          else if (!controller.isGoogleSyncEnabled)
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _activateGoogleSync(context, controller);
              },
              child: const Text('Activer'),
            ),

          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  /// Active la synchronisation Google
  Future<void> _activateGoogleSync(
    BuildContext context,
    CalendarController controller,
  ) async {
    final googleUser = await GoogleSignIn.instance.authenticate();

    if (googleUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Aucun compte Google connecté')),
        );
      }
      return;
    }

    try {
      // ✅ Passe par le controller au lieu d'accéder au repository directement
      await controller.initializeGoogleCalendar(googleUser);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Synchronisation Google Calendar activée'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Synchronise local vers Google
  Future<void> _syncLocalToGoogle(
    BuildContext context,
    CalendarController controller,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Envoi vers Google...'),
          ],
        ),
      ),
    );

    try {
      await controller.syncLocalToGoogle();

      if (context.mounted) {
        Navigator.pop(context); // Ferme le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Événements envoyés vers Google Calendar'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Synchronise Google vers local
  Future<void> _syncGoogleToLocal(
    BuildContext context,
    CalendarController controller,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Import depuis Google...'),
          ],
        ),
      ),
    );

    try {
      await controller.syncGoogleToLocal();

      if (context.mounted) {
        Navigator.pop(context); // Ferme le dialog de chargement
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Événements importés depuis Google Calendar'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
