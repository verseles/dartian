/// Telemetry event types
enum TelemetryEventType {
  request,
  databaseQuery,
  cacheOperation,
  queueJob,
  error,
  custom,
}

/// Telemetry event
class TelemetryEvent {
  final String name;
  final TelemetryEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> properties;
  final Duration? duration;

  TelemetryEvent({
    required this.name,
    required this.type,
    required this.timestamp,
    this.properties = const {},
    this.duration,
  });
}

/// Telemetry manager
class TelemetryManager {
  static TelemetryManager? _instance;
  static TelemetryManager get instance => _instance ??= TelemetryManager._();

  TelemetryManager._();

  final List<TelemetryEvent> _events = [];

  /// Record an event
  void record(TelemetryEvent event) {
    _events.add(event);
  }

  /// Record a timed event
  void recordTimed(String name, TelemetryEventType type, Duration duration, {Map<String, dynamic> properties = const {}}) {
    _events.add(TelemetryEvent(
      name: name,
      type: type,
      timestamp: DateTime.now(),
      duration: duration,
      properties: properties,
    ));
  }

  /// Get all events
  List<TelemetryEvent> get events => List.unmodifiable(_events);

  /// Clear all events
  void clear() {
    _events.clear();
  }
}
