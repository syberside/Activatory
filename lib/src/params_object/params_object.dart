import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/params_object/value.dart';

/// Base class for implementing parametrized factories.
/// Extend this class and implement [resolve] method.
/// To simplify optional parameters handling [Value] and [NullValue] classes can be used.
abstract class Params<TResult> {
  T get<T>(Value<T> value, ActivationContext ctx) {
    if (value == null) {
      return ctx.createTyped<T>(ctx);
    }
    return value.value;
  }

  TResult resolve(ActivationContext ctx);
}
