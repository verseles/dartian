import 'package:dartian_core/src/support/str.dart';
import 'package:test/test.dart';

void main() {
  group('Str', () {
    test('camel', () {
      expect(Str.camel('foo_bar'), 'fooBar');
      expect(Str.camel('Foo_bar'), 'fooBar');
      expect(Str.camel('foo-bar'), 'fooBar');
    });

    test('snake', () {
      expect(Str.snake('fooBar'), 'foo_bar');
      expect(Str.snake('fooBar', '-'), 'foo-bar');
      expect(Str.snake('FooBar'), 'foo_bar');
    });

    test('studly', () {
      expect(Str.studly('foo_bar'), 'FooBar');
      expect(Str.studly('foo-bar'), 'FooBar');
    });

    test('kebab', () {
      expect(Str.kebab('fooBar'), 'foo-bar');
    });

    test('title', () {
      expect(Str.title('foo_bar'), 'Foo Bar');
      expect(Str.title('foo-bar'), 'Foo Bar');
    });

    test('ucfirst', () {
      expect(Str.ucfirst('foo'), 'Foo');
    });

    test('lcfirst', () {
      expect(Str.lcfirst('Foo'), 'foo');
    });

    test('limit', () {
      expect(Str.limit('The quick brown fox', 10), 'The quick ...');
      expect(Str.limit('The quick brown fox', 20), 'The quick brown fox');
    });

    test('words', () {
      expect(Str.words('The quick brown fox', 2), 'The quick...');
      expect(Str.words('The quick brown fox', 5), 'The quick brown fox');
    });

    test('contains', () {
      expect(Str.contains('This is a test', 'test'), isTrue);
      expect(Str.contains('This is a test', ['sample', 'test']), isTrue);
      expect(Str.contains('This is a test', ['sample', 'demo']), isFalse);
    });

    test('startsWith', () {
      expect(Str.startsWith('This is a test', 'This'), isTrue);
      expect(Str.startsWith('This is a test', ['That', 'This']), isTrue);
    });

    test('endsWith', () {
      expect(Str.endsWith('This is a test', 'test'), isTrue);
      expect(Str.endsWith('This is a test', ['test', 'case']), isTrue);
    });

    test('slug', () {
      expect(Str.slug('Hello World'), 'hello-world');
      expect(Str.slug('Hello World', '_'), 'hello_world');
      expect(Str.slug('User @ Name'), 'user-name');
    });

    test('random', () {
      expect(Str.random(10).length, 10);
      expect(Str.random(16).length, 16);
      expect(Str.random(10), isNot(equals(Str.random(10))));
    });

    test('uuid', () {
      final uuid = Str.uuid();
      expect(uuid.length, 36);
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(uuid),
        isTrue,
      );
    });

    test('replaceArray', () {
      expect(
        Str.replaceArray('Hello ? ?', '?', ['World', 'Universe']),
        'Hello World Universe',
      );
    });

    test('replaceFirst', () {
      expect(
        Str.replaceFirst('the', 'a', 'the quick brown fox the'),
        'a quick brown fox the',
      );
    });

    test('replaceLast', () {
      expect(
        Str.replaceLast('the', 'a', 'the quick brown fox the'),
        'the quick brown fox a',
      );
    });

    test('before', () {
      expect(Str.before('This is a test', 'is'), 'Th');
      expect(Str.before('This is a test', 'xyz'), 'This is a test');
    });

    test('after', () {
      expect(Str.after('This is a test', 'is'), ' is a test');
      expect(Str.after('This is a test', 'xyz'), 'This is a test');
    });

    test('between', () {
      expect(Str.between('This is a test', 'This', 'test'), ' is a ');
    });

    test('wrap', () {
      expect(Str.wrap('test', '"'), '"test"');
      expect(Str.wrap('test', '<', '>'), '<test>');
    });

    test('unwrap', () {
      expect(Str.unwrap('"test"', '"'), 'test');
      expect(Str.unwrap('<test>', '<', '>'), 'test');
    });
  });
}
