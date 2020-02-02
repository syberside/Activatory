import 'dart:math';

abstract class ActivationContext {
  Object get key;

  Random get random;

  Object createUntyped(Type type);

  T create<T>();
}
