import 'package:get_it/get_it.dart';
import 'data/repositories/clock_repository_impl.dart';
import 'domain/repositories/clock_repository.dart';
import 'presentation/viewmodel/voice_clock_viewmodel.dart';
import '../notification/presentation/controllers/tts_controller.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<IClockRepository>(() => ClockRepositoryImpl());
  sl.registerFactory(() => VoiceClockViewModel(sl(), TtsController()));
}