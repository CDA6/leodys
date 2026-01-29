import 'package:get_it/get_it.dart';
import 'package:leodys/features/vocal_notes/data/services/speech_service.dart';
import 'package:leodys/features/vocal_notes/injection_container.dart' as vocal_notes;

import 'data/repositories/vocal_chat_repository_impl.dart';
import 'data/services/openrouter_service.dart';
import 'domain/repositories/vocal_chat_repository.dart';
import 'domain/usecases/send_chat_message_usecase.dart';
import 'presentation/viewmodels/vocal_chat_viewmodel.dart';

final sl = GetIt.instance;

/// Initialise les dépendances de la feature vocal_chat.
///
/// Note: Cette feature réutilise le [SpeechService] enregistré dans vocal_notes.
/// Assurez-vous que vocal_notes.init() est appelé avant vocal_chat.init().
Future<void> init() async {
  /// Services - singleton (doit être enregistré en premier)
  sl.registerLazySingleton<OpenRouterService>(() => OpenRouterService());

  /// Repository - singleton (dépend de OpenRouterService)
  sl.registerLazySingleton<VocalChatRepository>(
    () => VocalChatRepositoryImpl(sl<OpenRouterService>()),
  );

  /// UseCases - singleton (dépend de VocalChatRepository)
  sl.registerLazySingleton<SendChatMessageUseCase>(
    () => SendChatMessageUseCase(sl<VocalChatRepository>()),
  );

  /// ViewModel - factory (nouvelle instance à chaque fois)
  sl.registerFactory<VocalChatViewModel>(
    () => VocalChatViewModel(
      speechService: vocal_notes.sl<SpeechService>(),
      sendChatMessageUseCase: sl<SendChatMessageUseCase>(),
    ),
  );
}
