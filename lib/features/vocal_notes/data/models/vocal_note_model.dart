import 'package:leodys/features/vocal_notes/domain/entities/vocal_note_entity.dart';

class VocalNoteModel extends VocalNoteEntity {
  const VocalNoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  // ============================================
  // JSON Serialization (Supabase / API)
  // ============================================

  factory VocalNoteModel.fromJson(Map<String, dynamic> json) {
    return VocalNoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ============================================
  // Hive Serialization (Local DB)
  // ============================================

  factory VocalNoteModel.fromHive(Map<dynamic, dynamic> data) {
    return VocalNoteModel(
      id: data['id'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
      deletedAt: data['deleted_at'] != null
          ? DateTime.parse(data['deleted_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toHive() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ============================================
  // CopyWith (Immutabilité)
  // ============================================

  VocalNoteModel copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return VocalNoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
