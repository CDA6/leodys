class CardModel {
  final String name;
  final String rectoPath;
  final String? versoPath;
  final String? folderPath;

  CardModel({
    required this.name,
    required this.rectoPath,
    this.versoPath,
    this.folderPath
  });
}