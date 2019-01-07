import 'dart:core';
import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/backends_registry.dart';
import 'package:activatory/src/generator.dart';
import 'package:activatory/src/value_generator.dart';

class Activatory {
  final Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  BackendsRegistry _backendsRegistry;
  _ActivatoryClosure _wrapper;

  Activatory(){
    _backendsRegistry = new BackendsRegistry(new BackendsFactory(_random));
    _wrapper = new _ActivatoryClosure(this);
  }

  Object get(Type type, {Object key}) {
    var ctx = _createContext(key);
    var backend = _backendsRegistry.get(type, ctx);
    var value = backend.get(ctx);
    return value;
  }

  ActivationCtx _createContext(Object key) => new ActivationCtx(_wrapper, _random, key);

  T getTyped<T>({Object key}) => get(T, key: key);

  void override<T>(Generator<T> generator, {Object key}) {
    var backend = new ExplicitBackend(generator);
    _backendsRegistry.registerTyped<T>(backend, key: key);
  }

  void pin<T>({Object key}) {
    var detachedContext = _backendsRegistry.clone();
    var context = _createContext(null);
    var currentBackend = detachedContext.get(T, context);
    var value = currentBackend.get(context);

    var backend = new SingletonBackend<T>(value);
    _backendsRegistry.registerTyped<T>(backend, key: key);
  }

  void pinValue<T>(T value, {Object key}) => override((ctx) => value, key: key);

  void registerArray<T>() => _backendsRegistry.registerArray<T>();
}

class _ActivatoryClosure implements ValueGenerator{
  final Activatory _wrapped;

  _ActivatoryClosure(this._wrapped);

  @override
  Object create(Type type, ActivationCtx context) {
    return _wrapped.get(type,key: context.key);
  }

  @override
  T createTyped<T>(ActivationCtx context) {
    return _wrapped.getTyped<T>(key: context.key);
  }
}