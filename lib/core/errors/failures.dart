abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class OCRFailure extends Failure {
  const OCRFailure(super.message);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(super.message);
}