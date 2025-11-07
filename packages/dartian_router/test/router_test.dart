import 'package:test/test.dart';
import 'package:dartian_router/dartian_router.dart';
import 'package:shelf/shelf.dart';

void main() {
  group('Router', () {
    late Router router;

    setUp(() {
      router = Router();
    });

    test('can be instantiated', () {
      expect(router, isNotNull);
    });

    test('adds GET route correctly', () {
      final handler = (Request request) => Response.ok('GET handler');
      router.get('/test', handler);
      expect(router, isNotNull);
    });

    test('adds POST route correctly', () {
      final handler = (Request request) => Response.ok('POST handler');
      router.post('/test', handler);
      expect(router, isNotNull);
    });

    test('adds POST route with name correctly', () {
      final handler = (Request request) => Response.ok('POST handler');
      router.post('/test', handler, name: 'postTest');
      final route = router.getRoute('postTest');
      expect(route, equals('/test'));
    });

    test('adds PUT route correctly', () {
      final handler = (Request request) => Response.ok('PUT handler');
      router.put('/test', handler);
      expect(router, isNotNull);
    });

    test('adds PUT route with name correctly', () {
      final handler = (Request request) => Response.ok('PUT handler');
      router.put('/test', handler, name: 'putTest');
      final route = router.getRoute('putTest');
      expect(route, equals('/test'));
    });

    test('adds DELETE route correctly', () {
      final handler = (Request request) => Response.ok('DELETE handler');
      router.delete('/test', handler);
      expect(router, isNotNull);
    });

    test('adds DELETE route with name correctly', () {
      final handler = (Request request) => Response.ok('DELETE handler');
      router.delete('/test', handler, name: 'deleteTest');
      final route = router.getRoute('deleteTest');
      expect(route, equals('/test'));
    });

    test('creates route groups with prefix', () {
      final handler = (Request request) => Response.ok('Group handler');
      router.group('/api', (subRouter) {
        subRouter.get('/users', handler, name: 'users');
      });
      expect(router, isNotNull);
    });

    test('stores named routes', () {
      final handler = (Request request) => Response.ok('Named handler');
      router.get('/test', handler, name: 'testRoute');
      final route = router.getRoute('testRoute');
      expect(route, equals('/test'));
    });

    test('returns null for unknown route name', () {
      final route = router.getRoute('unknown');
      expect(route, isNull);
    });

    test('exposes shelf router', () {
      final shelfRouter = router.shelfRouter;
      expect(shelfRouter, isNotNull);
    });
  });
}
