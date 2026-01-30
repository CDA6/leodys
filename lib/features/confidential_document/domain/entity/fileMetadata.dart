import 'package:leodys/features/confidential_document/domain/entity/status_enum.dart';

class FileMetadata {
  final String title;
  final SyncStatus status;
  final DateTime lastUpdated;

  FileMetadata({
    required this.title,
    required this.status,
    required this.lastUpdated,
  });

  // Conversion pour le stockage JSON
  Map<String, dynamic> toJson() => {
    'title': title,
    'status': status.name,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory FileMetadata.fromJson(Map<String, dynamic> json) => FileMetadata(
    title: json['title'],
    status: SyncStatus.values.byName(json['status']),
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}