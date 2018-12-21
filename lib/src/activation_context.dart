import 'package:activatory/src/backends/complex_object_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class ActivationContext {
  Map<Type, GeneratorBackend> _exactBackends =
      new Map<Type, GeneratorBackend>();

  GeneratorBackend get(Type type){
    var backend = find(type);
    if (backend == null) {
      throw new Exception("Backend of type ${type} not found");
    }
    return backend;
  }

  GeneratorBackend find(Type type) {
    var result = _exactBackends[type];
    if (result != null) {
      return result;
    }
    var complexObjectBackend = new ComplexObjectBackend(type);
    register(type, complexObjectBackend);
    return complexObjectBackend;
  }

  void register(Type type, GeneratorBackend backend) {
    _exactBackends[type] = backend;
  }

  void registerAll(Map<Type, GeneratorBackend> backends) {
    backends.forEach((type, backend) => register(type, backend));
  }
}
