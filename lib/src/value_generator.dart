import 'package:activatory/src/activation_context.dart';

abstract class ValueGenerator {
  Object create(Type type, ActivationContext context);
  T createTyped<T>(ActivationContext context);
}
