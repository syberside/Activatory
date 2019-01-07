import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class RecurrencyLimiter<T> implements GeneratorBackend<T>{

  final Type _type;
  final GeneratorBackend<T> _wrapped;
  final T _defaultValue;

  RecurrencyLimiter(this._type, this._wrapped);

  @override
  T get(ActivationContext context) {
    if(context.isVisitLimitReached(_type)){
      var classMirror = reflectClass(_type);
      if(classMirror.isSubclassOf(reflectClass(List))){
        return new List() as T;
      }
      return null;
    }
    context.notifyVisiting(_type);
    T result = _wrapped.get(context);
    context.notifyVisited(_type);
    return result;
  }
}