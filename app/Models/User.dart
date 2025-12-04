class User {
  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({this.id, this.createdAt, this.updatedAt});

  /// The table associated with the model
  static String get tableName => 'users';

  /// Convert model to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Create model instance from database map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Save the model to the database
  Future<User> save() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Delete the model from the database
  Future<bool> delete() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Find a model by ID
  static Future<User?> find(int id) async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }

  /// Get all models
  static Future<List<User>> all() async {
    // Implementation will use ORM
    throw UnimplementedError('Implement with dartian_orm');
  }
}
