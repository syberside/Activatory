import 'package:activatory/src/activation_context.dart';

abstract class Params<TResult>{

  TResult resolve(ActivationContext ctx);

  T get<T>(Value<T> value, ActivationContext ctx){
    if(value == null){
      return ctx.createTyped<T>(ctx);
    }
    return value.value;
  }
}

class Value<T>{
  final T value;

  const Value(this.value);
}

Value<T> v<T>(T value) => new Value<T>(value);

class NullValue<T> extends Value<T>{
  const NullValue() : super(null);
}