import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/backends/generator_backend.dart';

class MapBackend extends GeneratorBackend<Map<Object, Object>> {
  final Type _keyType;
  final Type _valueType;

  MapBackend(this._keyType, this._valueType);

  @override
  Map<Object, Object> get(ActivationContext context) {
    final result = empty();
    if (context.isVisitLimitReached(_keyType) || context.isVisitLimitReached(_valueType)) {
      return result;
    }

    for (var i = 0; i < context.arraySize(_valueType); i++) {
      final key = context.create(_keyType, context);
      final value = context.create(_valueType, context);
      result[key] = value;
    }
    return result;
  }

  Map<Object, Object> empty() {
    final reflectedList = reflectType(Map, [_keyType, _valueType]);
    return (reflectedList as ClassMirror).newInstance(Symbol(''), []).reflectee as Map;
  }
}
