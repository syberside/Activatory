import 'dart:mirrors';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ReflectiveMapFactory implements Factory<Map<Object, Object>> {
  final Type _keyType;
  final Type _valueType;

  ReflectiveMapFactory(this._keyType, this._valueType);

  @override
  Map get(InternalActivationContext context) {
    final result = createEmptyMap();
    // Prevent from creating array of nulls.
    if (context.isVisitLimitReached(_keyType) || context.isVisitLimitReached(_valueType)) {
      return result;
    }

    for (var i = 0; i < context.arraySize(_valueType); i++) {
      final key = context.createUntyped(_keyType, context);
      final value = context.createUntyped(_valueType, context);
      result[key] = value;
    }
    return result;
  }

  Map createEmptyMap() {
    final reflectedList = reflectType(Map, [_keyType, _valueType]);
    return (reflectedList as ClassMirror).newInstance(const Symbol(''), <Object>[]).reflectee as Map;
  }

  @override
  Map getDefaultValue() => createEmptyMap();
}
