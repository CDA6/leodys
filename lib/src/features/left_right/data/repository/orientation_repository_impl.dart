import 'dart:typed_data';
import '../../domain/entity/body_part_entity.dart';
import '../../domain/repository/i_orientation_repository.dart';
import '../datasource/yolo_local_datasource.dart';
import '../model/body_part_model.dart';

class OrientationRepositoryImpl implements IOrientationRepository {
  final IYoloLocalDataSource dataSource;

  OrientationRepositoryImpl(this.dataSource);

  @override
  // On passe maintenant les bytes et la résolution de la frame
  Future<BodyPart> analyzeFrame(Uint8List bytes, int height, int width) async {

    // 1. La Data Source analyse maintenant les bytes en direct
    final rawData = await dataSource.predictFrame(bytes, height, width);

    if (rawData.isEmpty) {
      return BodyPart(
        label: "Rien détecté",
        x: 0,
        side: Side.unknown,
        confidence: 0,
      );
    }

    // 2. On transforme le résultat technique en Model
    final model = BodyPartModel.fromYolo(rawData.first);

    // 3. On renvoie l'objet (le Side sera calculé dans le UseCase juste après)
    return model;
  }
}