import 'package:activatory/activatory.dart';
import 'package:activatory/src/factories_registry.dart';
import 'package:activatory/src/post_activation/fields_filler.dart';
import 'package:activatory/src/value_generator.dart';

class ValueGeneratorImpl implements ValueGenerator {
  final FactoriesRegistry _backendsRegistry;
  final FieldsFiller _fieldsFiller;

  ValueGeneratorImpl(this._backendsRegistry, this._fieldsFiller);

  @override
  Object create(Type type, ActivationContext context) {
    var backend = _backendsRegistry.get(type, context);
    var value = backend.get(context);
    _fieldsFiller.fill(value, context);
    return value;
  }

  @override
  T createTyped<T>(ActivationContext context) => create(T, context);
}
