import 'dart:io';
import 'package:leodys/features/cards/data/cards_repository.dart';

class CreatePdfUsecase {
  final CardsRepository repository;

  CreatePdfUsecase(this.repository);

  Future<File> call(List<String> imagesPaths, String name) async {
    return await repository.createPdfFromImages(imagesPaths, name);
  }
}