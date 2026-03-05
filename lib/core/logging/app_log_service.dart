import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Singleton logger that writes structured entries to a daily log file.
///
/// Log file: `<app-documents>/logs/app_YYYY-MM-DD.log`
/// Entry format: `[2026-03-06T12:34:56.789] [LEVEL] [uid:abc123] message`
class AppLogService {
  AppLogService._();

  static final AppLogService instance = AppLogService._();

  /// Test-only constructor — injects a pre-created [File] so tests can inspect output.
  @visibleForTesting
  AppLogService.forTest(File logFile) : _logFile = logFile;

  File? _logFile;
  String? _userId;

  /// Initialises file logging. Call once from [main] after Firebase init.
  /// No-op on web (dart:io not supported).
  Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${dir.path}/logs');
      if (!logsDir.existsSync()) logsDir.createSync(recursive: true);
      final date = _dateTag(DateTime.now());
      _logFile = File('${logsDir.path}/app_$date.log');
    } catch (_) {
      // If file system is unavailable, continue without file logging.
    }
  }

  /// Updates the user ID that appears on every subsequent log entry.
  /// Pass `null` after sign-out.
  void setUserId(String? uid) => _userId = uid;

  void info(String message) => _write('INFO', message);

  void warning(String message, {Object? error}) =>
      _write('WARN', message, error: error);

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _write('ERROR', message, error: error, stackTrace: stackTrace);

  // ---------------------------------------------------------------------------

  void _write(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final ts = DateTime.now().toIso8601String().substring(0, 23);
    final uid = _userId ?? 'anonymous';
    final buf = StringBuffer('[$ts] [$level] [uid:$uid] $message');
    if (error != null) buf.write('\n  error: $error');
    if (stackTrace != null) {
      final lines = stackTrace.toString().split('\n').take(5);
      buf.write('\n  stacktrace:\n    ${lines.join('\n    ')}');
    }
    buf.write('\n');
    final entry = buf.toString();

    if (kDebugMode) {
      // ignore: avoid_print
      print(entry);
    }

    try {
      _logFile?.writeAsStringSync(entry, mode: FileMode.append, flush: true);
    } catch (_) {
      // Silently ignore write failures — logging must never crash the app.
    }
  }

  static String _dateTag(DateTime dt) =>
      '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)}';

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
