import 'database.dart';

/// Base class for database migrations
abstract class Migration {
  /// Run the migration
  Future<void> up(QueryDatabase db);

  /// Reverse the migration
  Future<void> down(QueryDatabase db);
}

/// Manages database migrations
class MigrationRunner {
  final QueryDatabase _db;
  final String _migrationsTable;

  MigrationRunner(this._db, {String migrationsTable = 'migrations'})
      : _migrationsTable = migrationsTable;

  /// Initialize the migrations table
  Future<void> initialize() async {
    _db.execute('''
      CREATE TABLE IF NOT EXISTS $_migrationsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        migration TEXT NOT NULL UNIQUE,
        batch INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''', []);
  }

  /// Get the current batch number
  int _getCurrentBatch() {
    try {
      final result = _db.querySingle<int>(
        'SELECT COALESCE(MAX(batch), 0) FROM $_migrationsTable',
        [],
      );
      return result;
    } catch (e) {
      return 0;
    }
  }

  /// Get all executed migrations
  List<String> getExecutedMigrations() {
    final result = _db.query(
      'SELECT migration FROM $_migrationsTable ORDER BY id',
      [],
    );
    return result.map((row) => row['migration'] as String).toList();
  }

  /// Get migrations from the last batch
  List<String> getLastBatchMigrations() {
    final currentBatch = _getCurrentBatch();
    if (currentBatch == 0) return [];

    final result = _db.query(
      'SELECT migration FROM $_migrationsTable WHERE batch = ? ORDER BY id DESC',
      [currentBatch],
    );
    return result.map((row) => row['migration'] as String).toList();
  }

  /// Run pending migrations
  Future<int> runMigrations(Map<String, Migration> migrations) async {
    await initialize();

    final executedMigrations = getExecutedMigrations().toSet();
    final pendingMigrations = migrations.entries
        .where((entry) => !executedMigrations.contains(entry.key))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (pendingMigrations.isEmpty) {
      return 0;
    }

    final newBatch = _getCurrentBatch() + 1;

    for (final entry in pendingMigrations) {
      final name = entry.key;
      final migration = entry.value;

      print('  Migrating: $name');

      try {
        await migration.up(_db);

        _db.execute(
          'INSERT INTO $_migrationsTable (migration, batch, created_at) VALUES (?, ?, ?)',
          [name, newBatch, DateTime.now().toIso8601String()],
        );

        print('  ✓ Migrated:  $name');
      } catch (e) {
        print('  ✗ Failed:    $name');
        print('  Error: $e');
        rethrow;
      }
    }

    return pendingMigrations.length;
  }

  /// Rollback the last batch of migrations
  Future<int> rollback(Map<String, Migration> migrations, {int steps = 1}) async {
    await initialize();

    int totalRolledBack = 0;

    for (int i = 0; i < steps; i++) {
      final lastBatch = getLastBatchMigrations();

      if (lastBatch.isEmpty) {
        if (totalRolledBack == 0) {
          print('  Nothing to rollback');
        }
        break;
      }

      print('  Rolling back batch...');

      for (final name in lastBatch) {
        final migration = migrations[name];

        if (migration == null) {
          print('  ⚠ Warning: Migration class not found for $name');
          // Still remove from database
          _db.execute(
            'DELETE FROM $_migrationsTable WHERE migration = ?',
            [name],
          );
          continue;
        }

        print('  Rolling back: $name');

        try {
          await migration.down(_db);

          _db.execute(
            'DELETE FROM $_migrationsTable WHERE migration = ?',
            [name],
          );

          print('  ✓ Rolled back: $name');
          totalRolledBack++;
        } catch (e) {
          print('  ✗ Failed:      $name');
          print('  Error: $e');
          rethrow;
        }
      }
    }

    return totalRolledBack;
  }

  /// Get migration status
  Map<String, dynamic> getStatus(Map<String, Migration> migrations) {
    final executed = getExecutedMigrations().toSet();
    final all = migrations.keys.toList()..sort();
    final pending = all.where((name) => !executed.contains(name)).toList();

    return {
      'total': all.length,
      'executed': executed.length,
      'pending': pending.length,
      'executedMigrations': executed.toList()..sort(),
      'pendingMigrations': pending,
    };
  }
}
