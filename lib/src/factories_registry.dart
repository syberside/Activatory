import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/aliases/type_alias_registry.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/customization/backend_resolver_factory.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/recursion_limiter.dart';
import 'package:activatory/src/factories_store.dart';
import 'package:activatory/src/resolve_key.dart';

class FactoriesRegistry {
  final FactoriesStore _store;
  final BackendsFactory _factory;
  final TypeCustomizationRegistry _customizationsRegistry;
  final BackendResolverFactory _ctorResolveStrategyFactory;
  final TypeAliasesRegistry _aliasesRegistry;

  FactoriesRegistry(
    this._factory,
    this._customizationsRegistry,
    this._ctorResolveStrategyFactory,
    this._aliasesRegistry,
    this._store,
  );

  FactoriesRegistry clone() {
    var storeCopy = _store.clone();
    return new FactoriesRegistry(
        _factory, _customizationsRegistry, _ctorResolveStrategyFactory, _aliasesRegistry, storeCopy);
  }

  Factory get(Type type, ActivationContext context) {
    Object key = context.key;
    var affectedType = _aliasesRegistry.getAlias(type);
    var storeKey = new ResolveKey(affectedType, key);
    var backends = _store.find(storeKey);
    if (backends == null) {
      backends = _factory.create(affectedType, context);
      backends = backends.reversed.map((b) => register(b, affectedType, key: key)).toList();
      return get(affectedType, context);
    }

    var customization = _customizationsRegistry.get(affectedType, key: key);
    var ctorResolveStrategy = _ctorResolveStrategyFactory.get(customization.resolutionStrategy);
    var backend = ctorResolveStrategy.resolve(backends, context);
    return backend;
  }

  Factory register(Factory backend, Type type, {Object key}) {
    var wrapped = new RecursionLimiter(type, backend);
    _store.store(wrapped, new ResolveKey(type, key));
    return wrapped;
  }

  void registerTyped<T>(Factory<T> backend, {Object key}) => register(backend, T, key: key);
}
