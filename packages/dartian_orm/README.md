# dartian_orm

Drift-based ORM for Dartian with relationships, migrations, and query builder - SQLite and PostgreSQL.

## Features

- Drift ORM integration
- SQLite and PostgreSQL support
- Type-safe query builder
- Migration system
- Model relationships

## Installation

```yaml
dependencies:
  dartian_orm: ^1.0.0
```

## Usage

```dart
import 'package:dartian_orm/dartian_orm.dart';

// Define your database
@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connectSqlite('app.db'));
  
  @override
  int get schemaVersion => 1;
}

// Define tables
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
}

// Use the database
final db = AppDatabase();
await db.into(db.users).insert(UsersCompanion.insert(
  name: 'John',
  email: 'john@example.com',
));

final users = await db.select(db.users).get();
```

## Part of Dartian

This package is part of the [Dartian](https://github.com/verseles/dartian) framework.

## License

AGPL-3.0 - See [LICENSE](LICENSE) for details.
