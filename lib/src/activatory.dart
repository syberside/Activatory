import 'dart:core';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/activation_context_factory.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';
import 'package:activatory/src/generator.dart';

class Activatory {
  ActivationContext _context;
  ActivationContextFactory _factory;

  Activatory() : this.custom(new ActivationContextFactory());

  Activatory.custom(this._factory, [this._context]) {
    if (_context == null) {
      _context = _factory.createDefault();
    }
  }

  Object get(Type type, {Object key}) {
    var backend = _context.get(type, key: key);
    var value = backend.get(_context);
    return value;
  }

  T getTyped<T>({Object key}) => get(T, key: key);

  void override<T>(Generator<T> generator, {Object key}) {
    var backend = new ExplicitBackend(generator);
    _context.register(backend, T, key: key);
  }

  void pin(Type type, {Object key}) {
    var detachedContext = _context.clone();
    var currentBackend = detachedContext.get(type, key: null);
    var value = currentBackend.get(detachedContext);

    var backend = new SingletonBackend(value);
    _context.register(backend, type, key: key);
  }

  void pinValue<T>(T value, {Object key}) => override((ctx) => value, key: key);

  void registerArray<T>() => _context.registerArray<T>();
}
