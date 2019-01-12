import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backend_store.dart';
import 'package:activatory/src/backend_store_key.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/recurrency_limiter.dart';
import 'package:activatory/src/backends_factory.dart';
import 'package:activatory/src/params_object.dart';

class BackendsRegistry {

  BackendStore _store = new BackendStore();
  final BackendsFactory _factory;

  BackendsRegistry(this._factory);
  BackendsRegistry._fromStore(this._factory, this._store);

  BackendsRegistry clone() {
    var storeCopy = _store.clone();
    return new BackendsRegistry._fromStore(_factory, storeCopy);
  }

  GeneratorBackend get(Type type, ActivationContext context) {
    Object key = context.key;
    if(context.key is Params){
      key = key.runtimeType;
    }
    var backend = _store.find(new BackendStoreKey(type, key));
    if(backend == null){
      backend = _factory.create(type);
      backend = register(backend, type, key: key);
    }
    return backend;
  }

  GeneratorBackend register(GeneratorBackend backend, Type type, {Object key}) {
    var wrapped = new RecurrencyLimiter(type, backend);
    _store.store(wrapped, new BackendStoreKey(type, key));
    return wrapped;
  }

  void registerArray<T>() => registerTyped(new ArrayBackend<T>());

  void registerTyped<T>(GeneratorBackend<T> backend, {Object key}) => register(backend, T, key: key);
}