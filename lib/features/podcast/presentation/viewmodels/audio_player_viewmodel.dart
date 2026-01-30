import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:leodys/common/utils/app_logger.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioPlayerViewModel extends ChangeNotifier {
  final AudioRepository audioRepository;

  AudioState _audioState = AudioState.initial();
  StreamSubscription<AudioState>? _audioSubscription;

  AudioPlayerViewModel({required this.audioRepository}) {
    _audioSubscription = audioRepository.audioStateStream.listen((state) {
      _audioState = state;
      notifyListeners();
    });
  }


  AudioState get audioState => _audioState;


  bool get isPlaying => _audioState.isPlaying;


  bool get hasCurrentEpisode => _audioState.hasCurrentEpisode;


  Future<void> playEpisode({
    required String url,
    required String title,
    String? imageUrl,
  }) async {
    final result = await audioRepository.playEpisode(
      url: url,
      title: title,
      imageUrl: imageUrl,
    );

    result.fold(
      (failure) => AppLogger().error('Erreur de lecture: ${failure.message}'),
      (_) => AppLogger().info('Lecture: $title'),
    );
  }


  Future<void> pauseResume() async {
    final result = await audioRepository.pauseResume();
    result.fold(
      (failure) => AppLogger().error('Erreur pause/reprise: ${failure.message}'),
      (_) {},
    );
  }


  Future<void> seek(Duration position) async {
    final result = await audioRepository.seek(position);
    result.fold(
      (failure) => AppLogger().error('Erreur seek: ${failure.message}'),
      (_) {},
    );
  }


  Future<void> skipBackward() async {
    final result = await audioRepository.skipBackward();
    result.fold(
      (failure) => AppLogger().error('Erreur skip backward: ${failure.message}'),
      (_) {},
    );
  }


  Future<void> skipForward() async {
    final result = await audioRepository.skipForward();
    result.fold(
      (failure) => AppLogger().error('Erreur skip forward: ${failure.message}'),
      (_) {},
    );
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    super.dispose();
  }
}
