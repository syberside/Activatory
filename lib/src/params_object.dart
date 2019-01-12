import 'package:activatory/src/activation_context.dart';

abstract class SelfResolvable<TResult>{
  TResult resolve(ActivationContext ctx);
}

abstract class ParamsObject<TResult> implements SelfResolvable<TResult>{
  T get<T>(Value<T> value, ActivationContext ctx){
    if(value == null){
      return ctx.createTyped<T>(ctx);
    }
    return value.resolve(ctx);
  }
}

class Value<T> implements SelfResolvable<T>{
  final T _value;

  const Value(this._value);

  @override
  T resolve(ActivationContext ctx) {
    return _value;
  }
}

Value<T> v<T>(T value) => new Value<T>(value);

class NullValue<T> extends Value<T>{
  const NullValue() : super(null);
}