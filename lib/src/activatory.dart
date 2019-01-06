import 'dart:core';
import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/generator.dart';

class Activatory {
  ActivationContext _context = new ActivationContext(new BackendsFactory(new Random()));

  Object get(Type type, {Object key}) {
    var backend = _context.get(type, key: key);
    var value = backend.get(_context);
    return value;
  }

  T getTyped<T>({Object key}) => get(T, key: key);

  void override<T>(Generator<T> generator, {Object key}) {
    var backend = new ExplicitBackend(generator);
    _context.registerTyped<T>(backend, key: key);
  }

  void pin<T>({Object key}) {
    var detachedContext = _context.clone();
    var currentBackend = detachedContext.get(T, key: null);
    var value = currentBackend.get(detachedContext);

    var backend = new SingletonBackend<T>(value);
    _context.registerTyped<T>(backend, key: key);
  }

  void pinValue<T>(T value, {Object key}) => override((ctx) => value, key: key);

  void registerArray<T>() => _context.registerArray<T>();
}
