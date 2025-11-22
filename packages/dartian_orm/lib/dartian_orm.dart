/// Dartian ORM package
/// Provides database connectivity and ORM functionality using Drift
library dartian_orm;

// Legacy SQLite3-based implementation (for backward compatibility)
export 'src/database.dart';
export 'src/repository.dart';
export 'src/query_builder.dart';

// Drift-based implementation (recommended)
export 'src/drift_database.dart';
export 'src/model.dart';
export 'src/relationships.dart';
export 'src/drift_migration.dart';

// Re-export Drift for convenience
export 'package:drift/drift.dart';
