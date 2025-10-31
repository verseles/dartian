abstract class Event {}

abstract class Listener<T extends Event> {
  void handle(T event);
}
