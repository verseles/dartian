import 'package:test/test.dart';
import 'package:dartian_di/dartian_di.dart';

void main() {
  group('DIContainer', () {
    test('can be instantiated', () {
      final container = DIContainer();
      expect(container, isNotNull);
    });

    test('registers and retrieves singleton', () {
      final container = DIContainer();
      container.registerSingleton<String>(
        () => 'Hello, World!',
        instanceName: 'test1',
      );
      final result = container.get<String>(instanceName: 'test1');
      expect(result, equals('Hello, World!'));
    });

    test('returns same instance for singleton', () {
      final container = DIContainer();
      final testObject = TestClass();
      container.registerSingleton<TestClass>(
        () => testObject,
        instanceName: 'test2',
      );
      final result1 = container.get<TestClass>(instanceName: 'test2');
      final result2 = container.get<TestClass>(instanceName: 'test2');
      expect(result1, same(result2));
    });

    test('returns different instances for factory', () {
      final container = DIContainer();
      container.registerFactory<TestClass>(
        () => TestClass(),
        instanceName: 'test3',
      );
      final result1 = container.get<TestClass>(instanceName: 'test3');
      final result2 = container.get<TestClass>(instanceName: 'test3');
      expect(result1, isNot(same(result2)));
    });

    test('registers and retrieves factory', () {
      final container = DIContainer();
      container.registerFactory<int>(() => 42, instanceName: 'test4');
      final result = container.get<int>(instanceName: 'test4');
      expect(result, equals(42));
    });

    test('registers async singleton', () async {
      final container = DIContainer();
      container.registerSingletonAsync<String>(
        () => Future.value('Async Hello'),
        instanceName: 'test5',
      );
      await container.ready();
      final result = container.get<String>(instanceName: 'test5');
      expect(result, equals('Async Hello'));
    });

    test('gets async service', () async {
      final container = DIContainer();
      container.registerSingletonAsync<String>(
        () => Future.value('Async Hello'),
        instanceName: 'test6',
      );
      final result = await container.getAsync<String>(instanceName: 'test6');
      expect(result, equals('Async Hello'));
    });

    test('checks if service is registered', () {
      final container = DIContainer();
      expect(container.isRegistered<String>(instanceName: 'test7'), isFalse);
      container.registerSingleton<String>(() => 'Hello', instanceName: 'test7');
      expect(container.isRegistered<String>(instanceName: 'test7'), isTrue);
    });

    test('checks if named instance is registered', () {
      final container = DIContainer();
      expect(
        container.isRegistered<String>(instanceName: 'instance1'),
        isFalse,
      );
      container.registerSingleton<String>(
        () => 'Hello',
        instanceName: 'instance1',
      );
      expect(container.isRegistered<String>(instanceName: 'instance1'), isTrue);
    });

    test('registers multiple instances with different names', () {
      final container = DIContainer();
      container.registerSingleton<String>(() => 'First', instanceName: 'first');
      container.registerSingleton<String>(
        () => 'Second',
        instanceName: 'second',
      );
      final first = container.get<String>(instanceName: 'first');
      final second = container.get<String>(instanceName: 'second');
      expect(first, equals('First'));
      expect(second, equals('Second'));
    });

    test('resets container', () async {
      final container = DIContainer();
      container.registerSingleton<String>(
        () => 'Hello',
        instanceName: 'test8a',
      );
      expect(container.isRegistered<String>(instanceName: 'test8a'), isTrue);
      await container.reset();
      // Reset clears all registrations
      expect(container.isRegistered<String>(instanceName: 'test8a'), isFalse);
    });

    test('works with dependencies', () {
      final container = DIContainer();
      container.registerSingleton<ServiceA>(
        () => ServiceA(),
        instanceName: 'test9a',
      );
      container.registerSingleton<ServiceB>(
        () => ServiceB(container.get<ServiceA>(instanceName: 'test9a')),
        instanceName: 'test9b',
      );
      final serviceB = container.get<ServiceB>(instanceName: 'test9b');
      expect(serviceB, isNotNull);
      expect(serviceB.serviceA, isNotNull);
    });

    test('supports lazy initialization', () {
      final container = DIContainer();
      final testObject = TestClass();
      container.registerSingleton<TestClass>(
        () => testObject,
        instanceName: 'lazy',
      );
      // Object is not created until first get
      final result = container.get<TestClass>(instanceName: 'lazy');
      expect(result, same(testObject));
    });
  });

  group('ServiceProvider', () {
    test('can be extended and used to register services', () {
      final provider = TestServiceProvider();
      final container = DIContainer();
      provider.register(container);
      final result = container.get<String>(instanceName: 'providerTest');
      expect(result, equals('Test Service'));
    });

    test('can boot after registration', () async {
      final provider = TestServiceProvider();
      final container = DIContainer();
      await provider.boot(container);
      expect(provider.booted, isTrue);
    });

    test('default boot implementation does nothing', () async {
      final provider = MinimalServiceProvider();
      final container = DIContainer();
      provider.register(container);
      // Should not throw - default boot() implementation is empty
      await provider.boot(container);
      expect(container.isRegistered<String>(instanceName: 'minimal'), isTrue);
    });
  });

  group('DIModule', () {
    test('can be created and used to register services', () {
      final container = DIContainer();
      final module = DIModuleExtension.create((c) {
        c.registerSingleton<String>(
          () => 'Module Service',
          instanceName: 'moduleTest',
        );
      });
      module.register(container);
      final result = container.get<String>(instanceName: 'moduleTest');
      expect(result, equals('Module Service'));
    });

    test('groups related service registrations', () {
      final container = DIContainer();
      final module = DIModuleExtension.create((c) {
        c.registerSingleton<String>(
          () => 'String from module',
          instanceName: 'moduleTest1',
        );
        c.registerSingleton<int>(() => 100, instanceName: 'moduleTest2');
      });
      module.register(container);
      expect(
        container.get<String>(instanceName: 'moduleTest1'),
        equals('String from module'),
      );
      expect(container.get<int>(instanceName: 'moduleTest2'), equals(100));
    });

    test('default providers() returns empty list', () {
      final module = TestModule();
      final providers = module.providers();
      expect(providers, isEmpty);
      expect(providers, isA<List<ServiceProvider>>());
    });
  });
}

class TestClass {
  final String value = 'test';
}

class ServiceA {
  String getValue() => 'ServiceA Value';
}

class ServiceB {
  final ServiceA serviceA;

  ServiceB(this.serviceA);
}

class TestServiceProvider extends ServiceProvider {
  bool booted = false;

  @override
  void register(DIContainer container) {
    container.registerSingleton<String>(
      () => 'Test Service',
      instanceName: 'providerTest',
    );
  }

  @override
  Future<void> boot(DIContainer container) async {
    booted = true;
  }
}

class MinimalServiceProvider extends ServiceProvider {
  @override
  void register(DIContainer container) {
    container.registerSingleton<String>(
      () => 'Minimal Service',
      instanceName: 'minimal',
    );
  }

  // Deliberately not overriding boot() to test default implementation
}

class TestModule extends DIModule {
  @override
  void register(DIContainer container) {
    container.registerSingleton<String>(
      () => 'Test Module',
      instanceName: 'testModule',
    );
  }

  // Deliberately not overriding providers() to test default implementation
}
