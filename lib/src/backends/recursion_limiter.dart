import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/array_backend.dart';
import 'package:activatory/src/backends/generator_backend.dart';
import 'package:activatory/src/backends/generator_backend_wrapper.dart';

class RecursionLimiter<T> implements GeneratorBackend<T>, GeneratorBackendWrapper<T> {
  final Type _type;
  final GeneratorBackend<T> _wrapped;
  final ClassMirror _listMirror = reflectClass(List);

  RecursionLimiter(this._type, this._wrapped);

  @override
  GeneratorBackend<T> get wrapped => _wrapped;

  @override
  T get(ActivationContext context) {
    if (context.isVisitLimitReached(_type)) {
      var classMirror = reflectClass(_type);
      if(classMirror.isSubclassOf(_listMirror)){
        return (_wrapped as ArrayBackend).empty() as T;
      }
      return null;
    }
    context.notifyVisiting(_type);
    T result = _wrapped.get(context);
    context.notifyVisited(_type);
    return result;
  }
}
