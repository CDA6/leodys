import 'package:logger/logger.dart';

class AppLogger {
  static final AppLogger _instance = AppLogger._internal();

  AppLogger._internal();

  final Logger logger = Logger(
      filter: null,
      printer: PrettyPrinter(),
      output: null
  );

  factory AppLogger() => _instance;

  void trace(String message) => logger.t(message);

  void debug(String message) => logger.d(message);

  void info(String message) => logger.i(message);

  void warning(String message) => logger.w(message);

  void error(
      String message, {
        dynamic error,
        StackTrace? stackTrace,
      }) {
    logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  void fatal(String message, [dynamic error]) => logger.f(message, error: error);
}