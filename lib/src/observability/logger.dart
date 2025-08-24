enum LogLevel { debug, info, warn, error }

class SmartAuthLogger {
  LogLevel level;
  void Function(String message, {LogLevel level})? sink;

  SmartAuthLogger({this.level = LogLevel.info, this.sink});

  void _emit(String message, LogLevel level) {
    if (level.index >= this.level.index) {
      if (sink != null) {
        sink!(message, level: level);
      } else {
        // Fallback to print
        // ignore: avoid_print
        print('[smart_auth_unified][${level.name}] $message');
      }
    }
  }

  void debug(String message) => _emit(message, LogLevel.debug);
  void info(String message) => _emit(message, LogLevel.info);
  void warn(String message) => _emit(message, LogLevel.warn);
  void error(String message) => _emit(message, LogLevel.error);
}
