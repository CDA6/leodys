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

  void debug(String message) => logger.d(message);

  void info(String message) => logger.i(message);

  void error(String message, [dynamic error]) => logger.e(message, error: error);
}