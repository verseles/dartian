import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:postgres/postgres.dart' as pg;

part 'drift_database.g.dart';

/// Configuration for database connection
class DatabaseConfig {
  final DatabaseType type;
  final String? path;
  final PostgresConfig? postgresConfig;

  const DatabaseConfig.sqlite(this.path)
      : type = DatabaseType.sqlite,
        postgresConfig = null;

  const DatabaseConfig.memory()
      : type = DatabaseType.memory,
        path = null,
        postgresConfig = null;

  const DatabaseConfig.postgres(this.postgresConfig)
      : type = DatabaseType.postgres,
        path = null;
}

class PostgresConfig {
  final String host;
  final int port;
  final String database;
  final String username;
  final String password;

  const PostgresConfig({
    required this.host,
    required this.port,
    required this.database,
    required this.username,
    required this.password,
  });
}

enum DatabaseType { sqlite, memory, postgres }

/// Base database class for Dartian ORM using Drift
///
/// This class provides the foundation for type-safe database operations.
/// To use it, create a subclass that defines your tables.
///
/// Example:
/// ```dart
/// @DriftDatabase(tables: [Users, Posts])
/// class AppDatabase extends DartianDatabase {
///   AppDatabase(super.config);
///
///   @override
///   int get schemaVersion => 1;
/// }
/// ```
@DriftDatabase(tables: [])
class DartianDatabase extends _$DartianDatabase {
  final DatabaseConfig config;

  DartianDatabase(this.config) : super(_openConnection(config));

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection(DatabaseConfig config) {
    switch (config.type) {
      case DatabaseType.memory:
        return NativeDatabase.memory();
      case DatabaseType.sqlite:
        if (config.path == null) {
          throw ArgumentError('SQLite path is required');
        }
        return NativeDatabase(File(config.path!));
      case DatabaseType.postgres:
        final pgConfig = config.postgresConfig;
        if (pgConfig == null) {
          throw ArgumentError('PostgreSQL config is required');
        }
        final endpoint = pg.Endpoint(
          host: pgConfig.host,
          port: pgConfig.port,
          database: pgConfig.database,
          username: pgConfig.username,
          password: pgConfig.password,
        );
        return PgDatabase(endpoint: endpoint);
    }
  }

  /// Close the database connection
  Future<void> closeConnection() => close();
}
