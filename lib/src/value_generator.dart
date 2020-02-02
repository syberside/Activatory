import 'package:activatory/src/factories-registry/factories_registry.dart';
import 'package:activatory/src/internal_activation_context.dart';
import 'package:activatory/src/post-activation/reflective_fields_filler.dart';

class ValueGenerator {
  final FactoriesRegistry _factoriesRegistry;
  final ReflectiveFieldsFiller _fieldsFiller;

  ValueGenerator(
    this._factoriesRegistry,
    this._fieldsFiller,
  );

  Object createUntyped(Type type, InternalActivationContext context) {
    final factory = _factoriesRegistry.getFactory(type, context.key);
    final Object value = factory.get(context);
    _fieldsFiller.fill(value, context);
    return value;
  }
}
