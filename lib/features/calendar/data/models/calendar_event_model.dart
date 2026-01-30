import 'package:hive/hive.dart';
import '../../domain/entities/calendar_event.dart';

part 'calendar_event_model.g.dart';

/// Model de CalendarEvent pour le stockage et la sérialisation
@HiveType(typeId: 2)
class CalendarEventModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? description;

  @HiveField(3)
  final DateTime startTime;

  @HiveField(4)
  final DateTime endTime;

  @HiveField(5)
  final String? location;

  @HiveField(6)
  final bool isAllDay;

  CalendarEventModel({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.location,
    required this.isAllDay,
  });

  /// Crée un model depuis une entité
  factory CalendarEventModel.fromEntity(CalendarEvent entity) {
    return CalendarEventModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      startTime: entity.startTime,
      endTime: entity.endTime,
      location: entity.location,
      isAllDay: entity.isAllDay,
    );
  }

  /// Crée un model depuis JSON
  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      location: json['location'] as String?,
      isAllDay: json['is_all_day'] as bool? ?? false,
    );
  }

  /// Convertit le model en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'is_all_day': isAllDay,
    };
  }

  /// Convertit le model en entité
  CalendarEvent toEntity() {
    return CalendarEvent(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      endTime: endTime,
      location: location,
      isAllDay: isAllDay,
    );
  }
}