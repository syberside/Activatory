import 'dart:core';
import 'package:activatory/src/activation_context_factory.dart';
import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';

typedef T Generator<T>(ActivationContext activatory);

class Activatory {
  ActivationContext _context;
  Activatory() {
    _context = ActivationContextFactory.createDefault();
  }

  //TODO: Test key
  T getTyped<T>({Object key}) => get(T, key: key);

  Object get(Type type, {Object key}) {
    var backend = _context.get(type, key: key);
    var value = backend.get(_context);
    return value;
  }

  //TODO: Test
  void override<T>(Generator<T> generator, {Object key}){
    var backend = new ExplicitBackend(generator);
    _context.register(backend, T, key: key);
  }

  void useSingleton(Type type) {
    //TODO: support key and rename to define?

    //TODO: BAD practice - unexpected state mutation + black magic
    var currentBackend = _context.get(type);
    var value = currentBackend.get(_context);

    var backend = new SingletonBackend(value);
    _context.register(backend, type);
  }

  void useValue<T>(T value, {Object key})=> override((ctx) => value, key: key);
}
