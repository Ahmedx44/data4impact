import 'package:logger/logger.dart';

class AppLogger {
  static Logger? _logger;

  static void initialize() {
    _logger ??= Logger(
      printer: PrettyPrinter(
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
    );
  }

  static void logInfo(String message) {
    assert(_logger != null, 'Logger not initialized. Call AppLogger.initialize() first.');
    _logger!.i(message);
  }

  static void logWarning(String message) {
    assert(_logger != null, 'Logger not initialized. Call AppLogger.initialize() first.');
    _logger!.w(message);
  }

  static void logError(String message, [Object? error, StackTrace? stackTrace]) {
    assert(_logger != null, 'Logger not initialized. Call AppLogger.initialize() first.');
    if (error != null && stackTrace != null) {
      _logger!.e(message, error: error, stackTrace: stackTrace);
    } else if (error != null) {
      _logger!.e(message, error: error);
    } else {
      _logger!.e(message);
    }
  }

  static void logDebug(String message) {
    assert(_logger != null, 'Logger not initialized. Call AppLogger.initialize() first.');
    _logger!.d(message);
  }
}