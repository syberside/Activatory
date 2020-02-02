import 'package:activatory/src/activation_context.dart';

abstract class Factory<T> {
  T get(ActivationContext context);

  T getDefaultValue();
}
