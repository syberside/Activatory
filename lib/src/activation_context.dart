import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/backend_store.dart';
import 'package:activatory/src/backend_store_key.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends_factory.dart';

class ActivationContext {

  BackendStore _store = new BackendStore();
  final BackendsFactory _factory;

  ActivationContext(this._factory);
  ActivationContext._fromStore(this._factory, this._store);

  ActivationContext clone() {
    var storeCopy = _store.clone();
    return new ActivationContext._fromStore(_factory, storeCopy);
  }

  GeneratorBackend find(Type type, {Object key}) {
    var result = _store.find(new BackendStoreKey(type, key));
    if(result != null){
      return result;
    }

    var newBackend = _factory.create(type);

    register(newBackend, type, key: key);
    return newBackend;
  }

  GeneratorBackend get(Type type, {Object key}) {
    var backend = find(type, key: key);
    if (backend == null) {
      throw new ActivationException("Backend of type ${type} with key ${key} not found");
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