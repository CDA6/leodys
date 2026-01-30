import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';

class AudioState {
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final String? currentTitle;
  final String? currentImageUrl;
  final String? currentUrl;

  const AudioState({
    required this.isPlaying,
    required this.position,
    required this.duration,
    this.currentTitle,
    this.currentImageUrl,
    this.currentUrl,
  });

  factory AudioState.initial() => const AudioState(
        isPlaying: false,
        position: Duration.zero,
        duration: Duration.zero,
        currentTitle: null,
        currentImageUrl: null,
        currentUrl: null,
      );


  bool get hasCurrentEpisode => currentUrl != null;


  String get formattedPosition => _formatDuration(position);


  String get formattedDuration => _formatDuration(duration);

  String _formatDuration(Duration d) =>
      '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';


  AudioState copyWith({
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    String? currentTitle,
    String? currentImageUrl,
    String? currentUrl,
  }) {
    return AudioState(
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentTitle: currentTitle ?? this.currentTitle,
      currentImageUrl: currentImageUrl ?? this.currentImageUrl,
      currentUrl: currentUrl ?? this.currentUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioState &&
          runtimeType == other.runtimeType &&
          isPlaying == other.isPlaying &&
          position == other.position &&
          duration == other.duration &&
          currentTitle == other.currentTitle &&
          currentImageUrl == other.currentImageUrl &&
          currentUrl == other.currentUrl;

  @override
  int get hashCode =>
      isPlaying.hashCode ^
      position.hashCode ^
      duration.hashCode ^
      currentTitle.hashCode ^
      currentImageUrl.hashCode ^
      currentUrl.hashCode;
}


abstract class AudioRepository {

  Stream<AudioState> get audioStateStream;


  AudioState get currentState;


  Future<Either<Failure, void>> playEpisode({
    required String url,
    required String title,
    String? imageUrl,
  });


  Future<Either<Failure, void>> pauseResume();


  Future<Either<Failure, void>> seek(Duration position);


  Future<Either<Failure, void>> skipBackward([Duration amount = const Duration(seconds: 10)]);


  Future<Either<Failure, void>> skipForward([Duration amount = const Duration(seconds: 30)]);
}
