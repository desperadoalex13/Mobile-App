import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/logging/app_log_service.dart';

void main() {
  late Directory tempDir;
  late File logFile;
  late AppLogService service;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('log_test_');
    logFile = File('${tempDir.path}/test.log');
    service = AppLogService.forTest(logFile);
  });

  tearDown(() async {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('AppLogService', () {
    test('info() writes INFO entry to file', () {
      service.info('App started');

      final content = logFile.readAsStringSync();
      expect(content, contains('[INFO]'));
      expect(content, contains('App started'));
    });

    test('error() writes ERROR entry to file', () {
      service.error('Something failed');

      final content = logFile.readAsStringSync();
      expect(content, contains('[ERROR]'));
      expect(content, contains('Something failed'));
    });

    test('warning() writes WARN entry to file', () {
      service.warning('Low memory');

      final content = logFile.readAsStringSync();
      expect(content, contains('[WARN]'));
      expect(content, contains('Low memory'));
    });

    test('error() includes error detail', () {
      service.error('DB failed', error: Exception('connection refused'));

      final content = logFile.readAsStringSync();
      expect(content, contains('connection refused'));
    });

    test('uses anonymous uid when no user set', () {
      service.info('No user yet');

      final content = logFile.readAsStringSync();
      expect(content, contains('[uid:anonymous]'));
    });

    test('setUserId makes uid appear in subsequent entries', () {
      service.setUserId('user-abc-123');
      service.info('Profile loaded');

      final content = logFile.readAsStringSync();
      expect(content, contains('[uid:user-abc-123]'));
    });

    test('setUserId(null) reverts to anonymous', () {
      service.setUserId('user-abc');
      service.setUserId(null);
      service.info('After logout');

      final content = logFile.readAsStringSync();
      expect(content, contains('[uid:anonymous]'));
    });

    test('timestamp is in ISO-like format', () {
      service.info('Check timestamp');

      final content = logFile.readAsStringSync();
      // Matches e.g. [2026-03-06T12:34:56.789]
      expect(
        content,
        matches(RegExp(r'\[\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}')),
      );
    });

    test('multiple entries are appended to the same file', () {
      service.info('First');
      service.info('Second');
      service.info('Third');

      final lines = logFile.readAsLinesSync().where((l) => l.isNotEmpty);
      expect(lines.length, greaterThanOrEqualTo(3));
    });
  });
}
