import 'package:activatory/src/factories-registry/factories_registry.dart';
import 'package:activatory/src/internal_activation_context.dart';
import 'package:activatory/src/post-activation/reflective_fields_filler.dart';
import 'package:activatory/src/value-generator/value_generator.dart';

class ValueGeneratorImpl implements ValueGenerator {
  final FactoriesRegistry _factoriesRegistry;
  final ReflectiveFieldsFiller _fieldsFiller;

  ValueGeneratorImpl(
    this._factoriesRegistry,
    this._fieldsFiller,
  );

  @override
  Object createUntyped(Type type, InternalActivationContext context) {
    final factory = _factoriesRegistry.getFactory(type, context.key);
    final Object value = factory.get(context);
    _fieldsFiller.fill(value, context);
    return value;
  }

  @override
  T create<T>(InternalActivationContext context) => createUntyped(T, context) as T;
}
