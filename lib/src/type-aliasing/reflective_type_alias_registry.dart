import 'dart:mirrors';

import 'package:activatory/src/helpers/type_helper.dart';

class ReflectiveTypeAliasesRegistry {
  final Map<Type, Type> _aliases = {
    getType<Iterable<bool>>(): getType<List<bool>>(),
    getType<Iterable<int>>(): getType<List<int>>(),
    getType<Iterable<double>>(): getType<List<double>>(),
    getType<Iterable<String>>(): getType<List<String>>(),
    getType<Iterable<DateTime>>(): getType<List<DateTime>>(),
    getType<Iterable<Null>>(): getType<List<Null>>(),
  };

  final _iterableMirror = reflectClass(Iterable);

  Type getAlias(Type type) {
    var result = _aliases[type];
    if (result != null) {
      return result;
    }

    final classMirror = reflectClass(type);
    if (classMirror.isSubclassOf(_iterableMirror)) {
      final typeArg = reflectType(type).typeArguments.first.reflectedType;
      final listType = reflectType(List, [typeArg]).reflectedType;
      _aliases[type] = listType;
      return listType;
    }

    result = type;
    _aliases[type] = type;
    return result;
  }

  void setAlias(Type source, Type target) {
    _aliases[source] = target;
  }

  void putIfAbsent(Type source, Type target) {
    var currentRegistration = getAlias(source);
    if (source != currentRegistration) {
      return;
    }
    setAlias(source, target);
  }
}
