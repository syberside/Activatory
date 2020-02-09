import 'dart:core';
import 'dart:math';

import 'package:activatory/src/customization/factory-resolving/factory_resolver_factory.dart';
import 'package:activatory/src/customization/type_customization.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/factories-registry/factories_provider.dart';
import 'package:activatory/src/factories-registry/factories_registry.dart';
import 'package:activatory/src/factories-registry/factories_store.dart';
import 'package:activatory/src/factories/explicit/explicit_factory.dart';
import 'package:activatory/src/factories/explicit/factory_delegate.dart';
import 'package:activatory/src/factories/singleton_factory.dart';
import 'package:activatory/src/internal_activation_context.dart';
import 'package:activatory/src/post-activation/reflective_fields_filler.dart';
import 'package:activatory/src/type-aliasing/reflective_type_alias_registry.dart';
import 'package:activatory/src/value_generator.dart';

class Activatory {
  final Random _random = new Random(DateTime.now().millisecondsSinceEpoch);
  ValueGenerator _valueGenerator;
  FactoriesRegistry _factoriesRegistry;
  TypeCustomizationRegistry _customizationsRegistry;
  FactoryResolverFactory _backendResolverFactory;
  ReflectiveTypeAliasesRegistry _typeAliasesRegistry;

  Activatory() {
    _typeAliasesRegistry = new ReflectiveTypeAliasesRegistry();
    _customizationsRegistry = new TypeCustomizationRegistry();
    _backendResolverFactory = new FactoryResolverFactory(_random);
    final factoriesProvider = new FactoriesProvider(_random);
    final factoriesStore = new FactoriesStore();
    _factoriesRegistry = new FactoriesRegistry(
      factoriesProvider,
      _customizationsRegistry,
      _backendResolverFactory,
      _typeAliasesRegistry,
      factoriesStore,
    );
    final fieldsFiller = new ReflectiveFieldsFiller();
    _valueGenerator = new ValueGenerator(_factoriesRegistry, fieldsFiller);
  }

  // region Activation members

  /// Creates and returns instance of specified type [T] filled with random data recursively.
  /// Uses [key] to select configuration.
  T get<T>({Object key}) => getUntyped(T, key: key) as T;

  /// Creates and returns instance of specified [type] filled with random data recursively.
  /// Uses [key] to select configuration.
  Object getUntyped(Type type, {Object key}) {
    final context = _createContext(key);
    return _valueGenerator.createUntyped(type, context);
  }

  /// Creates and returns multiple instances of specified [type] filled with random data recursively.
  /// Returns [List] of size [count]. If [count] is not specified default strategy will be used.
  /// Uses [key] to select configuration.
  List<Object> getManyUntyped(Type type, {int count, Object key}) {
    final countToCreate = count ?? _customizationsRegistry.getCustomization(type, key: key).arraySize;
    return List.generate(countToCreate, (int index) => getUntyped(type, key: key));
  }

  /// Creates and returns multiple instances of specified type [T] filled with random data recursively.
  /// Returns [List] of size [count]. If [count] is not specified default strategy will be used.
  /// Uses [key] to select configuration.
  List<T> getMany<T>({int count, Object key}) {
    final dynamicResult = getManyUntyped(T, count: count, key: key);
    //Cast result from List<dynamic> to List<T> through array creation
    return new List<T>.from(dynamicResult);
  }

  /// Returns random item from iterable. [variations] value will be iterated while choosing item.
  Object takeUntyped(Iterable variations) {
    final items = variations.toList();
    final index = _random.nextInt(items.length);
    return items[index];
  }

  /// Returns random item from iterable.  [variations] value will be iterated while choosing item.
  T take<T>(Iterable<T> variations) => takeUntyped(variations) as T;

  /// Returns random items from iterable. [variations] value will be iterated while choosing item.
  List<Object> takeManyUntyped(int count, Iterable variations) => List.generate(count, (_) => takeUntyped(variations));

  /// Returns random items from iterable.  [variations] value will be iterated while choosing item.
  List<T> takeMany<T>(int count, Iterable<T> variations) {
    final dynamicResult = takeManyUntyped(count, variations);
    //Cast result from List<dynamic> to List<T> through array creation
    return new List<T>.from(dynamicResult);
  }

  // endregion

  // region Customization members

  /// Registers function to be called to activate instance of type [T] with [key].
  void useFunction<T>(FactoryDelegate<T> generator, {Object key}) {
    final backend = new ExplicitFactory<T>(generator);
    _factoriesRegistry.register<T>(backend, key: key);
  }

  /// Creates instance of type [T] and fixes it as a result for subsequent activation calls for type [T] with customization [key].
  ///
  /// Uses current state of customization for [key]. Subsequent customization changes will not affect fixed value.
  /// To override fixed value call this method again.
  void useGeneratedSingleton<T>({Object key}) {
    final detachedContext = _factoriesRegistry.clone();
    final context = _createContext(null);
    final currentFactory = detachedContext.getFactory(T, context.key);
    final value = currentFactory.get(context) as T;

    useSingleton<T>(value, key: key);
  }

  /// Fixes passed [value] as a result for subsequent activation calls for type [T] with customization [key].
  void useSingleton<T>(T value, {Object key}) {
    final factory = new SingletonFactory<T>(value);
    _factoriesRegistry.register<T>(factory, key: key);
  }

  /// Marks [TTarget] as replacement for [TSource] activation calls.
  ///
  /// Allows to use [TTarget] type as activation target for [TSource] activation.
  /// [TTarget] should implements [TSource].
  void replaceSupperClass<TSource, TTarget extends TSource>() => _typeAliasesRegistry.setAlias(TSource, TTarget);

  /// Returns default customization which is used to activate not customized object types.
  /// Use returned value to customize default activation options.
  TypeCustomization get defaultCustomization => _customizationsRegistry.getCustomization(null, key: null);

  /// Returns customization for specified type [T] and [key].
  /// If [key] is not specified type default configuration will be returned.
  /// Type default configuration is used while activation in next cases:
  ///  * if key is not provided as parameter for activation call;
  ///  * if key specified while activation call was not configured.
  ///  Use returned value to customize activation options for type [T] and [key] pair.
  TypeCustomization customize<T>({Object key}) => _customizationsRegistry.getCustomization(T, key: key);

  //endregion

  InternalActivationContext _createContext(Object key) =>
      new InternalActivationContext(_valueGenerator, _random, key, _customizationsRegistry);
}
