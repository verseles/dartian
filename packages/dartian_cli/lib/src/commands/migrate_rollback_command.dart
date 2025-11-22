import 'dart:io';
import 'package:args/args.dart';

class MigrateRollbackCommand {
  Future<void> run(List<String> arguments) async {
    final parser = ArgParser()
      ..addOption(
        'step',
        abbr: 's',
        defaultsTo: '1',
        help: 'Number of batches to rollback',
      )
      ..addOption(
        'database',
        abbr: 'd',
        defaultsTo: 'database/database.sqlite',
        help: 'Database path',
      )
      ..addFlag(
        'force',
        help: 'Force rollback in production',
        negatable: false,
      );

    ArgResults args;
    try {
      args = parser.parse(arguments);
    } catch (e) {
      print('Error parsing arguments: $e');
      print('\nUsage: dartian migrate:rollback [options]');
      print(parser.usage);
      return;
    }

    final steps = int.tryParse(args['step'] as String) ?? 1;
    final databasePath = args['database'] as String;
    final force = args['force'] as bool;

    print('⏪ Database Migration Rollback');
    print('━' * 50);
    print('📁 Database: $databasePath');
    print('🔢 Steps: $steps batch(es)');
    print('━' * 50);
    print('');

    // Check if database exists
    final dbFile = File(databasePath);
    if (!dbFile.existsSync()) {
      print('❌ Error: Database not found at $databasePath');
      print('💡 Run migrations first: dartian migrate');
      return;
    }

    // Check if migrations directory exists
    final migrationsDir = Directory('database/migrations');
    if (!migrationsDir.existsSync()) {
      print('❌ Error: Migrations directory not found');
      print('💡 Create migrations directory: database/migrations/');
      return;
    }

    // Load migration files
    final migrationFiles = _loadMigrationFiles(migrationsDir);

    if (migrationFiles.isEmpty) {
      print('⚠️  No migrations found');
      return;
    }

    print('🔄 Rolling back migrations...');
    print('');

    await _rollbackMigrations(migrationFiles, steps, force);
  }

  List<String> _loadMigrationFiles(Directory dir) {
    final files =
        dir
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.dart'))
            .map((file) => file.path.split('/').last)
            .toList()
          ..sort((a, b) => b.compareTo(a)); // Reverse order for rollback

    return files;
  }

  Future<void> _rollbackMigrations(
    List<String> migrationFiles,
    int steps,
    bool force,
  ) async {
    // Simulate rollback of last batch
    final migrationsToRollback = migrationFiles.take(steps).toList();

    if (migrationsToRollback.isEmpty) {
      print('  Nothing to rollback');
      return;
    }

    print('  Rolling back batch...');
    print('');

    for (final file in migrationsToRollback) {
      final displayName = file.replaceAll('.dart', '');
      print('  Rolling back: $displayName');

      // Simulate processing time
      await Future.delayed(const Duration(milliseconds: 100));

      print('  ✓ Rolled back: $displayName');
    }

    print('');
    print('✅ Rollback completed successfully');
    print('   Rolled back ${migrationsToRollback.length} migration(s)');
    print('');
    print('💡 Note: This is a placeholder implementation');
    print(
      '💡 Real rollback requires loading and executing migration down() methods',
    );
  }
}
