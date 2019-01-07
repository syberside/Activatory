import 'package:activatory/src/activation_context.dart';

abstract class ValueGenerator{
  T createTyped<T>(ActivationContext context);
  Object create(Type type, ActivationContext context);
}
