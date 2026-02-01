import 'package:leodys/features/audio_reader/presentation/controllers/document_controller.dart';
import 'package:leodys/features/audio_reader/presentation/controllers/reader_controller.dart';
import 'data/repositories/ocr_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';
import 'data/repositories/tts_repository_impl.dart';
import 'data/services/ocr_service.dart';
import 'data/services/tts_service.dart';
import 'domain/usecases/document_usecase.dart';
import 'domain/usecases/read_text_usecase.dart';
import 'domain/usecases/scan_document_usecase.dart';

/// Injection de dépendence faite manuellement

ReaderController createReaderController() {
  final ocrService = OcrService();
  final ttsService = TtsService();

  final ocrRepository = OcrRepositoryImpl(ocrService);
  final ttsRepository = TtsRepositoryImpl(ttsService);
  final documentRepository = DocumentRepositoryImpl();

  final scanDocumentUsecase = ScanDocumentUsecase(ocrRepository);
  final readTextUsecase = ReadTextUseCase(ttsRepository);
  final documentUsecase = DocumentUsecase(documentRepository);

  return ReaderController(
    readTextUseCase: readTextUsecase,
    scanDocumentUsecase: scanDocumentUsecase,
    documentUsecase: documentUsecase,
  );
}

DocumentController createDocumentController() {
  final repository = DocumentRepositoryImpl();
  final documentUsecase = DocumentUsecase(repository);
  return DocumentController(documentUsecase: documentUsecase);
}
