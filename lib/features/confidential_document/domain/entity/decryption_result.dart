import 'package:leodys/features/confidential_document/domain/entity/picture_download.dart';

class DecryptionResult {
  final List<PictureDownload> pictures;
  final int errorCount;

  DecryptionResult(this.pictures, this.errorCount);
  bool get hasErrors => errorCount > 0;
}