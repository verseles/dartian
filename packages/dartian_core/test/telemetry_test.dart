import 'package:test/test.dart';
import 'package:dartian_core/dartian_core.dart';

void main() {
  group('TelemetryHooks', () {
    setUp(() {
      // Clear all hooks before each test
      TelemetryHooks.clear();
    });

    tearDown(() {
      // Clean up after each test
      TelemetryHooks.clear();
    });

    group('Registration', () {
      test('should register onRequest callback', () {
        var called = false;
        TelemetryHooks.onRequest((request) {
          called = true;
        });

        expect(TelemetryHooks.totalCallbacks, equals(1));
        expect(called, isFalse);
      });

      test('should register onResponse callback', () {
        TelemetryHooks.onResponse((response, duration) {});

        expect(TelemetryHooks.totalCallbacks, equals(1));
      });

      test('should register onQueryExecuted callback', () {
        TelemetryHooks.onQueryExecuted((sql, duration) {});

        expect(TelemetryHooks.totalCallbacks, equals(1));
      });

      test('should register onJobQueued callback', () {
        TelemetryHooks.onJobQueued((job) {});

        expect(TelemetryHooks.totalCallbacks, equals(1));
      });

      test('should register onJobProcessed callback', () {
        TelemetryHooks.onJobProcessed((job, duration) {});

        expect(TelemetryHooks.totalCallbacks, equals(1));
      });

      test('should register multiple callbacks for same hook', () {
        TelemetryHooks.onRequest((request) {});
        TelemetryHooks.onRequest((request) {});
        TelemetryHooks.onResponse((response, duration) {});

        expect(TelemetryHooks.totalCallbacks, equals(3));
      });
    });

    group('Triggering', () {
      test('should trigger onRequest callbacks', () {
        var callCount = 0;
        dynamic capturedRequest;

        TelemetryHooks.onRequest((request) {
          callCount++;
          capturedRequest = request;
        });

        TelemetryHooks.triggerRequest('test-request');

        expect(callCount, equals(1));
        expect(capturedRequest, equals('test-request'));
      });

      test('should trigger onResponse callbacks', () {
        var callCount = 0;
        dynamic capturedResponse;
        Duration? capturedDuration;

        TelemetryHooks.onResponse((response, duration) {
          callCount++;
          capturedResponse = response;
          capturedDuration = duration;
        });

        const testDuration = Duration(seconds: 5);
        TelemetryHooks.triggerResponse('test-response', testDuration);

        expect(callCount, equals(1));
        expect(capturedResponse, equals('test-response'));
        expect(capturedDuration, equals(testDuration));
      });

      test('should trigger onQueryExecuted callbacks', () {
        var callCount = 0;
        String? capturedSql;
        Duration? capturedDuration;

        TelemetryHooks.onQueryExecuted((sql, duration) {
          callCount++;
          capturedSql = sql;
          capturedDuration = duration;
        });

        const testDuration = Duration(milliseconds: 100);
        TelemetryHooks.triggerQueryExecuted('SELECT * FROM users', testDuration);

        expect(callCount, equals(1));
        expect(capturedSql, equals('SELECT * FROM users'));
        expect(capturedDuration, equals(testDuration));
      });

      test('should trigger onJobQueued callbacks', () {
        var callCount = 0;
        dynamic capturedJob;

        TelemetryHooks.onJobQueued((job) {
          callCount++;
          capturedJob = job;
        });

        final testJob = {'id': 1, 'type': 'email'};
        TelemetryHooks.triggerJobQueued(testJob);

        expect(callCount, equals(1));
        expect(capturedJob, equals(testJob));
      });

      test('should trigger onJobProcessed callbacks', () {
        var callCount = 0;
        dynamic capturedJob;
        Duration? capturedDuration;

        TelemetryHooks.onJobProcessed((job, duration) {
          callCount++;
          capturedJob = job;
          capturedDuration = duration;
        });

        final testJob = {'id': 1, 'type': 'email'};
        const testDuration = Duration(seconds: 2);
        TelemetryHooks.triggerJobProcessed(testJob, testDuration);

        expect(callCount, equals(1));
        expect(capturedJob, equals(testJob));
        expect(capturedDuration, equals(testDuration));
      });

      test('should trigger all registered callbacks', () {
        var callCount1 = 0;
        var callCount2 = 0;

        TelemetryHooks.onRequest((request) {
          callCount1++;
        });

        TelemetryHooks.onRequest((request) {
          callCount2++;
        });

        TelemetryHooks.triggerRequest('test');

        expect(callCount1, equals(1));
        expect(callCount2, equals(1));
      });

      test('should handle errors in callbacks gracefully', () {
        var callCount = 0;

        TelemetryHooks.onRequest((request) {
          callCount++;
          throw Exception('Test exception');
        });

        TelemetryHooks.onRequest((request) {
          callCount++;
        });

        // Should not throw, just log and continue
        expect(() => TelemetryHooks.triggerRequest('test'), returnsNormally);
        expect(callCount, equals(2));
      });
    });

    group('Clear', () {
      test('should clear all registered callbacks', () {
        TelemetryHooks.onRequest((request) {});
        TelemetryHooks.onResponse((response, duration) {});
        TelemetryHooks.onQueryExecuted((sql, duration) {});
        TelemetryHooks.onJobQueued((job) {});
        TelemetryHooks.onJobProcessed((job, duration) {});

        expect(TelemetryHooks.totalCallbacks, equals(5));

        TelemetryHooks.clear();

        expect(TelemetryHooks.totalCallbacks, equals(0));
      });

      test('should work after clearing', () {
        TelemetryHooks.onRequest((request) {});
        TelemetryHooks.clear();

        var callCount = 0;
        TelemetryHooks.onRequest((request) {
          callCount++;
        });

        TelemetryHooks.triggerRequest('test');

        expect(callCount, equals(1));
      });
    });

    group('Edge cases', () {
      test('should handle null request', () {
        var callCount = 0;
        dynamic capturedRequest;

        TelemetryHooks.onRequest((request) {
          callCount++;
          capturedRequest = request;
        });

        TelemetryHooks.triggerRequest(null);

        expect(callCount, equals(1));
        expect(capturedRequest, isNull);
      });

      test('should handle complex objects as requests', () {
        var callCount = 0;
        dynamic capturedRequest;

        TelemetryHooks.onRequest((request) {
          callCount++;
          capturedRequest = request;
        });

        final complexRequest = {
          'method': 'POST',
          'path': '/api/users',
          'headers': {'Content-Type': 'application/json'},
          'body': {'name': 'John Doe'}
        };

        TelemetryHooks.triggerRequest(complexRequest);

        expect(callCount, equals(1));
        expect(capturedRequest, equals(complexRequest));
      });

      test('should handle zero duration', () {
        var callCount = 0;
        Duration? capturedDuration;

        TelemetryHooks.onResponse((response, duration) {
          callCount++;
          capturedDuration = duration;
        });

        TelemetryHooks.triggerResponse('ok', Duration.zero);

        expect(callCount, equals(1));
        expect(capturedDuration, equals(Duration.zero));
      });

      test('should handle empty SQL query', () {
        var callCount = 0;
        String? capturedSql;

        TelemetryHooks.onQueryExecuted((sql, duration) {
          callCount++;
          capturedSql = sql;
        });

        TelemetryHooks.triggerQueryExecuted('', Duration.zero);

        expect(callCount, equals(1));
        expect(capturedSql, equals(''));
      });
    });
  });

  group('Helpers', () {
    group('generateId', () {
      test('should generate unique IDs', () {
        final id1 = generateId();
        final id2 = generateId();

        expect(id1, isNot(equals(id2)));
        expect(id1.length, greaterThan(8));
        expect(id2.length, greaterThan(8));
      });

      test('should generate IDs with timestamp', () {
        final id = generateId();
        final timestampPart = id.substring(0, 13);

        expect(int.parse(timestampPart), isA<int>());
      });
    });

    group('safeJsonDecode', () {
      test('should decode valid JSON', () {
        final result = safeJsonDecode('{"name": "John"}', (json) => json['name'] as String);
        expect(result, equals('John'));
      });

      test('should return null for null input', () {
        final result = safeJsonDecode(null, (json) => json['name'] as String);
        expect(result, isNull);
      });

      test('should return null for empty string', () {
        final result = safeJsonDecode('', (json) => json['name'] as String);
        expect(result, isNull);
      });

      test('should return null for invalid JSON', () {
        final result = safeJsonDecode('invalid json', (json) => json['name'] as String);
        expect(result, isNull);
      });

      test('should return null for non-map JSON', () {
        final result = safeJsonDecode('"just a string"', (json) => json['name'] as String);
        expect(result, isNull);
      });
    });

    group('TimeUtils', () {
      test('should return current time in milliseconds', () {
        final before = DateTime.now().millisecondsSinceEpoch;
        final result = TimeUtils.nowMillis();
        final after = DateTime.now().millisecondsSinceEpoch;

        expect(result, greaterThanOrEqualTo(before));
        expect(result, lessThanOrEqualTo(after));
      });

      test('should return current time in microseconds', () {
        final before = DateTime.now().microsecondsSinceEpoch;
        final result = TimeUtils.nowMicros();
        final after = DateTime.now().microsecondsSinceEpoch;

        expect(result, greaterThanOrEqualTo(before));
        expect(result, lessThanOrEqualTo(after));
      });

      test('should convert milliseconds to Duration', () {
        final duration = TimeUtils.millis(1500);
        expect(duration, equals(Duration(milliseconds: 1500)));
      });

      test('should convert seconds to Duration', () {
        final duration = TimeUtils.seconds(30);
        expect(duration, equals(Duration(seconds: 30)));
      });

      test('should convert minutes to Duration', () {
        final duration = TimeUtils.minutes(5);
        expect(duration, equals(Duration(minutes: 5)));
      });
    });
  });
}
