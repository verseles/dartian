/// Cron expression parser and evaluator
/// Supports standard cron format: minute hour day month dayOfWeek
/// Format: * * * * * (minute hour day month dayOfWeek)
///
/// Special characters:
/// * - any value
/// , - value list separator (e.g., 1,3,5)
/// - - range (e.g., 1-5)
/// / - step values (e.g., */5 for every 5 minutes)
class CronExpression {
  final String expression;
  final List<int> minutes;
  final List<int> hours;
  final List<int> daysOfMonth;
  final List<int> months;
  final List<int> daysOfWeek;

  CronExpression._({
    required this.expression,
    required this.minutes,
    required this.hours,
    required this.daysOfMonth,
    required this.months,
    required this.daysOfWeek,
  });

  /// Parse a cron expression
  /// Format: minute hour dayOfMonth month dayOfWeek
  /// Example: "0 9 * * *" = every day at 9:00 AM
  /// Example: "*/5 * * * *" = every 5 minutes
  /// Example: "0 0 1 * *" = first day of every month at midnight
  factory CronExpression.parse(String expression) {
    final parts = expression.trim().split(RegExp(r'\s+'));

    if (parts.length != 5) {
      throw ArgumentError(
        'Invalid cron expression: expected 5 parts (minute hour day month dayOfWeek), got ${parts.length}',
      );
    }

    return CronExpression._(
      expression: expression,
      minutes: _parseField(parts[0], 0, 59, 'minute'),
      hours: _parseField(parts[1], 0, 23, 'hour'),
      daysOfMonth: _parseField(parts[2], 1, 31, 'day of month'),
      months: _parseField(parts[3], 1, 12, 'month'),
      daysOfWeek: _parseField(parts[4], 0, 6, 'day of week'),
    );
  }

  /// Parse a single cron field
  static List<int> _parseField(
    String field,
    int min,
    int max,
    String fieldName,
  ) {
    // Handle wildcard
    if (field == '*') {
      return List.generate(max - min + 1, (i) => min + i);
    }

    // Handle step values (e.g., */5, 0-20/2)
    if (field.contains('/')) {
      final parts = field.split('/');
      final step = int.tryParse(parts[1]);

      if (step == null || step <= 0) {
        throw ArgumentError('Invalid step value in $fieldName: ${parts[1]}');
      }

      final range = parts[0] == '*'
          ? List.generate(max - min + 1, (i) => min + i)
          : _parseRange(parts[0], min, max, fieldName);

      return range.where((value) => (value - min) % step == 0).toList();
    }

    // Handle comma-separated list
    if (field.contains(',')) {
      final values = field.split(',');
      final result = <int>[];

      for (final value in values) {
        if (value.contains('-')) {
          result.addAll(_parseRange(value, min, max, fieldName));
        } else {
          final num = int.tryParse(value);
          if (num == null || num < min || num > max) {
            throw ArgumentError('Invalid value in $fieldName: $value');
          }
          result.add(num);
        }
      }

      return result..sort();
    }

    // Handle range (e.g., 1-5)
    if (field.contains('-')) {
      return _parseRange(field, min, max, fieldName);
    }

    // Handle single value
    final value = int.tryParse(field);
    if (value == null || value < min || value > max) {
      throw ArgumentError(
        'Invalid value in $fieldName: $field (must be between $min and $max)',
      );
    }

    return [value];
  }

  /// Parse a range expression (e.g., "1-5")
  static List<int> _parseRange(
    String range,
    int min,
    int max,
    String fieldName,
  ) {
    final parts = range.split('-');

    if (parts.length != 2) {
      throw ArgumentError('Invalid range in $fieldName: $range');
    }

    final start = int.tryParse(parts[0]);
    final end = int.tryParse(parts[1]);

    if (start == null ||
        end == null ||
        start < min ||
        end > max ||
        start > end) {
      throw ArgumentError('Invalid range in $fieldName: $range');
    }

    return List.generate(end - start + 1, (i) => start + i);
  }

  /// Check if the expression matches a given DateTime
  bool matches(DateTime dateTime) {
    return minutes.contains(dateTime.minute) &&
        hours.contains(dateTime.hour) &&
        daysOfMonth.contains(dateTime.day) &&
        months.contains(dateTime.month) &&
        daysOfWeek.contains(
          dateTime.weekday % 7,
        ); // Convert Monday=1 to Sunday=0
  }

  /// Get the next run time after a given DateTime
  DateTime? getNextRun(DateTime after) {
    // Start from the next minute
    DateTime current = DateTime(
      after.year,
      after.month,
      after.day,
      after.hour,
      after.minute,
    ).add(const Duration(minutes: 1));

    // Search for up to 4 years (to handle monthly/yearly schedules)
    final maxDate = after.add(const Duration(days: 365 * 4));

    while (current.isBefore(maxDate)) {
      if (matches(current)) {
        return current;
      }

      // Increment by 1 minute
      current = current.add(const Duration(minutes: 1));
    }

    return null; // No match found within 4 years
  }

  /// Get a human-readable description of the schedule
  String describe() {
    final parts = <String>[];

    // Describe minute
    if (minutes.length == 60) {
      parts.add('every minute');
    } else if (minutes.length == 1) {
      parts.add('at minute ${minutes[0]}');
    } else {
      parts.add(
        'at minutes ${minutes.take(3).join(", ")}${minutes.length > 3 ? "..." : ""}',
      );
    }

    // Describe hour
    if (hours.length == 24) {
      parts.add('every hour');
    } else if (hours.length == 1) {
      parts.add('at ${hours[0].toString().padLeft(2, "0")}:00');
    } else {
      parts.add(
        'during hours ${hours.take(3).join(", ")}${hours.length > 3 ? "..." : ""}',
      );
    }

    // Describe day
    if (daysOfMonth.length != 31) {
      if (daysOfMonth.length == 1) {
        parts.add('on day ${daysOfMonth[0]}');
      } else {
        parts.add(
          'on days ${daysOfMonth.take(3).join(", ")}${daysOfMonth.length > 3 ? "..." : ""}',
        );
      }
    }

    // Describe month
    if (months.length != 12) {
      if (months.length == 1) {
        parts.add('in ${_monthName(months[0])}');
      } else {
        parts.add(
          'in ${months.map(_monthName).take(2).join(", ")}${months.length > 2 ? "..." : ""}',
        );
      }
    }

    // Describe day of week
    if (daysOfWeek.length != 7) {
      if (daysOfWeek.length == 1) {
        parts.add('on ${_dayName(daysOfWeek[0])}');
      } else {
        parts.add(
          'on ${daysOfWeek.map(_dayName).take(3).join(", ")}${daysOfWeek.length > 3 ? "..." : ""}',
        );
      }
    }

    return parts.join(', ');
  }

  static String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  static String _dayName(int day) {
    const days = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return days[day];
  }

  @override
  String toString() => expression;
}
