class CardModel {
  final String id;
  final String name;
  final String rectoPath;
  final String? versoPath;
  final String folderPath;
  final String syncStatus;     // PENDING / SYNCED
  final bool deleted;
  final DateTime updatedAt;

  CardModel({
    required this.id,
    required this.name,
    required this.rectoPath,
    this.versoPath,
    required this.folderPath,
    this.syncStatus = 'PENDING',
    this.deleted = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory CardModel.fromJson(Map<String, dynamic> json, {required String folderPath}) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      rectoPath: json['images']?['recto'] != null ? '$folderPath/${json['images']['recto']}' : '',
      versoPath: json['images']?['verso'] != null ? '$folderPath/${json['images']['verso']}' : '',
      folderPath: folderPath,
      syncStatus: json['sync_status'],
      deleted: json['deleted'] ?? false,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'CardModel{id: $id, name: $name, rectoPath: $rectoPath, versoPath: $versoPath, folderPath: $folderPath, syncStatus: $syncStatus, deleted: $deleted, updatedAt: $updatedAt}';
  }


}