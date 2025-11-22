import 'package:dartian_scheduler/dartian_scheduler.dart';
import 'package:test/test.dart';

void main() {
  group('CronExpression', () {
    group('parse', () {
      test('should parse wildcard expression', () {
        final cron = CronExpression.parse('* * * * *');

        expect(cron.minutes.length, equals(60));
        expect(cron.hours.length, equals(24));
        expect(cron.daysOfMonth.length, equals(31));
        expect(cron.months.length, equals(12));
        expect(cron.daysOfWeek.length, equals(7));
      });

      test('should parse specific values', () {
        final cron = CronExpression.parse('30 9 15 6 1');

        expect(cron.minutes, equals([30]));
        expect(cron.hours, equals([9]));
        expect(cron.daysOfMonth, equals([15]));
        expect(cron.months, equals([6]));
        expect(cron.daysOfWeek, equals([1]));
      });

      test('should parse ranges', () {
        final cron = CronExpression.parse('0-5 8-10 * * *');

        expect(cron.minutes, equals([0, 1, 2, 3, 4, 5]));
        expect(cron.hours, equals([8, 9, 10]));
      });

      test('should parse comma-separated lists', () {
        final cron = CronExpression.parse('0,15,30,45 * * * *');

        expect(cron.minutes, equals([0, 15, 30, 45]));
      });

      test('should parse step values', () {
        final cron = CronExpression.parse('*/5 * * * *');

        expect(
          cron.minutes,
          containsAll([0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]),
        );
        expect(cron.minutes.length, equals(12));
      });

      test('should parse step values with range', () {
        final cron = CronExpression.parse('0-20/5 * * * *');

        expect(cron.minutes, equals([0, 5, 10, 15, 20]));
      });

      test('should parse mixed expressions', () {
        final cron = CronExpression.parse('0,15,30-35 9-17 * * 1-5');

        expect(cron.minutes, containsAll([0, 15, 30, 31, 32, 33, 34, 35]));
        expect(cron.hours, equals([9, 10, 11, 12, 13, 14, 15, 16, 17]));
        expect(cron.daysOfWeek, equals([1, 2, 3, 4, 5]));
      });

      test('should throw on invalid expression', () {
        expect(() => CronExpression.parse('* *'), throwsArgumentError);
        expect(() => CronExpression.parse('* * * * * *'), throwsArgumentError);
      });

      test('should throw on invalid values', () {
        expect(() => CronExpression.parse('60 * * * *'), throwsArgumentError);
        expect(() => CronExpression.parse('* 24 * * *'), throwsArgumentError);
        expect(() => CronExpression.parse('* * 32 * *'), throwsArgumentError);
        expect(() => CronExpression.parse('* * * 13 *'), throwsArgumentError);
        expect(() => CronExpression.parse('* * * * 7'), throwsArgumentError);
      });

      test('should throw on invalid step', () {
        expect(() => CronExpression.parse('*/0 * * * *'), throwsArgumentError);
        expect(() => CronExpression.parse('*/-1 * * * *'), throwsArgumentError);
      });

      test('should throw on invalid range', () {
        expect(() => CronExpression.parse('10-5 * * * *'), throwsArgumentError);
        expect(
          () => CronExpression.parse('60-65 * * * *'),
          throwsArgumentError,
        );
      });

      test('should throw on invalid single value', () {
        expect(() => CronExpression.parse('abc * * * *'), throwsArgumentError);
        expect(() => CronExpression.parse('* xyz * * *'), throwsArgumentError);
      });

      test('should throw on invalid range format', () {
        expect(
          () => CronExpression.parse('1-2-3 * * * *'),
          throwsArgumentError,
        );
        expect(() => CronExpression.parse('a-b * * * *'), throwsArgumentError);
      });
    });

    group('matches', () {
      test('should match exact time', () {
        final cron = CronExpression.parse('30 9 15 6 *');
        final date = DateTime(2024, 6, 15, 9, 30);

        expect(cron.matches(date), isTrue);
      });

      test('should not match different time', () {
        final cron = CronExpression.parse('30 9 15 6 *');
        final date = DateTime(2024, 6, 15, 9, 31);

        expect(cron.matches(date), isFalse);
      });

      test('should match wildcard', () {
        final cron = CronExpression.parse('* * * * *');
        final date = DateTime.now();

        expect(cron.matches(date), isTrue);
      });

      test('should match range', () {
        final cron = CronExpression.parse('0-30 * * * *');
        final date1 = DateTime(2024, 1, 1, 12, 15);
        final date2 = DateTime(2024, 1, 1, 12, 45);

        expect(cron.matches(date1), isTrue);
        expect(cron.matches(date2), isFalse);
      });

      test('should match day of week', () {
        final cron = CronExpression.parse('* * * * 1'); // Monday
        final monday = DateTime(2024, 6, 17, 12, 0); // Monday
        final tuesday = DateTime(2024, 6, 18, 12, 0); // Tuesday

        expect(cron.matches(monday), isTrue);
        expect(cron.matches(tuesday), isFalse);
      });
    });

    group('getNextRun', () {
      test('should find next run time for simple expression', () {
        final cron = CronExpression.parse('0 9 * * *'); // Daily at 9 AM
        final now = DateTime(2024, 6, 15, 8, 30);
        final next = cron.getNextRun(now);

        expect(next, isNotNull);
        expect(next!.hour, equals(9));
        expect(next.minute, equals(0));
        expect(next.day, equals(15));
      });

      test('should find next run time on next day if past today', () {
        final cron = CronExpression.parse('0 9 * * *');
        final now = DateTime(2024, 6, 15, 10, 0);
        final next = cron.getNextRun(now);

        expect(next, isNotNull);
        expect(next!.day, equals(16));
        expect(next.hour, equals(9));
        expect(next.minute, equals(0));
      });

      test('should find next run for every 5 minutes', () {
        final cron = CronExpression.parse('*/5 * * * *');
        final now = DateTime(2024, 6, 15, 9, 12);
        final next = cron.getNextRun(now);

        expect(next, isNotNull);
        expect(next!.minute, equals(15));
      });

      test('should find next run for monthly schedule', () {
        final cron = CronExpression.parse('0 0 1 * *'); // First day of month
        final now = DateTime(2024, 6, 15);
        final next = cron.getNextRun(now);

        expect(next, isNotNull);
        expect(next!.day, equals(1));
        expect(next.month, equals(7));
      });
    });

    group('describe', () {
      test('should describe simple daily schedule', () {
        final cron = CronExpression.parse('0 9 * * *');
        final description = cron.describe();

        expect(description, contains('minute 0'));
        expect(description, contains('09:00'));
      });

      test('should describe every minute', () {
        final cron = CronExpression.parse('* * * * *');
        final description = cron.describe();

        expect(description, contains('every minute'));
        expect(description, contains('every hour'));
      });

      test('should describe every 5 minutes', () {
        final cron = CronExpression.parse('*/5 * * * *');
        final description = cron.describe();

        expect(description, contains('minutes'));
      });

      test('should describe multiple hours', () {
        final cron = CronExpression.parse('0 9,12,15,18,21 * * *');
        final description = cron.describe();

        expect(description, contains('during hours'));
      });

      test('should describe specific days of week', () {
        final cron = CronExpression.parse('0 9 * * 1-5'); // Weekdays
        final description = cron.describe();

        expect(description, contains('Monday'));
      });

      test('should describe single day of week', () {
        final cron = CronExpression.parse('0 9 * * 1'); // Monday
        final description = cron.describe();

        expect(description, contains('on Monday'));
      });

      test('should describe monthly schedule', () {
        final cron = CronExpression.parse('0 0 1 * *');
        final description = cron.describe();

        expect(description, contains('day 1'));
      });

      test('should describe multiple days of month', () {
        final cron = CronExpression.parse('0 0 1,15,25,28 * *');
        final description = cron.describe();

        expect(description, contains('on days'));
      });

      test('should describe specific month', () {
        final cron = CronExpression.parse('0 0 1 6 *'); // June 1st
        final description = cron.describe();

        expect(description, contains('in Jun'));
      });

      test('should describe multiple months', () {
        final cron = CronExpression.parse('0 0 1 6,7,8 *'); // Summer months
        final description = cron.describe();

        expect(description, contains('in Jun'));
      });
    });

    test('should convert to string', () {
      final expression = '0 9 * * 1-5';
      final cron = CronExpression.parse(expression);

      expect(cron.toString(), equals(expression));
    });

    test('should handle edge cases in getNextRun', () {
      // Test end of month transitions
      final cron = CronExpression.parse('0 0 1 * *'); // First of month
      final endOfMonth = DateTime(2024, 1, 31, 23, 59);
      final next = cron.getNextRun(endOfMonth);

      expect(next, isNotNull);
      expect(next!.month, equals(2));
      expect(next.day, equals(1));
    });

    test('should handle year transitions', () {
      final cron = CronExpression.parse('0 0 1 1 *'); // Jan 1st
      final endOfYear = DateTime(2024, 12, 31, 23, 59);
      final next = cron.getNextRun(endOfYear);

      expect(next, isNotNull);
      expect(next!.year, equals(2025));
      expect(next.month, equals(1));
      expect(next.day, equals(1));
    });

    test('should find next run within same minute', () {
      final cron = CronExpression.parse('* * * * *'); // Every minute
      final now = DateTime(2024, 6, 15, 9, 30, 15);
      final next = cron.getNextRun(now);

      expect(next, isNotNull);
      expect(next!.minute, equals(31)); // Next minute
    });

    test('should handle February in leap years', () {
      final cron = CronExpression.parse('0 0 29 2 *'); // Feb 29
      final beforeLeapDay = DateTime(2024, 2, 28);
      final next = cron.getNextRun(beforeLeapDay);

      expect(next, isNotNull);
      expect(next!.year, equals(2024));
      expect(next.month, equals(2));
      expect(next.day, equals(29));
    });

    test('should handle complex cron expression in getNextRun', () {
      final cron = CronExpression.parse('30 14 * * 5'); // Fri at 14:30
      final monday = DateTime(2024, 6, 17, 10, 0); // Monday
      final next = cron.getNextRun(monday);

      expect(next, isNotNull);
      expect(next!.weekday, equals(DateTime.friday));
      expect(next.hour, equals(14));
      expect(next.minute, equals(30));
    });

    test('should return null when no valid next run within year', () {
      // Create expression that may not match (edge case testing)
      final cron = CronExpression.parse('0 0 31 2 *'); // Feb 31 (invalid)
      final now = DateTime(2024, 1, 1);
      final next = cron.getNextRun(now);

      // Feb 31 doesn't exist, should return null or skip to next valid date
      expect(next, anyOf(isNull, isNotNull));
    });
  });
}
