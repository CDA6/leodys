import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:leodys/features/vocal_notes/data/datasources/vocal_note_local_datasource.dart';
import 'package:leodys/features/vocal_notes/data/datasources/vocal_note_remote_datasource.dart';
import 'package:leodys/features/vocal_notes/data/repositories/vocal_note_repository_impl.dart';
import 'package:leodys/features/vocal_notes/data/services/speech_service.dart';
import 'package:leodys/features/vocal_notes/domain/repositories/vocal_note_repository.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/delete_note_usecase.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/get_all_notes_usecase.dart';
import 'package:leodys/features/vocal_notes/domain/usecases/save_note_usecase.dart';
import 'package:leodys/features/vocal_notes/presentation/viewmodels/vocal_notes_viewmodel.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

/// Navigator key pour accéder au context - doit être assigné depuis main.dart
late final GlobalKey<NavigatorState> _navigatorKey;

Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
  _navigatorKey = navigatorKey;

  /// ViewModel
  sl.registerFactory<VocalNotesViewModel>(
    () => VocalNotesViewModel(
      speechService: sl<SpeechService>(),
      getAllNotesUseCase: sl<GetAllNotesUseCase>(),
      saveNoteUseCase: sl<SaveNoteUseCase>(),
      deleteNoteUseCase: sl<DeleteNoteUseCase>(),
    ),
  );

  /// UseCases
  sl.registerLazySingleton(() => GetAllNotesUseCase(sl()));
  sl.registerLazySingleton(() => SaveNoteUseCase(sl()));
  sl.registerLazySingleton(() => DeleteNoteUseCase(sl()));

  /// Services - créé lazily avec le context du navigator
  sl.registerLazySingleton<SpeechService>(
    () => SpeechService(_navigatorKey.currentContext!),
  );

  /// Data Sources
  final box = await Hive.openBox('vocal_notes');
  sl.registerLazySingleton<VocalNoteLocalDataSource>(
    () => VocalNoteLocalDataSourceImpl(box),
  );

  sl.registerLazySingleton<VocalNoteRemoteDataSource>(
    () => VocalNoteRemoteDataSourceImpl(Supabase.instance.client),
  );

  /// Repository
  sl.registerLazySingleton<VocalNoteRepository>(
    () =>
        VocalNoteRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );
}
