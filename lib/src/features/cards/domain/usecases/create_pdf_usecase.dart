import 'dart:io';
import 'package:leodys/src/features/cards/data/cards_repository.dart';

class CreatePdfUsecase {
  final CardsRepository repository;

  CreatePdfUsecase(this.repository);

  Future<File> call(List<String> imagesPaths) async {
    return await repository.createPdfFromImages(imagesPaths);
  }
}