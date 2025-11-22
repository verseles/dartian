import 'package:test/test.dart';
import 'package:dartian_di/dartian_di.dart';

void main() {
  group('Annotations', () {
    group('@Singleton', () {
      test('can be created without parameters', () {
        const annotation = Singleton();
        expect(annotation.name, isNull);
        expect(annotation.asType, isNull);
        expect(annotation.async, isFalse);
      });

      test('can be created with name', () {
        const annotation = Singleton(name: 'myService');
        expect(annotation.name, equals('myService'));
      });

      test('can be created with async flag', () {
        const annotation = Singleton(async: true);
        expect(annotation.async, isTrue);
      });

      test('can be created with asType', () {
        const annotation = Singleton(asType: [String, int]);
        expect(annotation.asType, contains(String));
        expect(annotation.asType, contains(int));
      });

      test('can be created with all parameters', () {
        const annotation = Singleton(
          name: 'fullService',
          asType: [Object],
          async: true,
        );
        expect(annotation.name, equals('fullService'));
        expect(annotation.asType, contains(Object));
        expect(annotation.async, isTrue);
      });
    });

    group('@Service', () {
      test('can be created without parameters', () {
        const annotation = Service();
        expect(annotation.name, isNull);
        expect(annotation.asType, isNull);
      });

      test('can be created with name', () {
        const annotation = Service(name: 'factoryService');
        expect(annotation.name, equals('factoryService'));
      });

      test('can be created with asType', () {
        const annotation = Service(asType: [String]);
        expect(annotation.asType, contains(String));
      });
    });

    group('@LazySingleton', () {
      test('can be created without parameters', () {
        const annotation = LazySingleton();
        expect(annotation.name, isNull);
        expect(annotation.asType, isNull);
      });

      test('can be created with name', () {
        const annotation = LazySingleton(name: 'lazyService');
        expect(annotation.name, equals('lazyService'));
      });

      test('can be created with asType', () {
        const annotation = LazySingleton(asType: [Object]);
        expect(annotation.asType, contains(Object));
      });
    });

    group('@Named', () {
      test('can be created with name', () {
        const annotation = Named('myInstance');
        expect(annotation.name, equals('myInstance'));
      });
    });

    group('@Module', () {
      test('can be created', () {
        const annotation = Module();
        expect(annotation, isNotNull);
      });
    });

    group('@Provides', () {
      test('can be created', () {
        const annotation = Provides();
        expect(annotation, isNotNull);
      });
    });
  });

  group('DIContainer extensions', () {
    late DIContainer container;

    setUp(() async {
      container = DIContainer();
      await container.reset();
    });

    test('registerLazySingleton creates instance on first access', () {
      var creationCount = 0;
      container.registerLazySingleton<LazyTestService>(
        () {
          creationCount++;
          return LazyTestService();
        },
        instanceName: 'lazy1',
      );

      // Not created yet
      expect(creationCount, equals(0));

      // First access creates it
      final instance1 = container.get<LazyTestService>(instanceName: 'lazy1');
      expect(creationCount, equals(1));
      expect(instance1, isNotNull);

      // Second access returns same instance
      final instance2 = container.get<LazyTestService>(instanceName: 'lazy1');
      expect(creationCount, equals(1)); // Still 1, not created again
      expect(instance2, same(instance1));
    });

    test('unregister removes service from container', () {
      container.registerSingleton<String>(
        () => 'Test',
        instanceName: 'unregTest',
      );
      expect(container.isRegistered<String>(instanceName: 'unregTest'), isTrue);

      container.unregister<String>(instanceName: 'unregTest');
      expect(
          container.isRegistered<String>(instanceName: 'unregTest'), isFalse);
    });

    test('lazy singleton returns same instance on multiple calls', () {
      container.registerLazySingleton<LazyTestService>(
        () => LazyTestService(),
        instanceName: 'lazy2',
      );

      final instances = <LazyTestService>[];
      for (var i = 0; i < 5; i++) {
        instances.add(container.get<LazyTestService>(instanceName: 'lazy2'));
      }

      // All instances should be the same
      for (var i = 1; i < instances.length; i++) {
        expect(instances[i], same(instances[0]));
      }
    });
  });

  group('Auto-discovery simulation', () {
    // These tests simulate what the generated code would look like
    late DIContainer container;

    setUp(() async {
      container = DIContainer();
      await container.reset();
    });

    test('simulated singleton registration works', () {
      // This simulates: @Singleton() class DatabaseService {}
      void registerDatabaseService(DIContainer c) {
        c.registerSingleton<DatabaseService>(() => DatabaseService());
      }

      registerDatabaseService(container);
      final db = container.get<DatabaseService>();
      expect(db, isNotNull);
      expect(db.name, equals('DatabaseService'));
    });

    test('simulated service (factory) registration works', () {
      // This simulates: @Service() class RequestHandler {}
      void registerRequestHandler(DIContainer c) {
        c.registerFactory<RequestHandler>(() => RequestHandler());
      }

      registerRequestHandler(container);
      final handler1 = container.get<RequestHandler>();
      final handler2 = container.get<RequestHandler>();
      expect(handler1, isNot(same(handler2))); // Different instances
    });

    test('simulated lazy singleton registration works', () {
      // This simulates: @LazySingleton() class ExpensiveService {}
      void registerExpensiveService(DIContainer c) {
        c.registerLazySingleton<ExpensiveService>(() => ExpensiveService());
      }

      registerExpensiveService(container);
      final service1 = container.get<ExpensiveService>();
      final service2 = container.get<ExpensiveService>();
      expect(service1, same(service2)); // Same instance
    });

    test('simulated named registration works', () {
      // This simulates: @Singleton(name: 'primary') class DatabaseService {}
      void registerPrimaryDatabase(DIContainer c) {
        c.registerSingleton<DatabaseService>(
          () => DatabaseService(),
          instanceName: 'primary',
        );
      }

      // This simulates: @Singleton(name: 'replica') class DatabaseService {}
      void registerReplicaDatabase(DIContainer c) {
        c.registerSingleton<DatabaseService>(
          () => DatabaseService()..name = 'Replica',
          instanceName: 'replica',
        );
      }

      registerPrimaryDatabase(container);
      registerReplicaDatabase(container);

      final primary = container.get<DatabaseService>(instanceName: 'primary');
      final replica = container.get<DatabaseService>(instanceName: 'replica');

      expect(primary, isNot(same(replica)));
      expect(primary.name, equals('DatabaseService'));
      expect(replica.name, equals('Replica'));
    });

    test('registerAll pattern works', () {
      // This simulates generated registerAllServices function
      void registerAllServices(DIContainer c) {
        c.registerSingleton<DatabaseService>(() => DatabaseService());
        c.registerFactory<RequestHandler>(() => RequestHandler());
        c.registerLazySingleton<ExpensiveService>(() => ExpensiveService());
      }

      registerAllServices(container);

      expect(container.isRegistered<DatabaseService>(), isTrue);
      expect(container.isRegistered<RequestHandler>(), isTrue);
      expect(container.isRegistered<ExpensiveService>(), isTrue);
    });
  });
}

// Test classes
class LazyTestService {
  final DateTime createdAt = DateTime.now();
}

class DatabaseService {
  String name = 'DatabaseService';
}

class RequestHandler {
  final String id = DateTime.now().microsecondsSinceEpoch.toString();
}

class ExpensiveService {
  final String id = 'expensive_${DateTime.now().microsecondsSinceEpoch}';
}
