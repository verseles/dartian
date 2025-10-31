import 'package:dartian_di/dartian_di.dart';
import 'package:test/test.dart';

void main() {
  group('Container', () {
    late Container container;

    setUp(() {
      container = Container();
    });

    tearDown(() {
      container.reset();
    });

    test('registers and resolves a singleton', () {
      final instance = MyService();
      container.singleton<MyService>(instance);
      final resolved = container.resolve<MyService>();
      expect(resolved, same(instance));
    });

    test('registers and resolves a lazy singleton', () {
      container.lazySingleton<MyService>(() => MyService());
      final resolved1 = container.resolve<MyService>();
      final resolved2 = container.resolve<MyService>();
      expect(resolved1, same(resolved2));
    });

    test('registers and resolves a factory', () {
      container.factory<MyService>(() => MyService());
      final resolved1 = container.resolve<MyService>();
      final resolved2 = container.resolve<MyService>();
      expect(resolved1, isNot(same(resolved2)));
    });
  });

  group('ServiceProvider', () {
    late Container container;

    setUp(() {
      container = Container();
    });

    tearDown(() {
      container.reset();
    });

    test('registers services', () {
      final provider = MyServiceProvider();
      provider.register(container);
      final resolved = container.resolve<MyService>();
      expect(resolved, isA<MyService>());
    });

    test('boots services', () {
      final provider = MyServiceProvider();
      provider.register(container);
      provider.boot(container);
      final resolved = container.resolve<MyService>();
      expect(resolved.isBooted, isTrue);
    });
  });
}

class MyService {
  bool isBooted = false;
}

class MyServiceProvider extends ServiceProvider {
  @override
  void register(Container container) {
    container.lazySingleton<MyService>(() => MyService());
  }

  @override
  void boot(Container container) {
    final myService = container.resolve<MyService>();
    myService.isBooted = true;
  }
}
