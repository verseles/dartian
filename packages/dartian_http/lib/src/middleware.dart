import 'package:shelf/shelf.dart';
import 'package:dartian_i18n/dartian_i18n.dart';

/// Middleware for internationalization
Middleware i18nMiddleware({String defaultLocale = 'en'}) {
  return (Handler handler) {
    return (Request request) async {
      // Initialize i18n if not already done
      i18n.init(defaultLocale: defaultLocale);

      // Detect locale from Accept-Language header
      final acceptLanguage = request.headers['Accept-Language'];
      final detectedLocale = I18nUtils.detectFromHeader(acceptLanguage);

      if (detectedLocale != null) {
        i18n.setLocale(detectedLocale);
      }

      // Call next handler
      return await handler(request);
    };
  };
}
