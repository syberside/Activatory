import 'package:activatory/src/internal_activation_context.dart';

abstract class ValueGenerator {
  Object createUntyped(Type type, InternalActivationContext context);

  T create<T>(InternalActivationContext context);
}
