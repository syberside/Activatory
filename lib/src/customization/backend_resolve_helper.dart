import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/factory_wrapper.dart';

void assertBackendsNotEmpty(List<Factory> ctors) {
  if (ctors.isEmpty) {
    throw ActivationException('Cant resolve ctor strategy because no matching ctors found');
  }
}

Factory unwrap(Factory backend) {
  if (backend is FactoryWrapper) {
    var casted = backend as FactoryWrapper;
    return unwrap(casted.wrapped);
  }
  return backend;
}
