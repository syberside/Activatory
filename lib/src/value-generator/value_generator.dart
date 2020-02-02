import 'package:activatory/src/activation_context.dart';

abstract class ValueGenerator {
  Object createUntyped(Type type, ActivationContext context);

  T create<T>(ActivationContext context);
}
