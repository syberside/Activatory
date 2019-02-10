import 'package:activatory/src/activation_context.dart';

Value<T> v<T>(T value) => new Value<T>(value);

class NullValue<T> extends Value<T> {
  const NullValue() : super(null);
}

abstract class Params<TResult> {
  T get<T>(Value<T> value, ActivationContext ctx) {
    if (value == null) {
      return ctx.createTyped<T>(ctx);
    }
    return value.value;
  }

  TResult resolve(ActivationContext ctx);
}

class Value<T> {
  final T value;

  const Value(this.value);
}
