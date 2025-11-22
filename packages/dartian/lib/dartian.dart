/// Dartian - A Laravel-inspired web framework for Dart
///
/// This is the umbrella package that provides convenient access to all Dartian components.
///
/// For the full framework:
/// ```dart
/// import 'package:dartian/dartian.dart';
/// ```
///
/// Or import specific components to avoid conflicts:
/// ```dart
/// import 'package:dartian/http.dart';
/// import 'package:dartian/router.dart';
/// import 'package:dartian/di.dart';
/// ```
library dartian;

// Core utilities (no conflicts)
export 'package:dartian_core/dartian_core.dart';

// DI container (no conflicts)
export 'package:dartian_di/dartian_di.dart';

// Router (no conflicts)
export 'package:dartian_router/dartian_router.dart';

// i18n (no conflicts)
export 'package:dartian_i18n/dartian_i18n.dart';
