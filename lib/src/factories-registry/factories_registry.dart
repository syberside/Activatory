import 'package:activatory/src/customization/factory-resolving/factory_resolver_factory.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/factories-registry/factories_factory.dart';
import 'package:activatory/src/factories-registry/factories_store.dart';
import 'package:activatory/src/factories-registry/resolve_key.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/wrappers/recursion_limiter.dart';
import 'package:activatory/src/type-aliasing/reflective_type_alias_registry.dart';

class FactoriesRegistry {
  final FactoriesStore _store;
  final FactoriesFactory _factory;
  final TypeCustomizationRegistry _customizationsRegistry;
  final FactoryResolverFactory _ctorResolveStrategyFactory;
  final ReflectiveTypeAliasesRegistry _aliasesRegistry;

  FactoriesRegistry(
    this._factory,
    this._customizationsRegistry,
    this._ctorResolveStrategyFactory,
    this._aliasesRegistry,
    this._store,
  );

  FactoriesRegistry clone() {
    final storeCopy = _store.clone();
    return new FactoriesRegistry(
      _factory,
      _customizationsRegistry,
      _ctorResolveStrategyFactory,
      _aliasesRegistry,
      storeCopy,
    );
  }

  Factory getFactory(Type type, Object key) {
    final affectedType = _aliasesRegistry.getAlias(type);
    final storeKey = new ResolveKey(affectedType, key);
    var factories = _store.find(storeKey);
    if (factories != null) {
      final customization = _customizationsRegistry.getCustomization(affectedType, key: key);
      final ctorResolveStrategy = _ctorResolveStrategyFactory.getResolver(customization.resolvingStrategy);
      final backend = ctorResolveStrategy.resolve(factories);
      return backend;
    }

    factories = _factory.create(affectedType);
    for (final factory in factories.reversed) {
      _registerUntyped(factory, affectedType, key: key);
    }
    return getFactory(affectedType, key);
  }

  void _registerUntyped(Factory backend, Type type, {Object key}) {
    final wrapped = new RecursionLimiter(type, backend);
    final resolveKey = new ResolveKey(type, key);
    _store.store(wrapped, resolveKey);
  }

  void register<T>(Factory<T> backend, {Object key}) => _registerUntyped(backend, T, key: key);
}
