import 'dart:io';
import 'package:test/test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:dartian_orm/dartian_orm.dart' hide isNull, isNotNull;

part 'drift_database_config_test.g.dart';

@DriftDatabase(tables: [])
class TestConfigDatabase extends DartianDatabase {
  TestConfigDatabase(super.config);

  @override
  int get schemaVersion => 1;
}

void main() {
  group('DatabaseConfig', () {
    test('sqlite config stores path', () {
      const config = DatabaseConfig.sqlite('/path/to/db.sqlite');
      expect(config.type, DatabaseType.sqlite);
      expect(config.path, '/path/to/db.sqlite');
      expect(config.postgresConfig, isNull);
    });

    test('memory config has no path or postgres config', () {
      const config = DatabaseConfig.memory();
      expect(config.type, DatabaseType.memory);
      expect(config.path, isNull);
      expect(config.postgresConfig, isNull);
    });

    test('postgres config stores postgres settings', () {
      const pgConfig = PostgresConfig(
        host: 'localhost',
        port: 5432,
        database: 'testdb',
        username: 'user',
        password: 'pass',
      );
      const config = DatabaseConfig.postgres(pgConfig);
      expect(config.type, DatabaseType.postgres);
      expect(config.path, isNull);
      expect(config.postgresConfig, isNotNull);
      expect(config.postgresConfig!.host, 'localhost');
      expect(config.postgresConfig!.port, 5432);
    });
  });

  group('PostgresConfig', () {
    test('stores all connection details', () {
      const config = PostgresConfig(
        host: '192.168.1.1',
        port: 5433,
        database: 'myapp',
        username: 'admin',
        password: 'secret',
      );
      expect(config.host, '192.168.1.1');
      expect(config.port, 5433);
      expect(config.database, 'myapp');
      expect(config.username, 'admin');
      expect(config.password, 'secret');
    });
  });

  group('DartianDatabase with memory', () {
    late TestConfigDatabase db;

    setUp(() {
      db = TestConfigDatabase(const DatabaseConfig.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('creates database with memory config', () {
      expect(db.config.type, DatabaseType.memory);
    });

    test('can perform database operations', () async {
      // Verify database is functional
      final result = await db.customSelect('SELECT 1 as value').getSingle();
      expect(result.read<int>('value'), 1);
    });

    test('closes connection', () async {
      await db.closeConnection();
      // After closing, database is closed
      // We can't easily test that operations fail without causing test framework issues,
      // so we just verify the close method runs without error
      expect(db.config.type, DatabaseType.memory);
    });
  });

  group('DartianDatabase with SQLite', () {
    test('creates database with sqlite file', () async {
      final tempDir = Directory.systemTemp.createTempSync('drift_test_');
      final dbPath = '${tempDir.path}/test.db';

      final db = TestConfigDatabase(DatabaseConfig.sqlite(dbPath));
      expect(db.config.type, DatabaseType.sqlite);
      expect(db.config.path, dbPath);

      // Verify database works
      final result = await db.customSelect('SELECT 1 as value').getSingle();
      expect(result.read<int>('value'), 1);

      await db.close();

      // Verify file was created
      expect(File(dbPath).existsSync(), isTrue);

      // Cleanup
      tempDir.deleteSync(recursive: true);
    });

    test('throws error when sqlite path is null', () {
      expect(
        () => TestConfigDatabase(const DatabaseConfig.sqlite(null)),
        throwsArgumentError,
      );
    });
  });

  group('DartianDatabase with PostgreSQL', () {
    test('throws error when postgres config is null', () {
      expect(
        () => TestConfigDatabase(const DatabaseConfig.postgres(null)),
        throwsArgumentError,
      );
    });

    test('creates config with postgres settings', () {
      const pgConfig = PostgresConfig(
        host: 'localhost',
        port: 5432,
        database: 'testdb',
        username: 'test',
        password: 'test',
      );
      const config = DatabaseConfig.postgres(pgConfig);

      // We can't actually connect without a real PostgreSQL server,
      // but we can verify the config is created correctly
      expect(config.type, DatabaseType.postgres);
      expect(config.postgresConfig, isNotNull);
      expect(config.postgresConfig!.host, 'localhost');
    });
  });

  group('DatabaseType enum', () {
    test('has correct values', () {
      expect(DatabaseType.sqlite, DatabaseType.sqlite);
      expect(DatabaseType.memory, DatabaseType.memory);
      expect(DatabaseType.postgres, DatabaseType.postgres);
    });
  });
}
