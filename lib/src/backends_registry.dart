import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backend_store.dart';
import 'package:activatory/src/backend_store_key.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
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

  BackendsRegistry(this._factory, this._customizationsRegistry, this._ctorResolveStrategyFactory);
  BackendsRegistry._fromStore(this._factory, this._customizationsRegistry, this._ctorResolveStrategyFactory, this._store);

  BackendsRegistry clone() {
    var storeCopy = _store.clone();
    return new BackendsRegistry._fromStore(_factory, _customizationsRegistry, _ctorResolveStrategyFactory, storeCopy);
  }

  GeneratorBackend get(Type type, ActivationContext context) {
    Object key = context.key;
    if(context.key is Params){
      key = key.runtimeType;
    }
    var backends = _store.find(new BackendStoreKey(type, key));
    if(backends == null){
      backends = _factory.create(type);
      backends = backends.reversed.map((b)=>register(b, type, key: key)).toList();
      return get(type, context);
    }

    var customization = _customizationsRegistry.get(type);
    var ctorResolveStrategy = _ctorResolveStrategyFactory.get(customization.resolutionStrategy);
    var backend = ctorResolveStrategy.resolve(backends, context);
    return backend;
  }

  GeneratorBackend register(GeneratorBackend backend, Type type, {Object key}) {
    var wrapped = new RecursionLimiter(type, backend);
    _store.store(wrapped, new BackendStoreKey(type, key));
    return wrapped;
  }

  void registerArray<T>() => registerTyped(new ArrayBackend<T>());

  void registerTyped<T>(GeneratorBackend<T> backend, {Object key}) => register(backend, T, key: key);
}