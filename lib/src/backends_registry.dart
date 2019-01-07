import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/backend_store.dart';
import 'package:activatory/src/backend_store_key.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends_factory.dart';

class BackendsRegistry {

  BackendStore _store = new BackendStore();
  final BackendsFactory _factory;

  BackendsRegistry(this._factory);
  BackendsRegistry._fromStore(this._factory, this._store);

  BackendsRegistry clone() {
    var storeCopy = _store.clone();
    return new BackendsRegistry._fromStore(_factory, storeCopy);
  }

  GeneratorBackend _findOrCreate(Type type, ActivationCtx context) {
    var result = _store.find(new BackendStoreKey(type, context.key));
    if(result != null){
      return result;
    }

    var newBackend = _factory.create(type);

    register(newBackend, type, key: context.key);
    return newBackend;
  }

  GeneratorBackend get(Type type, ActivationCtx context) {
    var backend = _findOrCreate(type, context);
    if (backend == null) {
      throw new ActivationException("Backend of type ${type} with key ${context.key} not found");
    }
    return backend;
  }

  void register(GeneratorBackend backend, Type type, {Object key}) {
    _store.store(backend, new BackendStoreKey(type, key));
  }

  void registerArray<T>() {
    registerTyped(new ArrayBackend<T>());
  }

  void registerTyped<T>(GeneratorBackend<T> backend, {Object key}) => register(backend, T, key: key);
}