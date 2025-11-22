import 'package:test/test.dart';
import 'package:dartian_di/dartian_di.dart';

void main() {
  group('Cycle Detection', () {
    late DIContainer container;

    setUp(() async {
      container = DIContainer();
      await container.reset();
      container.clearDependencyGraph();
    });

    group('CircularDependencyException', () {
      test('creates readable message from cycle path', () {
        final exception = CircularDependencyException([ServiceA, ServiceB]);
        expect(exception.message, contains('Circular dependency detected'));
        expect(exception.message, contains('ServiceA'));
        expect(exception.message, contains('ServiceB'));
      });

      test('toString returns the message', () {
        final exception = CircularDependencyException([ServiceA, ServiceB]);
        expect(exception.toString(), equals(exception.message));
      });
    });

    group('registerDependencies', () {
      test('registers dependencies for a service', () {
        container.registerDependencies<ServiceA>([ServiceB]);
        expect(container.hasDependencies<ServiceA>(), isTrue);
        expect(container.getDependencies<ServiceA>(), contains(ServiceB));
      });

      test('allows registering empty dependencies', () {
        container.registerDependencies<ServiceA>([]);
        expect(container.hasDependencies<ServiceA>(), isTrue);
        expect(container.getDependencies<ServiceA>(), isEmpty);
      });

      test('overwrites previous dependencies', () {
        container.registerDependencies<ServiceA>([ServiceB]);
        container.registerDependencies<ServiceA>([ServiceC]);
        expect(container.getDependencies<ServiceA>(), contains(ServiceC));
        expect(
          container.getDependencies<ServiceA>(),
          isNot(contains(ServiceB)),
        );
      });
    });

    group('Simple cycles', () {
      test('detects direct self-dependency (A → A)', () {
        expect(
          () => container.registerDependencies<ServiceA>([ServiceA]),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('detects two-service cycle (A → B → A)', () {
        container.registerDependencies<ServiceB>([ServiceA]);

        expect(
          () => container.registerDependencies<ServiceA>([ServiceB]),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('detects three-service cycle (A → B → C → A)', () {
        container.registerDependencies<ServiceB>([ServiceC]);
        container.registerDependencies<ServiceC>([ServiceA]);

        expect(
          () => container.registerDependencies<ServiceA>([ServiceB]),
          throwsA(isA<CircularDependencyException>()),
        );
      });
    });

    group('Complex graphs', () {
      test('allows valid DAG (no cycles)', () {
        // D depends on B and C
        // B depends on A
        // C depends on A
        // Valid DAG: A ← B ← D
        //            A ← C ←┘
        container.registerDependencies<ServiceA>([]);
        container.registerDependencies<ServiceB>([ServiceA]);
        container.registerDependencies<ServiceC>([ServiceA]);
        container.registerDependencies<ServiceD>([ServiceB, ServiceC]);

        expect(container.dependencyGraph, hasLength(4));
      });

      test('detects cycle in complex graph', () {
        // Setup: B → C → D, then try to add D → B creating cycle
        container.registerDependencies<ServiceC>([]);
        container.registerDependencies<ServiceD>([ServiceC]);
        container.registerDependencies<ServiceB>([ServiceD]);

        // Now try to create a cycle by making C depend on B (C → B → D → C)
        expect(
          () => container.registerDependencies<ServiceC>([ServiceB]),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('allows diamond dependency (no cycle)', () {
        // Diamond: A → B → D
        //          A → C → D
        container.registerDependencies<ServiceD>([]);
        container.registerDependencies<ServiceB>([ServiceD]);
        container.registerDependencies<ServiceC>([ServiceD]);
        container.registerDependencies<ServiceA>([ServiceB, ServiceC]);

        expect(container.dependencyGraph, hasLength(4));
      });
    });

    group('detectCycle', () {
      test('returns null for valid dependency', () {
        container.registerDependencies<ServiceB>([]);
        final cycle = container.detectCycle<ServiceA>(ServiceB);
        expect(cycle, isNull);
      });

      test('returns cycle path for circular dependency', () {
        // First register A so it exists in the graph
        container.registerDependencies<ServiceA>([]);
        // Then register B depending on A
        container.registerDependencies<ServiceB>([ServiceA]);
        // Now check if adding A → B would create a cycle
        final cycle = container.detectCycle<ServiceA>(ServiceB);
        expect(cycle, isNotNull);
        expect(cycle, contains(ServiceA));
        expect(cycle, contains(ServiceB));
      });
    });

    group('Integration with registration methods', () {
      test('registerSingletonWithDeps validates dependencies', () {
        container.registerSingletonWithDeps<ServiceB>(
          () => ServiceB(),
          dependsOn: [],
        );

        expect(
          () => container.registerSingletonWithDeps<ServiceA>(
            () => ServiceA(),
            dependsOn: [ServiceA], // Self-dependency
          ),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('registerFactoryWithDeps validates dependencies', () {
        container.registerFactoryWithDeps<ServiceB>(
          () => ServiceB(),
          dependsOn: [ServiceA],
        );

        expect(
          () => container.registerFactoryWithDeps<ServiceA>(
            () => ServiceA(),
            dependsOn: [ServiceB], // Creates cycle
          ),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('registerLazySingletonWithDeps validates dependencies', () {
        container.registerLazySingletonWithDeps<ServiceB>(
          () => ServiceB(),
          dependsOn: [ServiceA],
        );

        expect(
          () => container.registerLazySingletonWithDeps<ServiceA>(
            () => ServiceA(),
            dependsOn: [ServiceB], // Creates cycle
          ),
          throwsA(isA<CircularDependencyException>()),
        );
      });

      test('successful registration with deps allows service resolution', () {
        container.registerSingletonWithDeps<ServiceA>(
          () => ServiceA(),
          dependsOn: [],
        );
        container.registerSingletonWithDeps<ServiceB>(
          () => ServiceB(),
          dependsOn: [ServiceA],
        );

        expect(container.get<ServiceA>(), isA<ServiceA>());
        expect(container.get<ServiceB>(), isA<ServiceB>());
      });
    });

    group('clearDependencyGraph', () {
      test('clears all tracked dependencies', () {
        container.registerDependencies<ServiceA>([ServiceB]);
        container.registerDependencies<ServiceB>([]);

        container.clearDependencyGraph();

        expect(container.dependencyGraph, isEmpty);
        expect(container.hasDependencies<ServiceA>(), isFalse);
      });

      test('allows reregistration after clear', () {
        // First, register some dependencies
        container.registerDependencies<ServiceA>([]);
        container.registerDependencies<ServiceB>([ServiceA]);

        expect(container.dependencyGraph, hasLength(2));

        // Clear and verify
        container.clearDependencyGraph();
        expect(container.dependencyGraph, isEmpty);

        // Now we can register fresh dependencies
        container.registerDependencies<ServiceC>([]);
        expect(container.hasDependencies<ServiceC>(), isTrue);
        expect(container.hasDependencies<ServiceA>(), isFalse);
      });
    });

    group('unregister removes from dependency graph', () {
      test('removes type from dependency graph on unregister', () {
        container.registerSingletonWithDeps<ServiceA>(
          () => ServiceA(),
          dependsOn: [],
        );

        expect(container.hasDependencies<ServiceA>(), isTrue);

        container.unregister<ServiceA>();

        expect(container.hasDependencies<ServiceA>(), isFalse);
      });
    });

    group('Exception message quality', () {
      test('shows complete cycle path', () {
        container.registerDependencies<ServiceC>([ServiceA]);
        container.registerDependencies<ServiceB>([ServiceC]);

        try {
          container.registerDependencies<ServiceA>([ServiceB]);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<CircularDependencyException>());
          final exception = e as CircularDependencyException;
          expect(exception.cycle.length, greaterThanOrEqualTo(2));
        }
      });
    });
  });
}

// Test service classes
class ServiceA {
  final String id = 'A';
}

class ServiceB {
  final String id = 'B';
}

class ServiceC {
  final String id = 'C';
}

class ServiceD {
  final String id = 'D';
}
