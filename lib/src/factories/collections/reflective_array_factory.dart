import 'dart:mirrors';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ReflectiveArrayFactory extends Factory<List<Object>> {
  final Type _type;

  ReflectiveArrayFactory(this._type);

  @override
  List get(InternalActivationContext context) {
    final value = getDefaultValue();
    // Prevent from creating array of nulls.
    if (context.isVisitLimitReached(_type)) {
      return value;
    }

    for (int i = 0; i < context.arraySize(_type); i++) {
      value.add(context.createUntyped(_type, context));
    }
    return value;
  }

  @override
  List<Object> getDefaultValue() {
    final reflectedList = reflectType(List, [_type]);
    return (reflectedList as ClassMirror).newInstance(Symbol(''), []).reflectee as List;
  }
}
