import 'package:leodys/features/text_simplification/domain/entities/text_simplification_entity.dart';

class TextSimplificationModel extends TextSimplificationEntity {
  const TextSimplificationModel({
    required super.id,
    required super.originalText,
    required super.simplifiedText,
    required super.createdAt,
    required super.updatedAt,
    super.deletedAt,
  });

  // ============================================
  // JSON Serialization (Supabase / API)
  // ============================================

  factory TextSimplificationModel.fromJson(Map<String, dynamic> json) {
    return TextSimplificationModel(
      id: json['id'] as String,
      originalText: json['original_text'] as String,
      simplifiedText: json['simplified_text'] as String,
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
      'original_text': originalText,
      'simplified_text': simplifiedText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ============================================
  // Hive Serialization (Local DB)
  // ============================================

  factory TextSimplificationModel.fromHive(Map<dynamic, dynamic> data) {
    return TextSimplificationModel(
      id: data['id'] as String,
      originalText: data['original_text'] as String,
      simplifiedText: data['simplified_text'] as String,
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
      'original_text': originalText,
      'simplified_text': simplifiedText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
    };
  }

  // ============================================
  // CopyWith (Immutabilite)
  // ============================================

  TextSimplificationModel copyWith({
    String? id,
    String? originalText,
    String? simplifiedText,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return TextSimplificationModel(
      id: id ?? this.id,
      originalText: originalText ?? this.originalText,
      simplifiedText: simplifiedText ?? this.simplifiedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
