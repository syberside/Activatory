import 'dart:collection';
import 'dart:mirrors';

import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/internal_activation_context.dart';

class ReflectiveSetFactory extends Factory<Set<Object>> {
  final Type _type;
  static const _emptyConstructorName = Symbol('');

  ReflectiveSetFactory(this._type);

  @override
  Set get(InternalActivationContext context) {
    final value = getDefaultValue();
    // Prevent from creating set of nulls.
    if (context.isVisitLimitReached(_type)) {
      return value;
    }

    // Result size of set can be lower than requested due to duplicate result of createUntyped call.
    for (var i = 0; i < context.arraySize(_type); i++) {
      value.add(context.createUntyped(_type));
    }
    return value;
  }

  @override
  Set<Object> getDefaultValue() {
    final reflectedSet = reflectType(LinkedHashSet, [_type]);
    return (reflectedSet as ClassMirror).newInstance(_emptyConstructorName, <Object>[]).reflectee as Set;
  }
}
