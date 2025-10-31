import 'package:shelf/shelf.dart';
import 'package:dartian_i18n/src/translator.dart';

Middleware createLocaleMiddleware(Translator translator) {
  return (Handler innerHandler) {
    return (Request request) {
      final lang = request.url.queryParameters['lang'];
      if (lang != null) {
        translator.setLocale(lang);
      }
      return innerHandler(request);
    };
  };
}
