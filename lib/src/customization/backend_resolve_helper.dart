import 'package:activatory/activatory.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/generator_backend_wrapper.dart';

void assertBackendsNotEmpty(List<GeneratorBackend> ctors) {
  if (ctors.isEmpty) {
    throw ActivationException('Cant resolve ctor strategy because no matching ctors found');
  }
}

GeneratorBackend unwrap(GeneratorBackend backend) {
  if (backend is GeneratorBackendWrapper) {
    var casted = backend as GeneratorBackendWrapper;
    return unwrap(casted.wrapped);
  }
  return backend;
}
