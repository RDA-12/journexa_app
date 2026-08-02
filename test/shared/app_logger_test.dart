import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journexa_app/shared/app_logger.dart';
import 'package:logging/logging.dart';
import 'package:mocktail/mocktail.dart';

class MockLogger extends Mock implements Logger {}

void main() {
  late MockLogger mockLogger;
  late AppLogger appLogger;
  const traceId = 'trace-123';
  final fixedClock = Clock.fixed(DateTime(2026, 1, 1, 12));

  setUp(() {
    mockLogger = MockLogger();
    appLogger = AppLogger('TestLogger', logger: mockLogger);
    when(() => mockLogger.name).thenReturn('TestLogger');
  });

  group('constructor', () {
    test(
      'creates AppLogger with default Logger when logger is not provided',
      () {
        final logger = AppLogger('CustomLogger');
        expect(logger, isNotNull);
      },
    );

    test('uses provided Logger instance when passed', () {
      withClock(fixedClock, () {
        final customMock = MockLogger();
        when(() => customMock.name).thenReturn('CustomLogger');
        AppLogger('CustomLogger', logger: customMock).debug(
          'test',
          traceId: traceId,
        );
        verify(() => customMock.fine(any())).called(1);
      });
    });
  });

  group('initialize', () {
    test('sets root logger level to Level.INFO when debugMode is false', () {
      AppLogger.initialize();
      expect(Logger.root.level, Level.INFO);
    });

    test('sets root logger level to Level.ALL when debugMode is true', () {
      AppLogger.initialize(debugMode: true);
      expect(Logger.root.level, Level.ALL);
    });

    test('listens to root logger records and formats output with traceId', () {
      final printedLogs = <String>[];
      withClock(fixedClock, () {
        Zone.current
            .fork(
              specification: ZoneSpecification(
                print: (self, parent, zone, line) {
                  printedLogs.add(line);
                },
              ),
            )
            .run(() {
              AppLogger.initialize(debugMode: true);
              final logMessage = LogMessage(
                name: 'TestApp',
                level: Level.INFO,
                message: 'Hello World',
                traceId: traceId,
                extras: const {'user_id': 123},
              );
              Logger.root.info(logMessage);
            });
      });

      expect(printedLogs, contains(contains('[$traceId]')));
      expect(printedLogs, contains(contains('Hello World')));
      expect(printedLogs, contains('[$traceId]--- EXTRAS ---'));
      expect(printedLogs, contains('[$traceId][user_id]: 123'));
      expect(printedLogs, contains('[$traceId]--- END EXTRAS ---'));
    });
  });

  group('debug', () {
    test('calls logger.fine with correct LogMessage without extras', () {
      withClock(fixedClock, () {
        const message = 'Debug message';
        appLogger.debug(message, traceId: traceId);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.FINE,
          message: message,
          traceId: traceId,
        );

        verify(() => mockLogger.fine(expected)).called(1);
      });
    });

    test('calls logger.fine with correct LogMessage with extras', () {
      withClock(fixedClock, () {
        const message = 'Debug message with extras';
        final extras = {'key': 'value'};
        appLogger.debug(message, traceId: traceId, extras: extras);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.FINE,
          message: message,
          traceId: traceId,
          extras: extras,
        );

        verify(() => mockLogger.fine(expected)).called(1);
      });
    });
  });

  group('info', () {
    test('calls logger.info with correct LogMessage without extras', () {
      withClock(fixedClock, () {
        const message = 'Info message';
        appLogger.info(message, traceId: traceId);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.INFO,
          message: message,
          traceId: traceId,
        );

        verify(() => mockLogger.info(expected)).called(1);
      });
    });

    test('calls logger.info with correct LogMessage with extras', () {
      withClock(fixedClock, () {
        const message = 'Info message with extras';
        final extras = {'user': 'john'};
        appLogger.info(message, traceId: traceId, extras: extras);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.INFO,
          message: message,
          traceId: traceId,
          extras: extras,
        );

        verify(() => mockLogger.info(expected)).called(1);
      });
    });
  });

  group('warning', () {
    test('calls logger.warning with correct LogMessage without extras', () {
      withClock(fixedClock, () {
        const message = 'Warning message';
        appLogger.warning(message, traceId: traceId);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.WARNING,
          message: message,
          traceId: traceId,
        );

        verify(() => mockLogger.warning(expected)).called(1);
      });
    });

    test('calls logger.warning with correct LogMessage with extras', () {
      withClock(fixedClock, () {
        const message = 'Warning message with extras';
        final extras = {'code': 404};
        appLogger.warning(message, traceId: traceId, extras: extras);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.WARNING,
          message: message,
          traceId: traceId,
          extras: extras,
        );

        verify(() => mockLogger.warning(expected)).called(1);
      });
    });
  });

  group('error', () {
    test('calls logger.severe with correct LogMessage without extras', () {
      withClock(fixedClock, () {
        const message = 'Error message';
        appLogger.error(message, traceId: traceId);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.SEVERE,
          message: message,
          traceId: traceId,
        );

        verify(() => mockLogger.severe(expected)).called(1);
      });
    });

    test('calls logger.severe with correct LogMessage with extras', () {
      withClock(fixedClock, () {
        const message = 'Error message with extras';
        final extras = {'error_code': '500'};
        appLogger.error(message, traceId: traceId, extras: extras);

        final expected = LogMessage(
          name: 'TestLogger',
          level: Level.SEVERE,
          message: message,
          traceId: traceId,
          extras: extras,
        );

        verify(() => mockLogger.severe(expected)).called(1);
      });
    });
  });
}
