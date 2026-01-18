import 'package:leodys/features/cards/data/datasources/remote/cards_remote_datasource.dart';
import 'package:leodys/features/cards/data/sync/cards_sync_manager.dart';
import 'package:leodys/features/cards/domain/usecases/delete_card_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/get_local_user_cards_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/save_new_card_usecase.dart';
import 'package:leodys/features/cards/domain/usecases/upload_card_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/cards_repository.dart';
import 'data/datasources/local/cards_local_datasource.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final cardsRemoteDatasourceProvider = Provider<CardsRemoteDatasource>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  return CardsRemoteDatasource(supabase: supabase);
});

final cardsLocalDatasourceProvider = Provider<CardsLocalDatasource>((ref) {
  return CardsLocalDatasource();
});

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  final remoteDatasource = ref.read(cardsRemoteDatasourceProvider);
  final localDatasource = ref.read(cardsLocalDatasourceProvider);
  return CardsRepository(remoteDatasource, localDatasource);
});

final uploadCardUseCaseProvider = Provider<UploadCardUsecase>((ref) {
  return UploadCardUsecase(ref.read(cardsRepositoryProvider));
});

final cardSyncManagerProvider = Provider<CardSyncManager>((ref) {
  return CardSyncManager(local: ref.read(cardsLocalDatasourceProvider), remote: ref.read(cardsRemoteDatasourceProvider));
});

final saveNewCardUseCaseProvider = Provider<SaveNewCardUsecase>((ref) {
  return SaveNewCardUsecase(ref.read(cardsRepositoryProvider), ref.read(cardSyncManagerProvider));
});

final getLocalUserCardsUseCaseProvider = Provider<GetLocalUserCardsUsecase>((ref) {
  return GetLocalUserCardsUsecase(ref.read(cardsRepositoryProvider), ref.read(cardSyncManagerProvider));
});

final deleteCardUseCaseProvider = Provider<DeleteCardUsecase>((ref) {
  return DeleteCardUsecase(ref.read(cardsRepositoryProvider), ref.read(cardSyncManagerProvider));
});