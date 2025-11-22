/// Annotations for automatic service discovery and registration
/// Used with build_runner for code generation

/// Marks a class as a singleton service
/// The service will be registered once and the same instance returned on each request
///
/// Example:
/// ```dart
/// @Singleton()
/// class DatabaseService {
///   void connect() { /* ... */ }
/// }
/// ```
///
/// With custom name:
/// ```dart
/// @Singleton(name: 'primaryDb')
/// class DatabaseService { /* ... */ }
/// ```
class Singleton {
  /// Optional name for the service instance
  /// Useful when you have multiple implementations of the same interface
  final String? name;

  /// Optional list of interfaces/abstract classes this service implements
  /// The service will be registered under these types as well
  final List<Type>? asType;

  /// Whether to register asynchronously
  /// Use when the service needs async initialization
  final bool async;

  const Singleton({this.name, this.asType, this.async = false});
}

/// Marks a class as a factory service
/// A new instance will be created on each request
///
/// Example:
/// ```dart
/// @Service()
/// class EmailSender {
///   void send(String to, String message) { /* ... */ }
/// }
/// ```
///
/// With custom name:
/// ```dart
/// @Service(name: 'smtp')
/// class SmtpEmailSender implements EmailSender { /* ... */ }
/// ```
class Service {
  /// Optional name for the service instance
  final String? name;

  /// Optional list of interfaces/abstract classes this service implements
  final List<Type>? asType;

  const Service({this.name, this.asType});
}

/// Marks a class as a lazy singleton
/// Similar to @Singleton but the instance is created on first access
///
/// Example:
/// ```dart
/// @LazySingleton()
/// class ExpensiveService {
///   ExpensiveService() {
///     // Heavy initialization here
///   }
/// }
/// ```
class LazySingleton {
  /// Optional name for the service instance
  final String? name;

  /// Optional list of interfaces/abstract classes this service implements
  final List<Type>? asType;

  const LazySingleton({this.name, this.asType});
}

/// Marks a parameter as injectable
/// Used to specify which dependency to inject when there are multiple implementations
///
/// Example:
/// ```dart
/// @Singleton()
/// class UserController {
///   final EmailSender emailSender;
///
///   UserController(@Named('smtp') this.emailSender);
/// }
/// ```
class Named {
  /// The name of the service to inject
  final String name;

  const Named(this.name);
}

/// Marks a class as a module that groups related service registrations
/// Modules help organize large applications by grouping related services
///
/// Example:
/// ```dart
/// @Module()
/// class DatabaseModule {
///   @Singleton()
///   DatabaseConnection provideConnection() => DatabaseConnection();
///
///   @Service()
///   UserRepository provideUserRepo(DatabaseConnection conn) =>
///       UserRepository(conn);
/// }
/// ```
class Module {
  const Module();
}

/// Marks a method in a Module as a provider
/// The method will be used to create and register the service
///
/// Example:
/// ```dart
/// @Module()
/// class AppModule {
///   @Provides()
///   @Singleton()
///   HttpClient provideHttpClient() => HttpClient();
/// }
/// ```
class Provides {
  const Provides();
}
