import 'package:get_it/get_it.dart';

class Container {
  final GetIt _getIt = GetIt.instance;

  void singleton<T extends Object>(T instance) {
    _getIt.registerSingleton<T>(instance);
  }

  void lazySingleton<T extends Object>(T Function() constructor) {
    _getIt.registerLazySingleton<T>(constructor);
  }

  void factory<T extends Object>(T Function() constructor) {
    _getIt.registerFactory<T>(constructor);
  }

  T resolve<T extends Object>() {
    return _getIt.get<T>();
  }

  void reset() {
    _getIt.reset();
  }
}
