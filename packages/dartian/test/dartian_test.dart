import 'package:test/test.dart';
import 'package:dartian/dartian.dart';
import 'package:dartian/http.dart' as http;

void main() {
  group('Dartian umbrella package', () {
    test('exports core (TelemetryHooks)', () {
      expect(TelemetryHooks, isNotNull);
    });

    test('exports router (Router)', () {
      final router = Router();
      expect(router, isNotNull);
    });

    test('exports DI (DIContainer)', () {
      final container = DIContainer();
      expect(container, isNotNull);
    });

    test('exports http (HttpKernel)', () {
      final kernel = http.HttpKernel();
      expect(kernel, isNotNull);
    });
  });
}
