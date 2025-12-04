import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
    test('throw_if', () {
        expect(() => throw_if(true, Exception('e')), throwsException);
        expect(() => throw_if(false, Exception('e')), returnsNormally);
    });

    test('throw_unless', () {
        expect(() => throw_unless(false, Exception('e')), throwsException);
        expect(() => throw_unless(true, Exception('e')), returnsNormally);
    });

    test('rescue', () {
        expect(rescue(() => 1), 1);
        expect(rescue(() => throw Exception('e'), null, false), null); // report=false to avoid App.report hook error if any
        expect(rescue(() => throw Exception('e'), (e) => 'rescued', false), 'rescued');
    });

    test('transform', () {
        expect(transform(1, (v) => v * 2), 2);
        expect(transform(null, (v) => v * 2, 'default'), 'default');
    });

    test('once', () {
        int count = 0;
        final f = once(() => ++count);
        expect(f(), 1);
        expect(f(), 1);
        expect(count, 1);
    });
}
