import 'dart:core';
import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/params_object_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/backends_registry.dart';
import 'package:activatory/src/generator_delegate.dart';
import 'package:activatory/src/params_object.dart';
import 'package:activatory/src/value_generator.dart';

class Activatory {
  final Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  ValueGeneratorImpl _valueGenerator;
  BackendsRegistry _backendsRegistry;

  Activatory(){
    _backendsRegistry = new BackendsRegistry(new BackendsFactory(_random));
    _valueGenerator = new ValueGeneratorImpl(_backendsRegistry);
  }

  Object get(Type type, [Object key = null]) {
    var context = _createContext(key);
    return _valueGenerator.create(type, context);
  }

  ActivationContext _createContext(Object key) => new ActivationContext(_valueGenerator, _random, key);

  T getTyped<T>([Object key = null]) => get(T, key);

  void override<T>(GeneratorDelegate<T> generator, {Object key}) {
    var backend = new ExplicitBackend<T>(generator);
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

  void pinValue<T>(T value, {Object key}) {
    var backend = new SingletonBackend<T>(value);
    _backendsRegistry.registerTyped<T>(backend, key: key);
  }

  void registerArray<T>() => _backendsRegistry.registerArray<T>();

  void useParamsObject<TValue, TParamsObj extends ParamsObject<TValue>>() {
    var backend = new ParamsObjectBackend<TValue>();
    _backendsRegistry.registerTyped<TValue>(backend, key: TParamsObj);
  }
}

class ValueGeneratorImpl implements ValueGenerator{
  BackendsRegistry _backendsRegistry;

  ValueGeneratorImpl(this._backendsRegistry);

  @override
  Object create(Type type, ActivationContext context) {
    var backend = _backendsRegistry.get(type, context);
    var value = backend.get(context);
    return value;
  }

  @override
  T createTyped<T>(ActivationContext context) => create(T, context);
}