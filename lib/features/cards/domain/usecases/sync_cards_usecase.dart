import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../common/errors/failures.dart';
import '../../../../common/mixins/usecase_mixin.dart';
import '../../data/cards_repository.dart';

class SyncCardsUsecase with UseCaseMixin<void, void> {
  final CardsRepository repository;
  SyncCardsUsecase(this.repository);

  @override
  Future<Either<Failure, void>> execute (void _) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Right(unit);

    return repository.syncCards(user.id);
  }
}
