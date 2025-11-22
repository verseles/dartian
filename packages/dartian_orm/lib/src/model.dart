import 'package:drift/drift.dart';

/// Base class for ORM models providing Active Record pattern
///
/// This abstract class provides Laravel-like methods for database operations.
/// Subclasses must implement the abstract methods to define their table operations.
///
/// Example:
/// ```dart
/// class User extends Model<UsersTable, User> {
///   final int id;
///   final String name;
///   final String email;
///
///   User({required this.id, required this.name, required this.email});
///
///   @override
///   UsersCompanion toCompanion() {
///     return UsersCompanion(
///       id: Value(id),
///       name: Value(name),
///       email: Value(email),
///     );
///   }
///
///   @override
///   int get primaryKey => id;
/// }
/// ```
abstract class Model<TTable extends Table, TModel> {
  /// Get the database instance
  DatabaseConnectionUser get database;

  /// Get the table for this model
  TableInfo<TTable, dynamic> get table;

  /// Convert model to a Drift companion for inserts/updates
  UpdateCompanion<dynamic> toCompanion();

  /// Get the primary key value
  dynamic get primaryKey;

  /// Save the model (insert if new, update if exists)
  Future<void> save() async {
    final companion = toCompanion();
    if (primaryKey == null || primaryKey == 0) {
      // Insert new record
      await database.into(table).insert(companion);
    } else {
      // Update existing record
      await (database.update(
        table,
      )..where((tbl) => _primaryKeyEquals(tbl, primaryKey))).write(companion);
    }
  }

  /// Delete the model
  Future<void> delete() async {
    if (primaryKey == null) {
      throw StateError('Cannot delete a model without a primary key');
    }
    await (database.delete(
      table,
    )..where((tbl) => _primaryKeyEquals(tbl, primaryKey))).go();
  }

  /// Helper to build primary key condition
  Expression<bool> _primaryKeyEquals(dynamic tbl, dynamic value) {
    // This is a simplified version. In practice, you'd need to know
    // which column is the primary key. Drift doesn't expose this directly,
    // so subclasses should override this if needed.
    throw UnimplementedError(
      'Subclasses must override _primaryKeyEquals or ensure table has standard "id" column',
    );
  }
}

/// Query builder extensions for models
extension ModelQueryExtensions<TTable extends Table, TModel>
    on SimpleSelectStatement<TTable, TModel> {
  /// Add WHERE condition
  SimpleSelectStatement<TTable, TModel> whereCondition(
    Expression<bool> Function(TTable tbl) filter,
  ) {
    return this..where(filter);
  }

  /// Add ORDER BY clause
  SimpleSelectStatement<TTable, TModel> orderByColumn(
    Expression Function(TTable tbl) orderBy, {
    OrderingMode mode = OrderingMode.asc,
  }) {
    return this
      ..orderBy([(tbl) => OrderingTerm(expression: orderBy(tbl), mode: mode)]);
  }

  /// Add LIMIT
  SimpleSelectStatement<TTable, TModel> limitTo(int count) {
    return this..limit(count);
  }

  /// Add OFFSET
  SimpleSelectStatement<TTable, TModel> offsetBy(int count) {
    return this..limit(count, offset: count);
  }
}

/// Repository pattern for model operations
///
/// Provides static-like methods for querying models.
/// This is a helper class that works with Drift's generated code.
class ModelRepository<TTable extends Table, TModel> {
  final DatabaseConnectionUser database;
  final TableInfo<TTable, TModel> table;

  ModelRepository(this.database, this.table);

  /// Find all records
  Future<List<TModel>> all() {
    return (database.select(table)).get();
  }

  /// Find a record by ID
  Future<TModel?> find(dynamic id) async {
    final query = database.select(table)
      ..where((tbl) => _buildIdCondition(tbl, id))
      ..limit(1);
    final results = await query.get();
    return results.isEmpty ? null : results.first;
  }

  /// Find records matching conditions
  Future<List<TModel>> where(Expression<bool> Function(TTable tbl) filter) {
    return (database.select(table)..where(filter)).get();
  }

  /// Count all records
  Future<int> count() async {
    final countExp = table.$columns.first.count();
    final query = database.selectOnly(table)..addColumns([countExp]);
    final result = await query.getSingle();
    return result.read(countExp) ?? 0;
  }

  /// Helper to build ID condition
  Expression<bool> _buildIdCondition(dynamic tbl, dynamic id) {
    // This assumes the table has an 'id' column
    // In practice, Drift generates specific column accessors
    throw UnimplementedError(
      'Subclasses must override _buildIdCondition based on table schema',
    );
  }
}
