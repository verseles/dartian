/// Task status
enum TaskStatus { scheduled, running, completed, failed, cancelled }

/// Scheduled task
class ScheduledTask {
  final String id;
  final String name;
  final String cronExpression;
  final Function() callback;
  final DateTime createdAt;
  TaskStatus status;
  DateTime? lastRun;
  DateTime? nextRun;
  String? error;

  ScheduledTask({
    required this.id,
    required this.name,
    required this.cronExpression,
    required this.callback,
    required this.createdAt,
  }) : status = TaskStatus.scheduled,
       error = null;

  /// Convert task to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cronExpression': cronExpression,
    'createdAt': createdAt.toIso8601String(),
    'status': status.name,
    'lastRun': lastRun?.toIso8601String(),
    'nextRun': nextRun?.toIso8601String(),
    'error': error,
  };

  /// Create task from JSON
  factory ScheduledTask.fromJson(Map<String, dynamic> json) =>
      ScheduledTask(
          id: json['id'] as String,
          name: json['name'] as String,
          cronExpression: json['cronExpression'] as String,
          callback: () {}, // Callback cannot be deserialized
          createdAt: DateTime.parse(json['createdAt'] as String),
        )
        ..status = TaskStatus.values.byName(json['status'] as String)
        ..lastRun = json['lastRun'] == null
            ? null
            : DateTime.parse(json['lastRun'] as String)
        ..nextRun = json['nextRun'] == null
            ? null
            : DateTime.parse(json['nextRun'] as String)
        ..error = json['error'] as String?;
}
