import 'package:dartian_orm/database.dart';
import 'package:drift/native.dart';

void main() {
  final database = AppDatabase(NativeDatabase.memory());
  print('Database schema version: ${database.schemaVersion}');
}
