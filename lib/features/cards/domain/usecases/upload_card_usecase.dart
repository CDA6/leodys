import 'dart:io';

import 'package:leodys/features/cards/data/cards_repository.dart';

class UploadCardUsecase {
  final CardsRepository repository;
  UploadCardUsecase(this.repository);

  Future<void> call (File file, String userId, String name) async {
    await repository.uploadCard(file, userId, name);
  }
}