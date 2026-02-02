import 'dart:developer' as developer;

/// Centralized Logger service for the application.
/// Helps in tracking events and errors consistently.
class Logger {
  static void info(String message) {
    developer.log('💡 $message', name: 'INFO');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    developer.log('❌ $message',
        name: 'ERROR', error: error, stackTrace: stackTrace);
  }

  static void warn(String message) {
    developer.log('⚠️ $message', name: 'WARN');
  }

  static void debug(String message) {
    developer.log('🐛 $message', name: 'DEBUG');
  }
}
