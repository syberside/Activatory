import 'package:activatory/src/internal_activation_context.dart';

abstract class Factory<T> {
  T get(InternalActivationContext context);

  T getDefaultValue();
}
