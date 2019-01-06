import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/backend_store_key.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class BackendStore{
  Map<BackendStoreKey, GeneratorBackend> _backends = new Map<BackendStoreKey, GeneratorBackend>();

  BackendStore();
  BackendStore._fromMap(this._backends);


  void store(GeneratorBackend backend, BackendStoreKey key){
    _backends[key] = backend;
  }

  GeneratorBackend find(BackendStoreKey key){
    return _backends[key];
  }

  BackendStore clone() {
    var copy = new BackendStore._fromMap(_backends);
    return copy;
  }
}