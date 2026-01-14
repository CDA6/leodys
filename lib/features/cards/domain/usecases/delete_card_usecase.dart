import 'package:leodys/features/cards/data/cards_repository.dart';
import 'package:leodys/features/cards/domain/card_model.dart';

class DeleteCardUsecase {
  final CardsRepository repository;
  DeleteCardUsecase(this.repository);

  Future<void> call (CardModel card) async {
    await repository.deleteCard(card);
  }
}