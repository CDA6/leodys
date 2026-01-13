import 'package:leodys/src/features/cards/data/cards_remote_datasource.dart';
import 'package:leodys/src/features/cards/domain/usecases/create_pdf_usecase.dart';
import 'package:leodys/src/features/cards/domain/usecases/upload_card_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/cards_repository.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final cardsRemoteDatasourceProvider = Provider<CardsRemoteDatasource>((ref) {
  final supabase = ref.read(supabaseClientProvider);
  return CardsRemoteDatasource(supabase: supabase);
});

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  final datasource = ref.read(cardsRemoteDatasourceProvider);
  return CardsRepository(datasource);
});

final createPdfUseCaseProvider = Provider<CreatePdfUsecase>((ref) {
  return CreatePdfUsecase(ref.read(cardsRepositoryProvider));
});

final uploadCardUseCaseProvider = Provider<UploadCardUsecase>((ref) {
  return UploadCardUsecase(ref.read(cardsRepositoryProvider));
});