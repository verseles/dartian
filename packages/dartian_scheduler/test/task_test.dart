import 'package:dartian_scheduler/src/task.dart';
import 'package:test/test.dart';

void main() {
  group('TaskStatus', () {
    test('should have all expected values', () {
      expect(
        TaskStatus.values,
        containsAll([
          TaskStatus.scheduled,
          TaskStatus.running,
          TaskStatus.completed,
          TaskStatus.failed,
          TaskStatus.cancelled,
        ]),
      );
    });
  });

  group('ScheduledTask', () {
    late ScheduledTask task;

    setUp(() {
      task = ScheduledTask(
        id: 'test-id',
        name: 'test-task',
        cronExpression: '* * * * *',
        callback: () {},
        createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      );
    });

    test('should create task with required fields', () {
      expect(task.id, equals('test-id'));
      expect(task.name, equals('test-task'));
      expect(task.cronExpression, equals('* * * * *'));
      expect(task.callback, isNotNull);
      expect(task.createdAt, equals(DateTime(2024, 1, 1, 12, 0, 0)));
    });

    test('should initialize with scheduled status', () {
      expect(task.status, equals(TaskStatus.scheduled));
    });

    test('should initialize optional fields as null', () {
      expect(task.lastRun, isNull);
      expect(task.nextRun, isNull);
      expect(task.error, isNull);
    });

    test('should allow status modification', () {
      task.status = TaskStatus.running;
      expect(task.status, equals(TaskStatus.running));

      task.status = TaskStatus.completed;
      expect(task.status, equals(TaskStatus.completed));
    });

    test('should allow setting lastRun', () {
      final lastRun = DateTime(2024, 1, 1, 12, 30, 0);
      task.lastRun = lastRun;
      expect(task.lastRun, equals(lastRun));
    });

    test('should allow setting nextRun', () {
      final nextRun = DateTime(2024, 1, 1, 13, 0, 0);
      task.nextRun = nextRun;
      expect(task.nextRun, equals(nextRun));
    });

    test('should allow setting error', () {
      task.error = 'Test error';
      expect(task.error, equals('Test error'));
    });

    group('toJson', () {
      test('should serialize minimal task', () {
        final json = task.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['name'], equals('test-task'));
        expect(json['cronExpression'], equals('* * * * *'));
        expect(json['status'], equals('scheduled'));
        expect(json['createdAt'], equals('2024-01-01T12:00:00.000'));
        expect(json['lastRun'], isNull);
        expect(json['nextRun'], isNull);
        expect(json['error'], isNull);
      });

      test('should serialize task with all fields', () {
        task.status = TaskStatus.failed;
        task.lastRun = DateTime(2024, 1, 1, 12, 30, 0);
        task.nextRun = DateTime(2024, 1, 1, 13, 0, 0);
        task.error = 'Test error message';

        final json = task.toJson();

        expect(json['id'], equals('test-id'));
        expect(json['name'], equals('test-task'));
        expect(json['cronExpression'], equals('* * * * *'));
        expect(json['status'], equals('failed'));
        expect(json['createdAt'], equals('2024-01-01T12:00:00.000'));
        expect(json['lastRun'], equals('2024-01-01T12:30:00.000'));
        expect(json['nextRun'], equals('2024-01-01T13:00:00.000'));
        expect(json['error'], equals('Test error message'));
      });

      test('should serialize all status values correctly', () {
        for (final status in TaskStatus.values) {
          task.status = status;
          final json = task.toJson();
          expect(json['status'], equals(status.name));
        }
      });
    });

    group('fromJson', () {
      test('should deserialize minimal task', () {
        final json = {
          'id': 'deserialized-id',
          'name': 'deserialized-task',
          'cronExpression': '0 * * * *',
          'createdAt': '2024-06-15T14:30:00.000',
          'status': 'scheduled',
        };

        final deserializedTask = ScheduledTask.fromJson(json);

        expect(deserializedTask.id, equals('deserialized-id'));
        expect(deserializedTask.name, equals('deserialized-task'));
        expect(deserializedTask.cronExpression, equals('0 * * * *'));
        expect(
          deserializedTask.createdAt,
          equals(DateTime(2024, 6, 15, 14, 30, 0)),
        );
        expect(deserializedTask.status, equals(TaskStatus.scheduled));
        expect(deserializedTask.lastRun, isNull);
        expect(deserializedTask.nextRun, isNull);
        expect(deserializedTask.error, isNull);
      });

      test('should deserialize task with all fields', () {
        final json = {
          'id': 'full-task-id',
          'name': 'full-task',
          'cronExpression': '*/5 * * * *',
          'createdAt': '2024-06-15T14:30:00.000',
          'status': 'completed',
          'lastRun': '2024-06-15T15:00:00.000',
          'nextRun': '2024-06-15T15:05:00.000',
          'error': 'Previous error',
        };

        final deserializedTask = ScheduledTask.fromJson(json);

        expect(deserializedTask.id, equals('full-task-id'));
        expect(deserializedTask.name, equals('full-task'));
        expect(deserializedTask.cronExpression, equals('*/5 * * * *'));
        expect(
          deserializedTask.createdAt,
          equals(DateTime(2024, 6, 15, 14, 30, 0)),
        );
        expect(deserializedTask.status, equals(TaskStatus.completed));
        expect(
          deserializedTask.lastRun,
          equals(DateTime(2024, 6, 15, 15, 0, 0)),
        );
        expect(
          deserializedTask.nextRun,
          equals(DateTime(2024, 6, 15, 15, 5, 0)),
        );
        expect(deserializedTask.error, equals('Previous error'));
      });

      test('should deserialize all status values correctly', () {
        for (final status in TaskStatus.values) {
          final json = {
            'id': 'test-id',
            'name': 'test-task',
            'cronExpression': '* * * * *',
            'createdAt': '2024-01-01T12:00:00.000',
            'status': status.name,
          };

          final deserializedTask = ScheduledTask.fromJson(json);
          expect(deserializedTask.status, equals(status));
        }
      });

      test('should handle null optional fields in JSON', () {
        final json = {
          'id': 'null-fields-id',
          'name': 'null-fields-task',
          'cronExpression': '* * * * *',
          'createdAt': '2024-01-01T12:00:00.000',
          'status': 'scheduled',
          'lastRun': null,
          'nextRun': null,
          'error': null,
        };

        final deserializedTask = ScheduledTask.fromJson(json);

        expect(deserializedTask.lastRun, isNull);
        expect(deserializedTask.nextRun, isNull);
        expect(deserializedTask.error, isNull);
      });
    });

    group('roundtrip serialization', () {
      test('should preserve data through serialize-deserialize cycle', () {
        task.status = TaskStatus.running;
        task.lastRun = DateTime(2024, 1, 1, 12, 30, 0);
        task.nextRun = DateTime(2024, 1, 1, 13, 0, 0);
        task.error = 'Test error';

        final json = task.toJson();
        final deserializedTask = ScheduledTask.fromJson(json);

        expect(deserializedTask.id, equals(task.id));
        expect(deserializedTask.name, equals(task.name));
        expect(deserializedTask.cronExpression, equals(task.cronExpression));
        expect(deserializedTask.createdAt, equals(task.createdAt));
        expect(deserializedTask.status, equals(task.status));
        expect(deserializedTask.lastRun, equals(task.lastRun));
        expect(deserializedTask.nextRun, equals(task.nextRun));
        expect(deserializedTask.error, equals(task.error));
      });
    });
  });
}
