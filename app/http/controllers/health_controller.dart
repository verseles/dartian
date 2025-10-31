import 'package:dartian_http/dartian_http.dart';

class HealthController {
  Future<DartianResponse> health() async {
    return DartianResponse.ok('OK');
  }
}
