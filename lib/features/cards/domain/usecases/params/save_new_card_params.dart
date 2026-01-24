import 'dart:io';

class SaveNewCardParams {
  final List<File> imageFiles;
  final String name;

  const SaveNewCardParams(
    this.imageFiles,
    this.name
  );
}