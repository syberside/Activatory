import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class RecurrencyLimiter<T> implements GeneratorBackend<T>{

  final Type _type;
  final GeneratorBackend<T> _wrapped;
  final T _defaultValue;

  RecurrencyLimiter(this._type, this._wrapped, this._defaultValue);

  @override
  T get(ActivationContext context) {
    if(context.isVisitLimitReached(_type)){
      return _defaultValue;
    }
    context.notifyVisiting(_type);
    T result = _wrapped.get(context);
    context.notifyVisited(_type);
    return result;
  }
}