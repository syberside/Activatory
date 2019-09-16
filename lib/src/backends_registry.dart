import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/aliases/type_alias_registry.dart';
import 'package:activatory/src/backend_store.dart';
import 'package:activatory/src/resolve_key.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/map_backend.dart';
import 'package:activatory/src/backends/recursion_limiter.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/customization/backend_resolver_factory.dart';
import 'package:activatory/src/customization/type_customization_registry.dart';
import 'package:activatory/src/params_object.dart';

class BackendsRegistry {
  BackendStore _store = new BackendStore();
  final BackendsFactory _factory;
  final TypeCustomizationRegistry _customizationsRegistry;
  final BackendResolverFactory _ctorResolveStrategyFactory;
  final TypeAliasesRegistry _aliasesRegistry;

  BackendsRegistry(
      this._factory, this._customizationsRegistry, this._ctorResolveStrategyFactory, this._aliasesRegistry);
  BackendsRegistry._fromStore(this._factory, this._customizationsRegistry, this._ctorResolveStrategyFactory,
      this._aliasesRegistry, this._store);

  BackendsRegistry clone() {
    var storeCopy = _store.clone();
    return new BackendsRegistry._fromStore(
        _factory, _customizationsRegistry, _ctorResolveStrategyFactory, _aliasesRegistry, storeCopy);
  }

  GeneratorBackend get(Type type, ActivationContext context) {
    Object key = context.key;
    if (context.key is Params) {
      key = key.runtimeType;
    }
    var affectedType = _aliasesRegistry.getAlias(type);
    var storeKey = new ResolveKey(affectedType, key);
    var backends = _store.find(storeKey);
    if (backends == null) {
      backends = _factory.create(affectedType);
      backends = backends.reversed.map((b) => register(b, affectedType, key: key)).toList();
      return get(affectedType, context);
    }

    var customization = _customizationsRegistry.get(affectedType, key: key);
    var ctorResolveStrategy = _ctorResolveStrategyFactory.get(customization.resolutionStrategy);
    var backend = ctorResolveStrategy.resolve(backends, context);
    return backend;
  }

  GeneratorBackend register(GeneratorBackend backend, Type type, {Object key}) {
    var wrapped = new RecursionLimiter(type, backend);
    _store.store(wrapped, new ResolveKey(type, key));
    return wrapped;
  }

  void registerArray<T>() => registerTyped(new ArrayBackend<T>());

  void registerMap<K, V>() => registerTyped(new MapBackend<K, V>());

  void registerTyped<T>(GeneratorBackend<T> backend, {Object key}) => register(backend, T, key: key);
}
