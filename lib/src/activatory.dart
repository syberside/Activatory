import 'dart:core';
import 'dart:math';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/aliases/type_alias_registry.dart';
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
import 'package:activatory/src/post_activation/fields_filler.dart';
import 'package:activatory/src/type_helper.dart';
import 'package:activatory/src/value_generator_impl.dart';

class Activatory {
  final Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  ValueGeneratorImpl _valueGenerator;
  BackendsRegistry _backendsRegistry;
  TypeCustomizationRegistry _customizationsRegistry;
  BackendResolverFactory _backendResolverFactory;
  TypeAliasesRegistry _aliasesRegistry;

  Activatory() {
    _aliasesRegistry = new TypeAliasesRegistry();
    _customizationsRegistry = new TypeCustomizationRegistry();
    _backendResolverFactory = new BackendResolverFactory(_random);
    var backendsFactory = new BackendsFactory(_random);
    _backendsRegistry = new BackendsRegistry(backendsFactory, _customizationsRegistry, _backendResolverFactory, _aliasesRegistry);
    _valueGenerator = new ValueGeneratorImpl(_backendsRegistry, new FieldsFiller());
  }

  TypeCustomization get defaultCustomization => _customizationsRegistry.get(null, key: null);

  TypeCustomization customize<T>({Object key = null}) => _customizationsRegistry.get(T, key: key);

  Object get(Type type, [Object key = null]) {
    var context = _createContext(key);
    return _valueGenerator.create(type, context);
  }

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

  void registerArray<T>({bool addIterableAlias=true}) {
    if(addIterableAlias){
      _aliasesRegistry.putIfAbsent(getType<Iterable<T>>(), getType<List<T>>());
    }
    _backendsRegistry.registerArray<T>();
  }

  void registerMap<K, V>() => _backendsRegistry.registerMap<K, V>();

  void useParamsObject<TValue, TParamsObj extends Params<TValue>>() {
    var backend = new ParamsObjectBackend<TValue>();
    _backendsRegistry.registerTyped<TValue>(backend, key: TParamsObj);
  }

  ActivationContext _createContext(Object key) =>
      new ActivationContext(_valueGenerator, _random, key, _customizationsRegistry);

  List<T> getManyTyped<T>({int count, Object key}) {
    var dynamicResult = getMany(T,count: count, key: key);
    //Cast result from List<dynamic> to List<T> through array creation
    return new List<T>.from(dynamicResult);
  }

  List getMany(Type type, {int count, Object key}){
    var countToCreate = count ?? _customizationsRegistry.get(type, key: key).arraySize;
    return List.generate(countToCreate, (int index)=>get(type, key));
  }

  void registerAlias<TSource, TTarget  extends TSource>() {
    _aliasesRegistry.setAlias(TSource, TTarget);
  }
}
