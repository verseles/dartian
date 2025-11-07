/// User session
class Session {
  final String id;
  final String userId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final Map<String, dynamic> data;

  Session({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.expiresAt,
    this.data = const {},
  });

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get session duration
  Duration get duration => expiresAt.difference(createdAt);

  /// Get remaining time
  Duration get remainingTime => expiresAt.difference(DateTime.now());

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
    'data': data,
  };

  /// Create from JSON
  factory Session.fromJson(Map<String, dynamic> json) => Session(
    id: json['id'] as String,
    userId: json['userId'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    expiresAt: DateTime.parse(json['expiresAt'] as String),
    data: Map<String, dynamic>.from(json['data'] as Map),
  );

  /// Create a new session
  factory Session.create(String userId, Duration duration) {
    final now = DateTime.now();
    return Session(
      id: now.millisecondsSinceEpoch.toString() + '_' + userId,
      userId: userId,
      createdAt: now,
      expiresAt: now.add(duration),
    );
  }
}
