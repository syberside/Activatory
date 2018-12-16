import 'dart:math';
import 'package:Activatory/src/backends/complex_object_backend.dart';
import 'package:Activatory/src/backends/generator_backend.dart';
import 'package:Activatory/src/backends/primitive_random_backends.dart';

class ActivationContext {
  Map<Type, GeneratorBackend> _exactBackends =
      new Map<Type, GeneratorBackend>();

  GeneratorBackend find(Type type) {
    var result = _exactBackends[type];
    if (result != null) {
      return result;
    }
    var complexObjectBackend = new ComplexObjectBackend(type);
    _exactBackends[type] = complexObjectBackend;
    return complexObjectBackend;
  }

  void register(Type type, GeneratorBackend backend) {
    _exactBackends[type] = backend;
  }

  void registerAll(Map<Type, GeneratorBackend> backends) {
    backends.forEach((type, backend) => register(type, backend));
  }
}
