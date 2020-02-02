import 'package:activatory/activatory.dart';
import 'package:activatory/src/factories-registry/factories_registry.dart';
import 'package:activatory/src/post-activation/reflective_fields_filler.dart';
import 'package:activatory/src/value-generator/value_generator.dart';

class ValueGeneratorImpl implements ValueGenerator {
  final FactoriesRegistry _factoriesRegistry;
  final FieldsFiller _fieldsFiller;

  ValueGeneratorImpl(
    this._factoriesRegistry,
    this._fieldsFiller,
  );

  @override
  Object createUntyped(Type type, ActivationContext context) {
    var backend = _factoriesRegistry.getFactory(type, context.key);
    var value = backend.get(context);
    _fieldsFiller.fill(value, context);
    return value;
  }

  @override
  T create<T>(ActivationContext context) => createUntyped(T, context);
}
