import 'package:leodys/features/map/domain/entities/geo_path.dart';
import 'package:leodys/features/map/domain/entities/geo_position.dart';
import 'package:leodys/features/map/domain/repositories/path_repository.dart';

class GetPathUseCase {
  final IPathRepository repository;

  GetPathUseCase(this.repository);

  Future<GeoPath> call(GeoPosition start, GeoPosition end) {
    return repository.getWalkingPath(start, end);
  }
}
