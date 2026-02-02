import 'package:flutter/material.dart';
import '../../domain/entities/calendar_event.dart';

/// Dialog pour modifier un événement existant
class EditEventDialog extends StatefulWidget {
  final CalendarEvent event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;

  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late bool _isAllDay;

  @override
  void initState() {
    super.initState();

    // Initialise avec les valeurs de l'événement
    _titleController = TextEditingController(text: widget.event.title);
    _descriptionController = TextEditingController(
      text: widget.event.description ?? '',
    );
    _locationController = TextEditingController(
      text: widget.event.location ?? '',
    );

    _startTime = TimeOfDay.fromDateTime(widget.event.startTime);
    _endTime = TimeOfDay.fromDateTime(widget.event.endTime);
    _isAllDay = widget.event.isAllDay;
  }

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
      title: const Text('Modifier l\'événement'),
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

              // Heure de début et fin
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

        // Bouton Enregistrer
        ElevatedButton(onPressed: _saveEvent, child: const Text('Enregistrer')),
      ],
    );
  }

  /// Sauvegarde les modifications
  void _saveEvent() {
    if (_formKey.currentState!.validate()) {
      // Crée les DateTime pour début et fin
      final startDateTime = _isAllDay
          ? DateTime(
              widget.event.startTime.year,
              widget.event.startTime.month,
              widget.event.startTime.day,
            )
          : DateTime(
              widget.event.startTime.year,
              widget.event.startTime.month,
              widget.event.startTime.day,
              _startTime.hour,
              _startTime.minute,
            );

      final endDateTime = _isAllDay
          ? DateTime(
              widget.event.startTime.year,
              widget.event.startTime.month,
              widget.event.startTime.day,
            )
          : DateTime(
              widget.event.startTime.year,
              widget.event.startTime.month,
              widget.event.startTime.day,
              _endTime.hour,
              _endTime.minute,
            );

      // Crée l'événement modifié (garde le même ID)
      final updatedEvent = CalendarEvent(
        id: widget.event.id,
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

      // Retourne l'événement modifié
      Navigator.of(context).pop(updatedEvent);
    }
  }
}
