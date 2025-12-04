import 'package:dartian_core/dartian_core.dart';
import 'package:test/test.dart';

void main() {
  test('URLs', () {
    UrlGenerator.toCallback = (path, [params, secure]) =>
        'http://localhost/$path';
    expect(url('home'), 'http://localhost/home');
    expect(
      secure_url('home'),
      'http://localhost/home',
    ); // Mock doesn't handle secure param in return value

    UrlGenerator.routeCallback = (name, [params, absolute]) =>
        'http://localhost/$name';
    expect(route('home'), 'http://localhost/home');

    UrlGenerator.assetCallback = (path, [secure]) =>
        'http://localhost/assets/$path';
    expect(asset('img.png'), 'http://localhost/assets/img.png');
  });
}
