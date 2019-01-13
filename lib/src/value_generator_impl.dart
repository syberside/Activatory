import 'package:activatory/activatory.dart';
import 'package:activatory/src/backends_registry.dart';
import 'package:activatory/src/value_generator.dart';

class ValueGeneratorImpl implements ValueGenerator{
  final BackendsRegistry _backendsRegistry;

  ValueGeneratorImpl(this._backendsRegistry);

  @override
  Object create(Type type, ActivationContext context) {
    var backend = _backendsRegistry.get(type, context);
    var value = backend.get(context);
    return value;
  }

  @override
  T createTyped<T>(ActivationContext context) => create(T, context);
}