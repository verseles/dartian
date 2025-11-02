import 'package:dartian_di/dartian_di.dart';

class MyService {
  void doSomething() {
    print('MyService is doing something!');
  }
}

void main() {
  final container = Container();
  container.lazySingleton<MyService>(() => MyService());

  final myService = container.resolve<MyService>();
  myService.doSomething();
}
