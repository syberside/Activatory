import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/params_object/value.dart';

abstract class Params<TResult> {
  T get<T>(Value<T> value, ActivationContext ctx) {
    if (value == null) {
      return ctx.createTyped<T>(ctx);
    }
    return value.value;
  }

  TResult resolve(ActivationContext ctx);
}
