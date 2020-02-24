import 'dart:math';
import 'dart:mirrors';

import 'package:activatory/src/activation_exception.dart';
import 'package:activatory/src/factories/collections/explicit_array_factory.dart';
import 'package:activatory/src/factories/collections/reflective_array_factory.dart';
import 'package:activatory/src/factories/collections/reflective_map_factory.dart';
import 'package:activatory/src/factories/collections/reflective_set_factory.dart';
import 'package:activatory/src/factories/ctor/argument_info.dart';
import 'package:activatory/src/factories/ctor/ctor_info.dart';
import 'package:activatory/src/factories/ctor/ctor_type.dart';
import 'package:activatory/src/factories/ctor/reflective_object_factory.dart';
import 'package:activatory/src/factories/factory.dart';
import 'package:activatory/src/factories/primitives/null_factory.dart';
import 'package:activatory/src/factories/primitives/random_bool_factory.dart';
import 'package:activatory/src/factories/primitives/random_date_time_factory.dart';
import 'package:activatory/src/factories/primitives/random_double_factory.dart';
import 'package:activatory/src/factories/primitives/random_duration_factory.dart';
import 'package:activatory/src/factories/primitives/random_int_factory.dart';
import 'package:activatory/src/factories/primitives/random_string_factory.dart';
import 'package:activatory/src/factories/random_array_item_factory.dart';
import 'package:activatory/src/helpers/type_helper.dart';

typedef _FactoryActivator = Factory Function();

class FactoriesProvider {
  static const _emptySymbol = Symbol('');
  final Random _random;
  final Map<Type, _FactoryActivator> _predefinedFactories = <Type, _FactoryActivator>{};

  final _listMirror = reflectClass(List);
  final _setMirror = reflectClass(Set);
  final _mapMirror = reflectClass(Map);

  FactoriesProvider(this._random) {
    _predefinedFactories[bool] = () => RandomBoolFactory(_random);
    _predefinedFactories[int] = () => RandomIntFactory(_random);
    _predefinedFactories[double] = () => RandomDoubleFactory(_random);
    _predefinedFactories[String] = () => RandomStringFactory();
    _predefinedFactories[DateTime] = () => RandomDateTimeFactory(_random);
    _predefinedFactories[Duration] = () => RandomDurationFactory(_random);
    _predefinedFactories[Null] = () => NullFactory();

    //TODO: Explicit factories are not required here. Reflective will works fine.
    _predefinedFactories[getType<List<bool>>()] = () => ExplicitArrayFactory<bool>();
    _predefinedFactories[getType<List<int>>()] = () => ExplicitArrayFactory<int>();
    _predefinedFactories[getType<List<double>>()] = () => ExplicitArrayFactory<double>();
    _predefinedFactories[getType<List<String>>()] = () => ExplicitArrayFactory<String>();
    _predefinedFactories[getType<List<DateTime>>()] = () => ExplicitArrayFactory<DateTime>();
    _predefinedFactories[getType<List<Null>>()] = () => ExplicitArrayFactory<Null>();
  }

  List<Factory> create(Type type) {
    final predefinedFactory = _predefinedFactories[type];
    if (predefinedFactory != null) {
      return [predefinedFactory()];
    }
    final classMirror = reflectType(type) as ClassMirror;
    if (classMirror.isEnum) {
      return [_createEnumBackend(classMirror)];
    } else {
      return _createObjectReflectiveFactories(classMirror, type);
    }
  }

  List<Factory> _createObjectReflectiveFactories(ClassMirror classMirror, Type type) {
    // We need to make sure that we are using original class mirror, not generic subtype
    // Otherwise subtype check will return false
    final originalClassMirror = reflectClass(type);
    if (originalClassMirror.isSubtypeOf(_listMirror)) {
      final typeArg = classMirror.typeArguments.first.reflectedType;
      return [ReflectiveArrayFactory(typeArg)];
    }

    if (originalClassMirror.isSubclassOf(_setMirror)) {
      final typeArg = classMirror.typeArguments.first.reflectedType;
      return [ReflectiveSetFactory(typeArg)];
    }

    if (originalClassMirror.isSubclassOf(_mapMirror)) {
      final typeArg1 = classMirror.typeArguments[0].reflectedType;
      final typeArg2 = classMirror.typeArguments[1].reflectedType;
      return [ReflectiveMapFactory(typeArg1, typeArg2)];
    }

    if (classMirror.isAbstract) {
      throw ActivationException('Cant create instance of abstract class (${classMirror})');
    }

    final constructors = _extractConstructors(classMirror, type)
        .map((ctorInfo) => ReflectiveObjectFactory(ctorInfo))
        .toList(growable: false);
    if (constructors.isEmpty) {
      throw ActivationException('Cant find constructor for type ${classMirror}');
    }

    return constructors;
  }

  Factory _createEnumBackend(ClassMirror classMirror) {
    final declaration = classMirror.declarations.values
        .whereType<VariableMirror>()
        .where((d) => d.isStatic && d.simpleName == #values)
        .first;
    if (declaration == null) {
      throw ActivationException('Declaration of values for enum ${classMirror} not found');
    }

    final allValues = classMirror.getField(declaration.simpleName).reflectee as List;
    if (allValues.isEmpty) {
      throw ActivationException('Enum ${classMirror} values found but empty');
    }

    return RandomArrayItemFactory(allValues);
  }

  Iterable<CtorInfo> _extractConstructors(ClassMirror classMirror, Type type) sync* {
    final constructors = classMirror.declarations.values;

    for (var method in constructors) {
      if (method is MethodMirror && method.isConstructor && !method.isPrivate) {
        final arguments = method.parameters.map(constructArgumentInfo).toList(growable: false);
        final name = method.constructorName;
        final ctorType = method.constructorName != _emptySymbol ? CtorType.Named : CtorType.Default;
        yield CtorInfo(classMirror, name, arguments, ctorType, type);
      }
    }
  }

  ArgumentInfo constructArgumentInfo(ParameterMirror parameter) {
    final argType = parameter.type.reflectedType;
    final Object defaultValue = parameter.defaultValue?.reflectee;
    final isNamed = parameter.isNamed;
    return ArgumentInfo(defaultValue, isNamed, parameter.simpleName, argType);
  }
}
