import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:dartian_orm/dartian_orm.dart';

part 'test_database.g.dart';

/// Test table for users
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Test table for posts
class Posts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  TextColumn get title => text()();
  TextColumn get content => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Test table for roles
class Roles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

/// Pivot table for user-role many-to-many relationship
class UserRoles extends Table {
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get roleId => integer().references(Roles, #id)();

  @override
  Set<Column> get primaryKey => {userId, roleId};
}

/// Test table for profiles (one-to-one with users)
class Profiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().unique().references(Users, #id)();
  TextColumn get bio => text().nullable()();
  TextColumn get avatar => text().nullable()();
}

/// Test database implementation
@DriftDatabase(tables: [Users, Posts, Roles, UserRoles, Profiles])
class TestDatabase extends _$TestDatabase {
  TestDatabase([QueryExecutor? executor])
      : super(executor ?? NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
    );
  }
}
