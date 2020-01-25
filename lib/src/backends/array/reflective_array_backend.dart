import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/array/array_backend.dart';

class ReflectiveArrayBackend extends ArrayBackend<Object> {
  final Type _type;

  ReflectiveArrayBackend(this._type);

  @override
  List get(ActivationContext context) {
    final value = empty();
    if (context.isVisitLimitReached(_type)) {
      return value;
    }

    for (int i = 0; i < context.arraySize(_type); i++) {
      value.add(context.create(_type, context));
    }
    return value;
  }

  @override
  List<Object> empty() {
    final reflectedList = reflectType(List, [_type]);
    return (reflectedList as ClassMirror).newInstance(Symbol(''), []).reflectee as List;
  }
}
