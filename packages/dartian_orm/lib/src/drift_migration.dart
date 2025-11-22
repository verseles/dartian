import 'package:drift/drift.dart';

/// Drift-based migration interface
///
/// Provides a clean API for database migrations using Drift.
/// Use this instead of the legacy Migration class for new projects.
abstract class DriftMigration {
  /// Migration version number
  int get version;

  /// Run the migration
  Future<void> up(Migrator m, QueryExecutor executor);

  /// Reverse the migration (optional)
  Future<void> down(Migrator m, QueryExecutor executor) async {
    throw UnimplementedError(
      'Migration rollback not implemented for version $version',
    );
  }
}

/// Helper class to manage Drift migrations
///
/// Example:
/// ```dart
/// @override
/// MigrationStrategy get migration {
///   return DriftMigrationHelper.simple((m) async {
///     await m.createAll();
///   });
/// }
/// ```
class DriftMigrationHelper {
  /// Create a basic migration strategy with just onCreate
  static MigrationStrategy simple(OnCreate onCreate) {
    return MigrationStrategy(onCreate: onCreate);
  }
}

/// Common migration operations helper
class MigrationOperations {
  final Migrator migrator;
  final QueryExecutor executor;

  MigrationOperations(this.migrator, this.executor);

  /// Add a column to a table
  Future<void> addColumn(String table, String columnDef) async {
    await executor.runCustom('ALTER TABLE $table ADD COLUMN $columnDef');
  }

  /// Rename a column (SQLite 3.25.0+)
  Future<void> renameColumn(
    String table,
    String oldName,
    String newName,
  ) async {
    await executor.runCustom(
      'ALTER TABLE $table RENAME COLUMN $oldName TO $newName',
    );
  }

  /// Drop a column (SQLite 3.35.0+)
  Future<void> dropColumn(String table, String column) async {
    await executor.runCustom('ALTER TABLE $table DROP COLUMN $column');
  }

  /// Create an index
  Future<void> createIndex(
    String indexName,
    String table,
    List<String> columns, {
    bool unique = false,
  }) async {
    final uniqueStr = unique ? 'UNIQUE ' : '';
    final columnsStr = columns.join(', ');
    await executor.runCustom(
      'CREATE ${uniqueStr}INDEX $indexName ON $table($columnsStr)',
    );
  }

  /// Drop an index
  Future<void> dropIndex(String indexName) async {
    await executor.runCustom('DROP INDEX IF EXISTS $indexName');
  }

  /// Execute raw SQL
  Future<void> raw(String sql) async {
    await executor.runCustom(sql);
  }
}
