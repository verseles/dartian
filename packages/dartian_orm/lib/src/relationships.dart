import 'package:drift/drift.dart';

/// Represents a one-to-many relationship
///
/// Example:
/// ```dart
/// class User {
///   HasMany<Post> get posts => HasMany<Post>(
///     database: database,
///     foreignKey: 'user_id',
///     localKey: id,
///   );
/// }
/// ```
abstract class HasMany<TModel> {
  final DatabaseConnectionUser database;
  final TableInfo table;
  final String foreignKey;
  final dynamic localKey;

  HasMany({
    required this.database,
    required this.table,
    required this.foreignKey,
    required this.localKey,
  });

  /// Get all related models
  Future<List<TModel>> get() async {
    final query = database.select(table)
      ..where((tbl) => buildForeignKeyCondition(tbl));
    return (await query.get()).cast<TModel>();
  }

  /// Build the foreign key condition
  Expression<bool> buildForeignKeyCondition(dynamic tbl);
}

/// Represents a many-to-one relationship
///
/// Example:
/// ```dart
/// class Post {
///   BelongsTo<User> get user => BelongsTo<User>(
///     database: database,
///     foreignKey: userId,
///   );
/// }
/// ```
abstract class BelongsTo<TModel> {
  final DatabaseConnectionUser database;
  final TableInfo table;
  final dynamic foreignKey;

  BelongsTo({
    required this.database,
    required this.table,
    required this.foreignKey,
  });

  /// Get the related model
  Future<TModel?> get() async {
    if (foreignKey == null) return null;

    final query = database.select(table)
      ..where((tbl) => buildPrimaryKeyCondition(tbl))
      ..limit(1);
    final results = await query.get();
    return results.isEmpty ? null : results.first as TModel;
  }

  /// Build the primary key condition
  Expression<bool> buildPrimaryKeyCondition(dynamic tbl);
}

/// Represents a one-to-one relationship
///
/// Example:
/// ```dart
/// class User {
///   HasOne<Profile> get profile => HasOne<Profile>(
///     database: database,
///     foreignKey: 'user_id',
///     localKey: id,
///   );
/// }
/// ```
abstract class HasOne<TModel> {
  final DatabaseConnectionUser database;
  final TableInfo table;
  final String foreignKey;
  final dynamic localKey;

  HasOne({
    required this.database,
    required this.table,
    required this.foreignKey,
    required this.localKey,
  });

  /// Get the related model
  Future<TModel?> get() async {
    final query = database.select(table)
      ..where((tbl) => buildForeignKeyCondition(tbl))
      ..limit(1);
    final results = await query.get();
    return results.isEmpty ? null : results.first as TModel;
  }

  /// Build the foreign key condition
  Expression<bool> buildForeignKeyCondition(dynamic tbl);
}

/// Represents a many-to-many relationship
///
/// Example:
/// ```dart
/// class User {
///   BelongsToMany<Role> get roles => BelongsToMany<Role>(
///     database: database,
///     pivotTable: 'user_roles',
///     foreignPivotKey: 'user_id',
///     relatedPivotKey: 'role_id',
///     localKey: id,
///   );
/// }
/// ```
abstract class BelongsToMany<TModel> {
  final DatabaseConnectionUser database;
  final TableInfo relatedTable;
  final TableInfo pivotTable;
  final String foreignPivotKey;
  final String relatedPivotKey;
  final dynamic localKey;

  BelongsToMany({
    required this.database,
    required this.relatedTable,
    required this.pivotTable,
    required this.foreignPivotKey,
    required this.relatedPivotKey,
    required this.localKey,
  });

  /// Get all related models
  Future<List<TModel>> get() async {
    // This requires a JOIN query which is more complex in Drift
    // For now, we'll fetch pivot records and then fetch related records
    final pivotQuery = database.select(pivotTable)
      ..where((tbl) => buildPivotCondition(tbl));
    final pivotResults = await pivotQuery.get();

    if (pivotResults.isEmpty) return [];

    final relatedIds =
        pivotResults.map((r) => extractRelatedId(r)).toList();
    final relatedQuery = database.select(relatedTable)
      ..where((tbl) => buildRelatedIdsCondition(tbl, relatedIds));

    return (await relatedQuery.get()).cast<TModel>();
  }

  /// Attach a related model (create pivot record)
  Future<void> attach(dynamic relatedId) async {
    final companion = buildPivotCompanion(localKey, relatedId);
    await database.into(pivotTable).insert(companion);
  }

  /// Detach a related model (delete pivot record)
  Future<void> detach(dynamic relatedId) async {
    await (database.delete(pivotTable)
          ..where((tbl) =>
              buildPivotDeleteCondition(tbl, localKey, relatedId)))
        .go();
  }

  /// Sync related models (replace all pivot records)
  Future<void> sync(List<dynamic> relatedIds) async {
    // Delete all existing pivot records
    await (database.delete(pivotTable)
          ..where((tbl) => buildPivotCondition(tbl)))
        .go();

    // Insert new pivot records
    for (final relatedId in relatedIds) {
      await attach(relatedId);
    }
  }

  /// Build the pivot table condition for local key
  Expression<bool> buildPivotCondition(dynamic tbl);

  /// Build condition for related IDs
  Expression<bool> buildRelatedIdsCondition(
      dynamic tbl, List<dynamic> ids);

  /// Extract related ID from pivot record
  dynamic extractRelatedId(dynamic record);

  /// Build pivot companion for insert
  UpdateCompanion buildPivotCompanion(dynamic localId, dynamic relatedId);

  /// Build pivot delete condition
  Expression<bool> buildPivotDeleteCondition(
      dynamic tbl, dynamic localId, dynamic relatedId);
}
