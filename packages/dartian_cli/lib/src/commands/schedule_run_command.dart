import 'dart:async';
import 'dart:io';

class ScheduleRunCommand {
  final List<Timer> _timers = [];
  bool _shouldStop = false;

  Future<void> run(List<String> arguments) async {
    print('🕐 Task Scheduler Starting');
    print('━' * 50);
    print('📅 Checking for scheduled tasks...');
    print('━' * 50);
    print('');

    // Load scheduled tasks
    final tasks = _loadScheduledTasks();

    if (tasks.isEmpty) {
      print('⚠️  No scheduled tasks found');
      print('💡 Define tasks in app/Console/Kernel.dart');
      print('');
      return;
    }

    print('✅ Loaded ${tasks.length} scheduled task(s):');
    for (final task in tasks) {
      print('  • ${task['name']} - ${task['schedule']}');
    }
    print('');
    print('💪 Scheduler started successfully');
    print('⏰ Running every minute...');
    print('');

    // Handle Ctrl+C gracefully
    ProcessSignal.sigint.watch().listen((_) {
      print('\n\n🛑 Stopping scheduler...');
      _shouldStop = true;
      _cleanup();
    });

    // Run scheduler loop
    await _runScheduler(tasks);
  }

  List<Map<String, dynamic>> _loadScheduledTasks() {
    // In a real implementation, this would load from app/Console/Kernel.dart
    // For now, return example tasks
    return [
      {
        'name': 'cleanup:temp',
        'command': 'Clean temporary files',
        'schedule': 'daily at 00:00',
        'cron': '0 0 * * *',
      },
      {
        'name': 'reports:generate',
        'command': 'Generate daily reports',
        'schedule': 'daily at 08:00',
        'cron': '0 8 * * *',
      },
      {
        'name': 'cache:clear',
        'command': 'Clear expired cache',
        'schedule': 'every hour',
        'cron': '0 * * * *',
      },
    ];
  }

  Future<void> _runScheduler(List<Map<String, dynamic>> tasks) async {
    // Check for due tasks every minute
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_shouldStop) {
        timer.cancel();
        return;
      }

      _checkAndRunTasks(tasks);
    });

    // Also check immediately on start
    _checkAndRunTasks(tasks);

    // Keep the process running
    while (!_shouldStop) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  void _checkAndRunTasks(List<Map<String, dynamic>> tasks) {
    final now = DateTime.now();
    final timestamp = now.toIso8601String().substring(0, 19);

    print('[$timestamp] Checking for due tasks...');

    int ranTasks = 0;

    for (final task in tasks) {
      if (_isTaskDue(task, now)) {
        _runTask(task);
        ranTasks++;
      }
    }

    if (ranTasks == 0) {
      print('[$timestamp] No tasks due');
    }

    print('');
  }

  bool _isTaskDue(Map<String, dynamic> task, DateTime now) {
    final cron = task['cron'] as String;

    // Simple cron parsing for demonstration
    // In real implementation, use a proper cron parser
    final parts = cron.split(' ');
    if (parts.length != 5) return false;

    final minute = parts[0];
    final hour = parts[1];

    // Check if current time matches
    if (minute != '*' && minute != now.minute.toString()) {
      return false;
    }

    if (hour != '*' && hour != now.hour.toString()) {
      return false;
    }

    // For simplicity, only checking minute and hour
    // Real implementation would check day, month, day of week
    return true;
  }

  void _runTask(Map<String, dynamic> task) {
    final timestamp = DateTime.now().toIso8601String().substring(0, 19);
    final name = task['name'] as String;
    final command = task['command'] as String;

    print('[$timestamp] ⏰ Running: $name');
    print('[$timestamp]    Command: $command');

    // Simulate task execution
    Timer(const Duration(seconds: 2), () {
      print('[$timestamp] ✅ Completed: $name');
    });
  }

  void _cleanup() {
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    print('✅ Cleanup completed');
    print('👋 Scheduler stopped');
  }
}
