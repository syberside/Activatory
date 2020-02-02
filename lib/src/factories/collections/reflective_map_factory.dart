import 'dart:mirrors';

import 'package:activatory/src/activation_context.dart';
import 'package:activatory/src/factories/factory.dart';

class ReflectiveMapFactory<TKey, TValue> implements Factory<Map<TKey, TValue>> {
  final Type _keyType;
  final Type _valueType;

  ReflectiveMapFactory(this._keyType, this._valueType);

  @override
  Map<TKey, TValue> get(ActivationContext context) {
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

  Map<TKey, TValue> createEmptyMap() {
    final reflectedList = reflectType(Map, [_keyType, _valueType]);
    return (reflectedList as ClassMirror).newInstance(Symbol(''), []).reflectee as Map<TKey, TValue>;
  }

  @override
  Map<TKey, TValue> getDefaultValue() => createEmptyMap();
}
