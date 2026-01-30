import 'package:dartz/dartz.dart';
import 'package:leodys/common/errors/failures.dart';
import 'package:leodys/common/mixins/repository_mixin.dart';
import '../../domain/repositories/audio_repository.dart';
import '../services/audio_player_service.dart';
// implémentation qui fait le pont entre les usecases et le son
class AudioRepositoryImpl with RepositoryMixin implements AudioRepository {
  final AudioPlayerService _audioService; // le moteur réel (just_audio/etc)

  AudioRepositoryImpl({required AudioPlayerService service}) : _audioService = service;

  // expose le flux continu du lecteur (temps, etat)
  @override
  Stream<AudioState> get audioStateStream => _audioService.stateStream;

  @override
  AudioState get currentState => _audioService.currentState;

  // lance le son et catch les erreurs
  @override
  Future<Either<Failure, void>> playEpisode({
    required String url,
    required String title,
    String? imageUrl,
  }) {
    return execute('playEpisode', () async {
      try {
        await _audioService.playEpisode(url, title, imageUrl);
        return const Right(null); // succès
      } catch (e) {
        return Left(UnknownFailure('erreur de lecture: $e')); // echec propre
      }
    });
  }

  // pause ou lecture
  @override
  Future<Either<Failure, void>> pauseResume() {
    return execute('pauseResume', () async {
      await _audioService.pauseResume();
      return const Right(null);
    });
  }

  // deplace le curseur
  @override
  Future<Either<Failure, void>> seek(Duration position) {
    return execute('seek', () async {
      await _audioService.seek(position);
      return const Right(null);
    });
  }

  // recule (-10s par defaut) et avance (+30s)
  @override
  Future<Either<Failure, void>> skipBackward([Duration amount = const Duration(seconds: 10)]) {
    return execute('skipBackward', () async {
      await _audioService.skipBackward(amount);
      return const Right(null);
    });
  }

  @override
  Future<Either<Failure, void>> skipForward([Duration amount = const Duration(seconds: 30)]) {
    return execute('skipForward', () async {
      await _audioService.skipForward(amount);
      return const Right(null);
    });
  }
}