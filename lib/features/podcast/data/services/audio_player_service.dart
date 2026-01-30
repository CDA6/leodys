import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/repositories/audio_repository.dart';


class AudioPlayerService {

  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  final _stateController = StreamController<AudioState>.broadcast();

  AudioState _currentState = AudioState.initial();


  Stream<AudioState> get stateStream => _stateController.stream;


  AudioState get currentState => _currentState;

  void init() {
    _player.onPlayerStateChanged.listen((state) {
      _updateState(isPlaying: state == PlayerState.playing);
    });

    _player.onDurationChanged.listen((duration) {
      _updateState(duration: duration);
    });

    _player.onPositionChanged.listen((position) {
      _updateState(position: position);
    });

    _player.onPlayerComplete.listen((_) {
      _updateState(isPlaying: false, position: Duration.zero);
    });
  }


  void _updateState({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? currentTitle,
    String? currentImageUrl,
    String? currentUrl,
  }) {
    _currentState = AudioState(
      isPlaying: isPlaying ?? _currentState.isPlaying,
      position: position ?? _currentState.position,
      duration: duration ?? _currentState.duration,
      currentTitle: currentTitle ?? _currentState.currentTitle,
      currentImageUrl: currentImageUrl ?? _currentState.currentImageUrl,
      currentUrl: currentUrl ?? _currentState.currentUrl,
    );
    _stateController.add(_currentState);
  }

// logique de lecture : soit on reprend, soit on charge un nouveau mp3
  Future<void> playEpisode(String url, String title, String? imageUrl) async {
    if (_currentState.currentUrl == url) {
      // Même épisode → toggle play/pause
      _currentState.isPlaying ? await _player.pause() : await _player.resume();
    } else {
      // Nouvel épisode → stop et play
      await _player.stop();
      _updateState(
        currentUrl: url,
        currentTitle: title,
        currentImageUrl: imageUrl,
        position: Duration.zero,
        duration: Duration.zero,
      );
      await _player.play(UrlSource(url));
    }
  }


  Future<void> pauseResume() async {
    if (_currentState.currentUrl == null) return;

    if (_currentState.isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }


  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }


  Future<void> skipBackward([Duration amount = const Duration(seconds: 10)]) async {
    final newPosition = _currentState.position - amount;
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }


  Future<void> skipForward([Duration amount = const Duration(seconds: 30)]) async {
    final newPosition = _currentState.position + amount;
    final maxDuration = _currentState.duration;

    if (maxDuration.inSeconds > 0 && newPosition > maxDuration) {
      await seek(maxDuration);
    } else {
      await seek(newPosition);
    }
  }


  Future<void> dispose() async {
    await _player.dispose();
    await _stateController.close();
  }
}
