import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/calendar_event.dart';

/// Dialog pour ajouter un nouvel événement
class AddEventDialog extends StatefulWidget {
  final DateTime selectedDay;

  const AddEventDialog({super.key, required this.selectedDay});

  @override
  State<AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: 0);
  bool _isAllDay = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nouvel événement'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre (obligatoire)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titre *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le titre est obligatoire';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description (optionnel)
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Lieu (optionnel)
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              // Journée entière
              SwitchListTile(
                title: const Text('Journée entière'),
                value: _isAllDay,
                onChanged: (value) {
                  setState(() {
                    _isAllDay = value;
                  });
                },
              ),

              // Heure de début
              if (!_isAllDay) ...[
                const SizedBox(height: 8),
                // Heure de début
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Heure de début'),
                  trailing: Text(_startTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _startTime,
                      initialEntryMode: TimePickerEntryMode.input,
                      // ← Ajoute ça
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = time;
                      });
                    }
                  },
                ),

                // Heure de fin
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Heure de fin'),
                  trailing: Text(_endTime.format(context)),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _endTime,
                      initialEntryMode: TimePickerEntryMode.input,
                      // ← Ajoute ça
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(
                            context,
                          ).copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = time;
                      });
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        // Bouton Annuler
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),

        // Bouton Ajouter
        ElevatedButton(onPressed: _saveEvent, child: const Text('Ajouter')),
      ],
    );
  }

  /// Sauvegarde l'événement
  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Crée les DateTime pour début et fin
      final startDateTime = _isAllDay
          ? DateTime(
              widget.selectedDay.year,
              widget.selectedDay.month,
              widget.selectedDay.day,
            )
          : DateTime(
              widget.selectedDay.year,
              widget.selectedDay.month,
              widget.selectedDay.day,
              _startTime.hour,
              _startTime.minute,
            );

      final endDateTime = _isAllDay
          ? DateTime(
              widget.selectedDay.year,
              widget.selectedDay.month,
              widget.selectedDay.day,
              23,
              59,
            )
          : DateTime(
              widget.selectedDay.year,
              widget.selectedDay.month,
              widget.selectedDay.day,
              _endTime.hour,
              _endTime.minute,
            );

      // Crée l'événement
      final event = CalendarEvent(
        id: const Uuid().v4(),
        // Génère un ID unique
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        startTime: startDateTime,
        endTime: endDateTime,
        location: _locationController.text.isEmpty
            ? null
            : _locationController.text,
        isAllDay: _isAllDay,
      );

      // Retourne l'événement
      Navigator.of(context).pop(event);
    }
  }
}
