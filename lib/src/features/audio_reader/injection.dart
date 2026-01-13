import 'package:leodys/src/features/audio_reader/data/repositories/document_repository_impl.dart';
import 'package:leodys/src/features/audio_reader/data/repositories/ocr_repository_impl.dart';
import 'package:leodys/src/features/audio_reader/data/repositories/reading_progress_repository_impl.dart';
import 'package:leodys/src/features/audio_reader/data/repositories/tts_repository_impl.dart';
import 'package:leodys/src/features/audio_reader/data/services/ocr_service_impl.dart';
import 'package:leodys/src/features/audio_reader/data/services/tts_service_imp.dart';
import 'package:leodys/src/features/audio_reader/domain/repositories/reading_progress_repository.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/document_usecase.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/read_text_usecase.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/reading_progress_usecase.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/scan_and_read_text_usecase.dart';
import 'package:leodys/src/features/audio_reader/domain/usecases/scan_document_usecase.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/document_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reader_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/reading_progess_controller.dart';
import 'package:leodys/src/features/audio_reader/presentation/controllers/scan_and_read_text_controller.dart';

ReaderController createReaderController() {
  final ocrService = OcrServiceImpl();
  final ttsService = TtsServiceImpl();

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

ScanAndReadTextController createScanAndReadController() {
  final ocrService = OcrServiceImpl();
  final ttsService = TtsServiceImpl();

  final ocrRepository = OcrRepositoryImpl(ocrService);
  final ttsRepository = TtsRepositoryImpl(ttsService);

  final scanAndReadUsecase = ScanAndReadTextUsecase(
    ocrRepository,
    ttsRepository,
  );

  return ScanAndReadTextController(scanAndReadTextUsecase: scanAndReadUsecase);
}

ReadingProgressController createReadingProgressController() {
  final repository = ReadingProgressRepositoryImpl();
  final readingProgressUsecase = ReadingProgressUsecase(repository);
  return ReadingProgressController(
    readingProgressUsecase: readingProgressUsecase,
  );
}

DocumentController createDocumentController() {
  final repository = DocumentRepositoryImpl();
  final documentUsecase = DocumentUsecase(repository);
  return DocumentController(documentUsecase: documentUsecase);
}
