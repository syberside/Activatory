import 'dart:core';
import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/explicit_backend.dart';
import 'package:activatory/src/backends/params_object_backend.dart';
import 'package:activatory/src/backends/singleton_backend.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/backends_registry.dart';
import 'package:activatory/src/customization/backend_resolver_factory.dart';
import 'package:activatory/src/customization/type_customization.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/generator_delegate.dart';
import 'package:activatory/src/params_object.dart';
import 'package:activatory/src/value_generator_impl.dart';

class Activatory {
  final Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  ValueGeneratorImpl _valueGenerator;
  BackendsRegistry _backendsRegistry;
  TypeCustomizationRegistry _customizationsRegistry;
  BackendResolverFactory _ctorResolveStrategyFactory;

  Activatory(){
    _customizationsRegistry = new TypeCustomizationRegistry();
    _ctorResolveStrategyFactory = new BackendResolverFactory(_random);
    _backendsRegistry = new BackendsRegistry(new BackendsFactory(_random), _customizationsRegistry, _ctorResolveStrategyFactory);
    _valueGenerator = new ValueGeneratorImpl(_backendsRegistry);
  }

  TypeCustomization get defaultCustomization => _customizationsRegistry.get(null);

  Object get(Type type, [Object key = null]) {
    var context = _createContext(key);
    return _valueGenerator.create(type, context);
  }

  ActivationContext _createContext(Object key) => new ActivationContext(_valueGenerator, _random, key, _customizationsRegistry);

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

  void useParamsObject<TValue, TParamsObj extends Params<TValue>>() {
    var backend = new ParamsObjectBackend<TValue>();
    _backendsRegistry.registerTyped<TValue>(backend, key: TParamsObj);
  }

  TypeCustomization customize<T>() => _customizationsRegistry.get(T);
}