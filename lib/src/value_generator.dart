import 'package:activatory/src/activation_context.dart';

abstract class ValueGenerator{
  T createTyped<T>(ActivationCtx context);
  Object create(Type type, ActivationCtx context);
}
