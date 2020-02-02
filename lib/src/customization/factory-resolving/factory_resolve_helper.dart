import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/wrappers/factory_wrapper.dart';

void assertAnyFactoryFound(List<Factory> factories) {
  if (factories.isEmpty) {
    throw ActivationException('Cant resolve ctor strategy because no matching ctors found');
  }
}

Factory unwrap(Factory backend) {
  if (backend is FactoryWrapper) {
    final casted = backend as FactoryWrapper;
    return unwrap(casted.wrapped);
  }
  return backend;
}
