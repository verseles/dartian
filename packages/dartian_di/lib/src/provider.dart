import 'container.dart';

abstract class ServiceProvider {
  void register(Container container);
  void boot(Container container) {}
}
