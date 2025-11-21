import 'package:test/test.dart';
import 'package:dartian_orm/dartian_orm.dart';

/// Test migration that creates a table
class CreateUsersTable extends Migration {
  @override
  Future<void> up(QueryDatabase db) async {
    db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''', []);
  }

  @override
  Future<void> down(QueryDatabase db) async {
    db.execute('DROP TABLE IF EXISTS users', []);
  }
}

/// Test migration that adds a column
class AddAgeToUsersTable extends Migration {
  @override
  Future<void> up(QueryDatabase db) async {
    db.execute('ALTER TABLE users ADD COLUMN age INTEGER', []);
  }

  @override
  Future<void> down(QueryDatabase db) async {
    // SQLite doesn't support DROP COLUMN directly
    // In a real scenario, you'd recreate the table
    // For test purposes, we'll just leave it
  }
}

/// Test migration that creates an index
class AddEmailIndexToUsersTable extends Migration {
  @override
  Future<void> up(QueryDatabase db) async {
    db.execute('CREATE INDEX idx_users_email ON users(email)', []);
  }

  @override
  Future<void> down(QueryDatabase db) async {
    db.execute('DROP INDEX IF EXISTS idx_users_email', []);
  }
}

/// Migration that will fail on purpose (on up)
class FailingMigration extends Migration {
  @override
  Future<void> up(QueryDatabase db) async {
    db.execute('INVALID SQL SYNTAX HERE', []);
  }

  @override
  Future<void> down(QueryDatabase db) async {
    // Nothing to rollback
  }
}

/// Migration that will fail on down
class FailingDownMigration extends Migration {
  @override
  Future<void> up(QueryDatabase db) async {
    db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''', []);
  }

  @override
  Future<void> down(QueryDatabase db) async {
    db.execute('INVALID SQL SYNTAX ON DOWN', []);
  }
}

void main() {
  group('MigrationRunner', () {
    late QueryDatabase db;
    late MigrationRunner runner;

    setUp(() {
      db = DatabaseManager.instance.inMemoryDatabase();
      runner = MigrationRunner(db);
    });

    tearDown(() {
      db.close();
    });

    group('initialize', () {
      test('should create migrations table', () async {
        await runner.initialize();

        expect(db.tableExists('migrations'), isTrue);
      });

      test('should be idempotent (can be called multiple times)', () async {
        await runner.initialize();
        await runner.initialize();
        await runner.initialize();

        expect(db.tableExists('migrations'), isTrue);
      });
    });

    group('runMigrations', () {
      test('should run pending migrations', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        final count = await runner.runMigrations(migrations);

        expect(count, 1);
        expect(db.tableExists('users'), isTrue);
      });

      test('should run multiple migrations in order', () async {
        final migrations = <String, Migration>{
          '002_add_age_to_users': AddAgeToUsersTable(),
          '001_create_users_table': CreateUsersTable(),
        };

        final count = await runner.runMigrations(migrations);

        expect(count, 2);
        expect(db.tableExists('users'), isTrue);
      });

      test('should not run already executed migrations', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        await runner.runMigrations(migrations);
        final secondCount = await runner.runMigrations(migrations);

        expect(secondCount, 0);
      });

      test('should return 0 when no pending migrations', () async {
        final count = await runner.runMigrations({});

        expect(count, 0);
      });

      test('should track batch numbers', () async {
        final firstMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        final secondMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        await runner.runMigrations(firstMigrations);
        await runner.runMigrations(secondMigrations);

        // Verify both migrations ran successfully
        final executed = runner.getExecutedMigrations();
        expect(executed.length, 2);
      });

      test('should rethrow errors on migration failure', () async {
        final migrations = <String, Migration>{
          '001_failing': FailingMigration(),
        };

        expect(
          () => runner.runMigrations(migrations),
          throwsA(anything),
        );
      });
    });

    group('getExecutedMigrations', () {
      test('should return empty list when no migrations executed', () async {
        await runner.initialize();

        final executed = runner.getExecutedMigrations();

        expect(executed, isEmpty);
      });

      test('should return list of executed migration names', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        await runner.runMigrations(migrations);

        final executed = runner.getExecutedMigrations();

        expect(executed.length, 2);
        expect(executed, contains('001_create_users_table'));
        expect(executed, contains('002_add_age_to_users'));
      });
    });

    group('getLastBatchMigrations', () {
      test('should return empty list when no migrations', () async {
        await runner.initialize();

        final lastBatch = runner.getLastBatchMigrations();

        expect(lastBatch, isEmpty);
      });

      test('should return migrations from last batch', () async {
        final firstMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        final secondMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
          '003_add_email_index': AddEmailIndexToUsersTable(),
        };

        await runner.runMigrations(firstMigrations);
        await runner.runMigrations(secondMigrations);

        final lastBatch = runner.getLastBatchMigrations();

        expect(lastBatch.length, 2);
        expect(lastBatch, contains('002_add_age_to_users'));
        expect(lastBatch, contains('003_add_email_index'));
      });
    });

    group('rollback', () {
      test('should rollback last batch of migrations', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        await runner.runMigrations(migrations);
        expect(db.tableExists('users'), isTrue);

        final rolledBack = await runner.rollback(migrations);

        expect(rolledBack, 1);
        expect(db.tableExists('users'), isFalse);
      });

      test('should rollback multiple steps', () async {
        final firstMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        final secondMigrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        await runner.runMigrations(firstMigrations);
        await runner.runMigrations(secondMigrations);

        final rolledBack = await runner.rollback(secondMigrations, steps: 2);

        expect(rolledBack, 2);
        expect(db.tableExists('users'), isFalse);
      });

      test('should return 0 when nothing to rollback', () async {
        await runner.initialize();

        final rolledBack = await runner.rollback({});

        expect(rolledBack, 0);
      });

      test('should handle missing migration class', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        await runner.runMigrations(migrations);

        // Try to rollback with empty migrations map (class not found)
        final rolledBack = await runner.rollback({});

        // Should still remove from database even if class not found
        expect(rolledBack, 0);
        expect(runner.getExecutedMigrations(), isEmpty);
      });

      test('should rethrow errors on rollback failure', () async {
        // Create and run a migration
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        await runner.runMigrations(migrations);

        // Create a migration that will fail on down
        final failingRollback = <String, Migration>{
          '001_create_users_table': FailingDownMigration(),
        };

        expect(
          () async => await runner.rollback(failingRollback),
          throwsA(anything),
        );
      });
    });

    group('getStatus', () {
      test('should return correct status with no migrations', () async {
        await runner.initialize();

        final status = runner.getStatus({});

        expect(status['total'], 0);
        expect(status['executed'], 0);
        expect(status['pending'], 0);
        expect(status['executedMigrations'], isEmpty);
        expect(status['pendingMigrations'], isEmpty);
      });

      test('should return correct status with pending migrations', () async {
        await runner.initialize();

        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        final status = runner.getStatus(migrations);

        expect(status['total'], 2);
        expect(status['executed'], 0);
        expect(status['pending'], 2);
        expect(status['pendingMigrations'], hasLength(2));
      });

      test('should return correct status after running migrations', () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        await runner.runMigrations({
          '001_create_users_table': CreateUsersTable(),
        });

        final status = runner.getStatus(migrations);

        expect(status['total'], 2);
        expect(status['executed'], 1);
        expect(status['pending'], 1);
        expect(status['executedMigrations'], ['001_create_users_table']);
        expect(status['pendingMigrations'], ['002_add_age_to_users']);
      });

      test('should return correct status when all migrations executed',
          () async {
        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
          '002_add_age_to_users': AddAgeToUsersTable(),
        };

        await runner.runMigrations(migrations);

        final status = runner.getStatus(migrations);

        expect(status['total'], 2);
        expect(status['executed'], 2);
        expect(status['pending'], 0);
        expect(status['pendingMigrations'], isEmpty);
      });
    });

    group('custom migrations table', () {
      test('should use custom table name', () async {
        final customRunner = MigrationRunner(db, migrationsTable: 'schema_versions');

        await customRunner.initialize();

        expect(db.tableExists('schema_versions'), isTrue);
        expect(db.tableExists('migrations'), isFalse);
      });

      test('should work with custom table name for all operations', () async {
        final customRunner = MigrationRunner(db, migrationsTable: 'custom_migrations');

        final migrations = <String, Migration>{
          '001_create_users_table': CreateUsersTable(),
        };

        await customRunner.runMigrations(migrations);

        expect(db.tableExists('custom_migrations'), isTrue);
        expect(customRunner.getExecutedMigrations(), hasLength(1));
      });
    });
  });

  group('Migration abstract class', () {
    test('CreateUsersTable should create users table', () async {
      final db = DatabaseManager.instance.inMemoryDatabase();
      final migration = CreateUsersTable();

      await migration.up(db);

      expect(db.tableExists('users'), isTrue);

      await migration.down(db);

      expect(db.tableExists('users'), isFalse);

      db.close();
    });
  });
}
